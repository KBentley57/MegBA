
###############################################################################
#
#   Download data 
#
###############################################################################

# Provide the option to download additional data for the examples.  This allows 
# us to keep minimal data in the repository.
option(DOWNLOAD_TEST_DATA "Downloads additional test data" FALSE)
if(DOWNLOAD_TEST_DATA)
    include("Venice.cmake")
    if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/venice)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/venice)
        foreach(problem ${Venice})
            set(filename ${problem} NAME)
            file(DOWNLOAD 
                 ${problem}
                 ${CMAKE_CURRENT_BINARY_DIR}/venice/${filename}
                 SHOW_PROGRESS
                 LOG venice_download.txt)
        endforeach(problem ${Venice})
    endif(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/venice)

    file(GLOB archives ${CMAKE_CURRENT_BINARY_DIR}/venice/*)
    foreach(archive ${archives})
        file(ARCHIVE_EXTRACT 
             INPUT ${archive} 
             DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/venice
             PATTERN *.bz2)
    endforeach(archive ${archives})
endif(DOWNLOAD_TEST_DATA)

###############################################################################
#
#   Extract the single data file provided with this repository
#
###############################################################################

file(ARCHIVE_EXTRACT 
     INPUT ${CMAKE_CURRENT_SOURCE_DIR}/problem-52-64053-pre.txt.xz
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

###############################################################################
#
#   Double precision variant
#
###############################################################################

add_executable(BAL_Double)

target_sources(BAL_Double
    PRIVATE 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/BAL_numerical.cpp>
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/problem/base_problem.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/edge/base_edge.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/vertex/base_vertex.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/geo/geo.cuh>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/algo/lm_algo.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/solver/schur_pcg_solver.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/linear_system/schur_LM_linear_system.h>)

target_compile_definitions(BAL_Double 
    PRIVATE
        PRECISION=double)

target_include_directories(BAL_Double
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    PUBLIC
        $<BUILD_INTERFACE:${CUDAToolkit_INCLUDE_DIRS}>)

target_link_libraries(BAL_Double
    PUBLIC
        base_problem 
        base_edge 
        jet_vector 
        geo
        lm_algo 
        schur_LM_linear_system 
        schur_pcg_solver 
        argparse)

target_compile_features(BAL_Double  
    PRIVATE
        cxx_std_17)

###############################################################################
#
#   Single precision variant
#
###############################################################################
add_executable(BAL_Float)

target_sources(BAL_Float
    PRIVATE 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/BAL_numerical.cpp>
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/problem/base_problem.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/edge/base_edge.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/vertex/base_vertex.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/geo/geo.cuh>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/algo/lm_algo.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/solver/schur_pcg_solver.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/linear_system/schur_LM_linear_system.h>)

target_compile_definitions(BAL_Float
    PRIVATE
        PRECISION=float)

target_include_directories(BAL_Float
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CUDAToolkit_INCLUDE_DIRS}>)

target_link_libraries(BAL_Float
    PUBLIC
        base_problem 
        base_edge 
        jet_vector 
        geo
        lm_algo 
        schur_LM_linear_system 
        schur_pcg_solver 
        argparse)

target_compile_features(BAL_Float  
    PRIVATE
        cxx_std_17)

###############################################################################
#
#   Double precision variant (analytical)
#
###############################################################################

add_executable(BAL_Double_analytical)

target_sources(BAL_Double_analytical
    PRIVATE 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/BAL_analytical.cpp>
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/problem/base_problem.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/edge/base_edge.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/vertex/base_vertex.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/geo/geo.cuh>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/algo/lm_algo.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/solver/schur_pcg_solver.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/linear_system/schur_LM_linear_system.h>)

target_compile_definitions(BAL_Double_analytical
    PRIVATE
        PRECISION=double)

target_include_directories(BAL_Double_analytical
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    PUBLIC
        $<BUILD_INTERFACE:${CUDAToolkit_INCLUDE_DIRS}>)

target_link_libraries(BAL_Double_analytical
    PUBLIC
        base_problem 
        base_edge 
        jet_vector 
        geo
        lm_algo 
        schur_LM_linear_system 
        schur_pcg_solver 
        argparse)

target_compile_features(BAL_Double_analytical  
    PRIVATE
        cxx_std_17)

###############################################################################
#
#   Float precision variant (analytical)
#
###############################################################################

add_executable(BAL_Float_analytical)

target_sources(BAL_Float_analytical
    PRIVATE 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/BAL_analytical.cpp>
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/problem/base_problem.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/edge/base_edge.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/vertex/base_vertex.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/geo/geo.cuh>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/algo/lm_algo.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/solver/schur_pcg_solver.h>
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/linear_system/schur_LM_linear_system.h>)

target_compile_definitions(BAL_Float_analytical
    PRIVATE
        PRECISION=float)

target_include_directories(BAL_Float_analytical
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    PUBLIC
        $<BUILD_INTERFACE:${CUDAToolkit_INCLUDE_DIRS}>)

target_link_libraries(BAL_Float_analytical
    PUBLIC
        base_problem 
        base_edge 
        jet_vector 
        geo
        lm_algo 
        schur_LM_linear_system 
        schur_pcg_solver 
        argparse)

target_compile_features(BAL_Float_analytical  
    PRIVATE
        cxx_std_17)
