
cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

project(MegBA 
    LANGUAGES CXX
    DESCRIPTION "A very fast bundle adjuster"
    HOMEPAGE_URL "https://github.com/MegviiRobot/MegBA")

if(POLICY CMP0074)  
    cmake_policy(SET CMP0074 NEW)
endif(POLICY CMP0074)

if(NOT DEFINED CMAKE_CXX_STANDARD)
	set(CMAKE_CXX_STANDARD 14)
	set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
endif(NOT DEFINED CMAKE_CXX_STANDARD)

if(NOT DEFINED CMAKE_CUDA_STANDARD)
	set(CMAKE_CUDA_STANDARD 14)
	set(CMAKE_CUDA_STANDARD_REQUIRED TRUE)
endif(NOT DEFINED CMAKE_CUDA_STANDARD)

option(BUILD_SHARED_LIBS "Builds libraries as shared" TRUE)
option(ENABLE_LTO "Enable link time optimiztion for static compilation" FALSE)

if(NOT BUILD_SHARED_LIBS)
	if(ENABLE_LTO)
		set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
	endif(ENABLE_LTO)
endif(NOT BUILD_SHARED_LIBS)

option(ENABLE_OPENMP "Allow OpenMP for shared memory processing" TRUE)
if(ENABLE_OPENMP)
	find_package(OpenMP)
endif(ENABLE_OPENMP)

include(FetchContent)

include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
    enable_language(CUDA)
    find_package(CUDAToolkit 11.2 REQUIRED)
    set(CMAKE_CUDA_ARCHITECTURES "86")
    set(CMAKE_CUDA_SEPARABLE_COMPILATION ON)
    list(APPEND CUDA_NVCC_FLAGS "--expt-relaxed-constexpr")
    find_package(CUB REQUIRED CONFIG)
    find_package(Thrust REQUIRED CONFIG)
    thrust_create_target(Thrust)
    
    #find_package(NCCL REQUIRED)
    set(NCCL_INCLUDE_DIR "/home/bentleykw/Downloads/nccl-2.12.7-1/build/include")
    set(NCCL_LIB_DIR "/home/bentleykw/Downloads/nccl-2.12.7-1/build/lib")        
endif(CMAKE_CUDA_COMPILER)

option(EXTERNAL_EIGEN "Use an external version of Eigen3" FALSE)

if(EXTERNAL_EIGEN)
    find_package(Eigen3 3.4 REQUIRED NO_MODULE)
endif(EXTERNAL_EIGEN)

if(NOT Eigen3_FOUND OR NOT EXTERNAL_EIGEN)
    message(STATUS "Fetching Eigen3 from git")
    FetchContent_Declare(
        Eigen3
        GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
        GIT_TAG 3147391d946bb4b6c68edd901f2add6ac1f31f8c) #Release 3.4.0
    FetchContent_MakeAvailable(Eigen3)
endif(NOT Eigen3_FOUND OR NOT EXTERNAL_EIGEN)

option(EXTERNAL_ARGPARSE "Use an external version of argparse" TRUE)

if(NOT EXTERNAL_ARGPARSE)
    message(STATUS "Fetching argparse from git")
    FetchContent_Declare(
        argparse
        GIT_REPOSITORY https://github.com/JieRen98/argparse.git
        GIT_TAG d3354827b6dba6ab87366af0bb34acf3baf42791)
    FetchContent_MakeAvailable(argparse)
endif(NOT EXTERNAL_ARGPARSE)

add_subdirectory(src)

option(BUILD_EXAMPLES "Build examples" TRUE)

if(BUILD_EXAMPLES)
	add_subdirectory(examples)
endif(BUILD_EXAMPLES)
