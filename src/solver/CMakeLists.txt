
add_library(schur_pcg_solver)

target_sources(schur_pcg_solver
	PRIVATE
		schur_pcg_solver.cpp)
		
target_include_directories(schur_pcg_solver
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>)
        
target_link_libraries(schur_pcg_solver
	PUBLIC
		Eigen3::Eigen)
		
add_library(schur_pcg_solver_CUDA)

target_sources(schur_pcg_solver_CUDA
	PRIVATE
		schur_pcg_solver.cu)

target_include_directories(schur_pcg_solver_CUDA
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_link_libraries(schur_pcg_solver 
	PUBLIC
		schur_pcg_solver_CUDA)
		
target_link_libraries(schur_pcg_solver_CUDA 
	PUBLIC
		Eigen3::Eigen
		CUDA::toolkit
		CUDA::cusparse
		CUDA::cublas 
		nccl)
		
target_link_directories(schur_pcg_solver_CUDA
	PUBLIC
		${NCCL_LIB_DIR})
