add_library(base_linear_system)

target_sources(base_linear_system
    PRIVATE 
        base_linear_system.cpp)

add_library(base_linear_system_CUDA)

target_sources(base_linear_system_CUDA
    PRIVATE
        base_linear_system.cu)

target_link_libraries(base_linear_system
    PUBLIC
        base_linear_system_CUDA)

add_library(schur_linear_system) 

target_sources(schur_linear_system
    PRIVATE
        schur_linear_system.cpp)

add_library(schur_linear_system_CUDA)

target_sources(schur_linear_system_CUDA
    PRIVATE
        schur_linear_system.cu)

target_link_libraries(schur_linear_system 
    PUBLIC
        schur_linear_system_CUDA 
        base_linear_system)

add_library(LM_linear_system)

target_sources(LM_linear_system
    PRIVATE
        LM_linear_system.cpp)

add_library(LM_linear_system_CUDA)

target_sources(LM_linear_system_CUDA
    PRIVATE
        LM_linear_system.cu)

target_link_libraries(LM_linear_system 
    PUBLIC
        LM_linear_system_CUDA 
        base_linear_system)

add_library(schur_LM_linear_system)

target_sources(schur_LM_linear_system
    PRIVATE
        schur_LM_linear_system.cpp)

add_library(schur_LM_linear_system_CUDA)

target_sources(schur_LM_linear_system_CUDA
    PRIVATE
        schur_LM_linear_system.cu)

target_link_libraries(schur_LM_linear_system 
    PUBLIC 
        schur_LM_linear_system_CUDA)
        
target_link_libraries(schur_LM_linear_system
    PUBLIC
        LM_linear_system 
        schur_linear_system nccl)
