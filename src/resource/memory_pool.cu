/**
 * MegBA is Licensed under the Apache License, Version 2.0 (the "License")
 *
 * Copyright (c) 2021 Megvii Inc. All rights reserved.
 *
 **/

#include "resource/memory_pool.h"
#include "resource/handle_manager.h"
#include <unordered_map>
#include <set>
#include <stack>
#include <stdexcept>

namespace MegBA {
namespace {
union Ptr {
  explicit Ptr(void *address) : address(address) {}
  void *address;
#if __SIZEOF_POINTER__ == 8
  std::uint64_t number;
#elif __SIZEOF_POINTER__ == 4
  std::uint32_t number;
#elif __SIZEOF_POINTER__ == 2
  std::uint16_t number;
#endif
};

std::vector<std::stack<std::pair<void *, std::size_t>>> ptrRecorder{};
std::vector<std::stack<std::pair<void *, std::size_t>>> overflowedPtrRecorder{};

std::vector<std::size_t> memOffsetCounter{};

std::vector<std::size_t> memOverflowedCounter{};

std::vector<std::size_t> memOverflowedPeak{};

std::set<std::vector<void *>> managedRecorder{};
}  // namespace

void MemoryPool::resetPool(const ProblemOption *problemOption,
                           std::int8_t sizeofType) {
  int deviceCount;
  cudaGetDeviceCount(&deviceCount);
  cudaDeviceSynchronize();
  if (problemOption->deviceUsed.size() > deviceCount) {
    throw std::runtime_error(
        "world_size is larger than the number of devices you have");
  }

  // TODO(Jie Ren): maybe destroy only once
  _problemOption = problemOption;
  _sizeofType = sizeofType;
  HandleManager::destroyNCCLComm();
  HandleManager::createNCCLComm();
  HandleManager::destroyCUBLASHandle();
  HandleManager::destroyCUSPARSEHandle();
  HandleManager::createCUBLASHandle();
  HandleManager::createCUSPARSEHandle();
}

void MemoryPool::allocateJetVector(std::vector<void *> &valueDevicePtr,
                                   std::vector<void *> &gradDevicePtr,
                                   std::size_t N, std::size_t nItem,
                                   std::int8_t sizeofType) {
  const auto worldSize = getWorldSize();
  valueDevicePtr.clear();
  valueDevicePtr.resize(worldSize);
  gradDevicePtr.clear();
  gradDevicePtr.resize(worldSize);
  //  assert((N == _N || N == 0) && nItem == _nItem && sizeofType ==
  //  _sizeofType);
  for (auto offset : memOffsetCounter)
    if (offset != 0) throw std::runtime_error("memory leak");
  if (_ptr.empty()) {
    for (int i = 0; i < worldSize; ++i) {
      const auto nItem = getItemNum(i);
      cudaSetDevice(_problemOption->deviceUsed[i]);
      Ptr ptr{nullptr};
      cudaMalloc(&ptr.address, (_problemOption->N + 1) * nItem * _sizeofType);
      gradDevicePtr[i] = ptr.address;
      ptr.number += _problemOption->N * nItem * _sizeofType;
      valueDevicePtr[i] = ptr.address;
    }
    managedRecorder.insert(gradDevicePtr);
  } else {
    std::vector<void *> back = std::move(_ptr.back());
    _ptr.pop_back();
    for (int i = 0; i < worldSize; ++i) {
      const auto nItem = getItemNum(i);
      cudaSetDevice(_problemOption->deviceUsed[i]);
      Ptr ptr{back[i]};
      gradDevicePtr[i] = ptr.address;
      ptr.number += _problemOption->N * nItem * _sizeofType;
      valueDevicePtr[i] = ptr.address;
    }
  }
  _ptrInUseCounter++;
}

void MemoryPool::deallocateJetVector(std::vector<void *> &ptr) {
  _ptr.push_back(std::move(ptr));
  _ptrInUseCounter--;
}

void MemoryPool::allocateNormal(void **ptr, std::size_t size, int rank) {
  const auto worldSize = getWorldSize();
  size += size % 8;
  Ptr ptrHelper{nullptr};

  if (memOffsetCounter.empty()) {
    memOffsetCounter.resize(worldSize);
    ptrRecorder.resize(worldSize);
    std::fill(memOffsetCounter.begin(), memOffsetCounter.end(), 0);
  }

  bool use_overflowed_stack{_poolSize[rank] < (memOffsetCounter[rank] + size)};
  if (use_overflowed_stack) {
    if (overflowedPtrRecorder.empty()) {
      overflowedPtrRecorder.resize(worldSize);
      memOverflowedCounter.resize(worldSize);
      memOverflowedPeak.resize(worldSize);
      std::fill(memOverflowedCounter.begin(), memOverflowedCounter.end(), 0);
      std::fill(memOverflowedPeak.begin(), memOverflowedPeak.end(), 0);
    }

    memOverflowedPeak[rank] =
        std::max(memOverflowedPeak[rank],
                 memOffsetCounter[rank] + size - _poolSize[rank]);
    cudaSetDevice(rank);
    cudaMalloc(&ptrHelper.address, size);
    overflowedPtrRecorder[rank].emplace(ptrHelper.address, size);
    memOverflowedCounter[rank] += size;
  } else {
    ptrHelper.address = _headPtr[rank];
    ptrHelper.number += memOffsetCounter[rank];
    memOffsetCounter[rank] += size;
  }
  *ptr = ptrHelper.address;
  if (!use_overflowed_stack) {
    ptrRecorder[rank].emplace(ptrHelper.address, size);
  }
}

void MemoryPool::deallocateNormal(void *ptr, int rank) {
  std::pair<void *, std::size_t> back;
  if (ptrRecorder[rank].top().first == ptr) {
    back = std::move(ptrRecorder[rank].top());
    ptrRecorder[rank].pop();
    memOffsetCounter[rank] -= back.second;
  } else {
    if (!overflowedPtrRecorder[rank].empty() &&
        overflowedPtrRecorder[rank].top().first == ptr) {
      back = std::move(overflowedPtrRecorder[rank].top());
      overflowedPtrRecorder[rank].pop();
      cudaSetDevice(rank);
      cudaFree(back.first);
      memOverflowedCounter[rank] -= back.second;
    } else {
      throw std::runtime_error("not using a stack style malloc-free");
    }
  }
}

void MemoryPool::redistribute() {
  const auto worldSize = getWorldSize();
  if (_poolSize.empty()) {
    _poolSize.resize(worldSize);
    _headPtr.resize(worldSize);
    for (auto &item : _ptr) {
      managedRecorder.erase(item);
    }
    for (int i = 0; i < worldSize; ++i) {
      cudaSetDevice(_problemOption->deviceUsed[i]);
      const auto nItem = getItemNum(i);
      for (const auto &v : _ptr) {
        cudaFree(v[i]);
      }
      _poolSize[i] =
          (_problemOption->N + 1) * nItem * _sizeofType * _ptr.size();
      cudaMalloc(&_headPtr[i], _poolSize[i]);
      uint64_t offset{0};
      for (auto &item : _ptr) {
        Ptr ptr{_headPtr[i]};
        ptr.number += offset;
        offset += (_problemOption->N + 1) * nItem * _sizeofType;
        item[i] = ptr.address;
      }
    }
  } else {
    bool overflowed{false};
    for (auto peak : memOverflowedPeak) overflowed |= peak != 0;
    if (overflowed) {
      for (auto &item : _ptr) {
        managedRecorder.erase(item);
      }
      for (int i = 0; i < worldSize; ++i) {
        cudaSetDevice(_problemOption->deviceUsed[i]);
        const auto nItem = getItemNum(i);
        cudaFree(_headPtr[i]);
        _poolSize[i] += memOverflowedPeak[i];
        cudaMalloc(&_headPtr[i], _poolSize[i]);
        uint64_t offset{0};
        for (auto &item : _ptr) {
          Ptr ptr{_headPtr[i]};
          ptr.number += offset;
          offset += (_problemOption->N + 1) * nItem * _sizeofType;
          item[i] = ptr.address;
        }
      }
    }
  }
}

void MemoryPool::destruct() {
  const auto worldSize = getWorldSize();
  for (int i = 0; i < worldSize; ++i) {
    cudaSetDevice(_problemOption->deviceUsed[i]);
    cudaFree(_headPtr[i]);
  }
  for (const auto &ptr : managedRecorder) {
    for (int i = 0; i < worldSize; ++i) {
      cudaSetDevice(i);
      cudaFree(ptr[i]);
    }
  }
  _headPtr.clear();
  _ptr.clear();
  managedRecorder.clear();
}

std::vector<std::vector<void *>> MemoryPool::_ptr{};
const ProblemOption *MemoryPool::_problemOption{nullptr};
std::vector<std::size_t> MemoryPool::_poolSize{};
std::vector<void *> MemoryPool::_headPtr{};
std::uint8_t MemoryPool::_sizeofType{0};
std::size_t MemoryPool::_ptrInUseCounter{0};
}  // namespace MegBA
