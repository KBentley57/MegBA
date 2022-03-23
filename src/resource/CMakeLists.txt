add_library(resource)

target_sources(resource
	PRIVATE
		handle_manager.cpp 
		memory_pool.cu)
		
target_include_directories(resource
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_compile_options(resource
	PRIVATE
		$<$<BUILD_INTERFACE:$<COMPILE_LANGUAGE:CUDA>>:--extended-lambda>)
		
set_target_properties(resource
	PROPERTIES
		CUDA_SEPARABLE_COMPILATION ON)	
		
target_link_libraries(resource 
	PUBLIC
		CUDA::toolkit
		CUDA::cusparse
		CUDA::cublas)
