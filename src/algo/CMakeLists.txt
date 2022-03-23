add_library(base_algo)

target_sources(base_algo 
    PRIVATE 
        base_algo.cpp)

add_library(lm_algo)

target_sources(lm_algo 
    PRIVATE 
        lm_algo.cpp)

add_library(lm_algo_CUDA)

target_sources(lm_algo_CUDA 
    PRIVATE 
        lm_algo.cu)
  
target_link_libraries(lm_algo 
    PUBLIC 
        lm_algo_CUDA 
        base_algo)