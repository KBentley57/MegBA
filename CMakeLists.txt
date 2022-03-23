
cmake_minimum_required(VERSION 3.13 FATAL_ERROR)

project(MegBA 
    LANGUAGES CXX
    VERSION 0.0.1)

if(POLICY CMP0074)  
    cmake_policy(SET CMP0074 NEW)
endif(POLICY CMP0074)

find_package(OpenMP)

include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
    enable_language(CUDA)
    find_package(Cub REQUIRED CONFIG)
    find_package(Thrust REQUIRED CONFIG)
    thrust_create_target(Thrust)
endif(CMAKE_CUDA_COMPILER)

find_package(Eigen3 REQUIRED)

add_subdirectory(src)
add_subdirectory(examples)
