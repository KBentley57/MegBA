add_library(base_algo)

target_sources(base_algo 
    PRIVATE 
        base_algo.cpp)
        
target_include_directories(base_algo
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_link_libraries(base_algo
	PUBLIC
		Eigen3::Eigen)

add_library(lm_algo)

target_sources(lm_algo 
    PRIVATE 
        lm_algo.cpp)
        
target_include_directories(lm_algo
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>)

add_library(lm_algo_CUDA)

target_sources(lm_algo_CUDA 
    PRIVATE 
        lm_algo.cu)
        
target_compile_options(lm_algo_CUDA
	PUBLIC
		$<$<BUILD_INTERFACE:$<COMPILE_LANGUAGE:CUDA>>:--extended-lambda>)
        
target_include_directories(lm_algo_CUDA
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
set_target_properties(lm_algo_CUDA
	PROPERTIES
		CUDA_SEPARABLE_COMPILATION ON)		
		
target_link_libraries(lm_algo_CUDA
	PUBLIC
		Eigen3::Eigen)
  
target_link_libraries(lm_algo 
    PUBLIC     	
        lm_algo_CUDA 
        base_algo)
