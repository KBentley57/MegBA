
add_library(base_problem)

target_sources(base_problem
	PRIVATE
		base_problem.cpp)
		
target_include_directories(base_problem
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>)
		
add_library(base_problem_CUDA SHARED)

target_sources(base_problem_CUDA
	PRIVATE
		base_problem.cu)				
		
target_include_directories(base_problem_CUDA
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_link_libraries(base_problem_CUDA 
	PUBLIC
		Eigen3::Eigen)
		
target_link_libraries(base_problem 
	PUBLIC
		CUDA::toolkit
		CUDA::cudart
		Eigen3::Eigen
		base_problem_CUDA 
		resource)
