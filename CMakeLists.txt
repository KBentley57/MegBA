###############################################################################
#
#   Project:  MegBA
#   
#   Description: A High-Performance and Distributed Library for Large Scale
#                bundle adjustment 
#
#   MegBA is a fast and distributed library for large-scale Bundle Adjustment 
#   (BA). MegBA has a novel end-to-end vectorised BA algorithm which can fully 
#   exploit the massive parallel cores on GPUs, thus speeding up the entire BA 
#   computation. It also has a novel distributed BA algorithm that can 
#   automatically partition BA problems, and solve BA sub-problems using 
#   distributed GPUs. The GPUs synchronise intermediate solving state using 
#   network-efficient collective communication, and the synchronisation is 
#   designed to minimise communication cost. MegBA has a memory-efficient GPU 
#   runtime and it exposes g2o-compatible APIs.
#
#   This work is described based on the paper at the arxiv link below
#   https://arxiv.org/abs/2112.01349
#
#   Authors:  Jie Ren, Wenteng Liang, Ran Yan, Luo Mai, Shiwen Liu, Xaio Liu
#   
#   Date:  2021 December 10
#
###############################################################################

cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

project(MegBA 
    LANGUAGES CXX
    DESCRIPTION "A very fast bundle adjuster"
    HOMEPAGE_URL "https://github.com/MegviiRobot/MegBA")

# This policy allows CMake Modules (for find_package) to use the 
# PACKAGNAME_ROOT variable, uniformly.
if(POLICY CMP0074)  
    cmake_policy(SET CMP0074 NEW)
endif(POLICY CMP0074)

# Apply the C++ and CUDA Standards to all targets 
if(NOT DEFINED CMAKE_CXX_STANDARD)
	set(CMAKE_CXX_STANDARD 14)
	set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
endif(NOT DEFINED CMAKE_CXX_STANDARD)

if(NOT DEFINED CMAKE_CUDA_STANDARD)
	set(CMAKE_CUDA_STANDARD 14)
	set(CMAKE_CUDA_STANDARD_REQUIRED TRUE)
endif(NOT DEFINED CMAKE_CUDA_STANDARD)

# Give the user an option to build static libraries if desired.
# The default behavior is for shared libraries on all targets.
option(BUILD_SHARED_LIBS "Builds libraries as shared" TRUE)
option(ENABLE_LTO "Enable link time optimiztion for static compilation" FALSE)

# Optionally, allow a user to add the -flto flag for static libraries.
# I would consider this experimental at this point.
if(NOT BUILD_SHARED_LIBS)
	if(ENABLE_LTO)
		set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
	endif(ENABLE_LTO)
endif(NOT BUILD_SHARED_LIBS)

# Allow an option for the use of OpenMP for shared memory parallelism.
option(ENABLE_OPENMP "Allow OpenMP for shared memory processing" TRUE)
if(ENABLE_OPENMP)
	find_package(OpenMP)
endif(ENABLE_OPENMP)

# Allow an option for building tests with CTest.
#
# @TODO Add test cases for easy regression testing.
option(ENABLE_TESTING "Enable testing with CTest" TRUE)
if(ENABLE_TESTING)    
    include(CTest)  
endif(ENABLE_TESTING)

include(FetchContent)
include(CheckLanguage)

# By default, this project utilizes CUDA as the device component for 
# Thrust.  Ensure that CUDA, Cub, Thrust, and NCCL are found correctly.
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
    enable_language(CUDA)
    # Even though the cuda language is required, a call to find_package
    # is required for the namespaced CUDA:: targets to be imported.
    find_package(CUDAToolkit 11.2 REQUIRED)
    # These architectures date back to the GTX 1000 series cards, and 
    # Quadro 100 series cards. Consult the link below for reference
    # https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/
    set(CMAKE_CUDA_ARCHITECTURES 60 61 62 70 72 75 80 86)
    # Cub and Thrust are usually found using config mode.  
    # During the configuration step, pass the location to the cmake directory for 
    # Each of these.
    #
    # Example:  cmake -DThrust_DIR=/usr/include/thrust/cmake -DCUB_DIR=/usr/include/cub/cmake ../
    find_package(CUB REQUIRED CONFIG)
    find_package(Thrust REQUIRED CONFIG)
    thrust_create_target(Thrust)

    #@TODO NCCL CMake Module
    #
    # Create a module for easier use of NCCL.  Currently the build system uses
    # a Makefile approach that is not at all user friendly, or highly successful.
    # For now I'm hard coding these in until I get a chance to fix it up.
    set(NCCL_INCLUDE_DIR "/home/bentleykw/Downloads/nccl-2.12.7-1/build/include")
    set(NCCL_LIB_DIR "/home/bentleykw/Downloads/nccl-2.12.7-1/build/lib")        
endif(CMAKE_CUDA_COMPILER)

# Most users will have, or can get Eigen3 from their repository, or other means.  
# This option allows that usage by setting EXTERNAL_EIGEN to TRUE
#
# Example: cmake -DEXTERNAL_EIGEN=TRUE ../
#
# Eigen is typically found without a Module, similar to Cub and Thrust.
option(EXTERNAL_EIGEN "Use an external version of Eigen3" TRUE)

if(EXTERNAL_EIGEN)
    find_package(Eigen3 3.4 REQUIRED NO_MODULE)
endif(EXTERNAL_EIGEN)

# If the package wasn't found, even if the user believed to have it, then we can 
# use The FetchContent function introduced in CMake 3.11 to pull it from git.
if(NOT Eigen3_FOUND OR NOT EXTERNAL_EIGEN)
    message(STATUS "Fetching Eigen3 from git")
    FetchContent_Declare(
        Eigen3
        GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
        GIT_TAG 3147391d946bb4b6c68edd901f2add6ac1f31f8c) #Release 3.4.0
    FetchContent_MakeAvailable(Eigen3)
endif(NOT Eigen3_FOUND OR NOT EXTERNAL_EIGEN)

# The same goes for argparse.  A user can install it, but since it is not 
# as popular as Eigen, it is more likely to need installation, or cloning from
# a repository
option(EXTERNAL_ARGPARSE "Use an external version of argparse" FALSE)

if(NOT EXTERNAL_ARGPARSE)
    message(STATUS "Fetching argparse from git")
    FetchContent_Declare(
        argparse
        GIT_REPOSITORY https://github.com/JieRen98/argparse.git
        GIT_TAG d3354827b6dba6ab87366af0bb34acf3baf42791)
    FetchContent_MakeAvailable(argparse)
endif(NOT EXTERNAL_ARGPARSE)

add_subdirectory(src)

# Build all the examples by default.  If a user wishes to skip this step, or if 
# a c++17 compiler isn't available, set this to false.
#
# Exmaple:  cmake -DBUILD_EXAMPLES=FALSE ../
option(BUILD_EXAMPLES "Build examples" TRUE)
if(BUILD_EXAMPLES)
	add_subdirectory(examples)
endif(BUILD_EXAMPLES)
