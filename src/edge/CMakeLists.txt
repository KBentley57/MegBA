add_library(base_edge)

target_sources(base_edge
    PRIVATE
        base_edge.cpp)
        
target_include_directories(base_edge
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>)

add_library(base_edge_CUDA)

target_sources(base_edge_CUDA
    PRIVATE
        base_edge.cu)
        
target_include_directories(base_edge_CUDA
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_link_libraries(base_edge_CUDA
	PUBLIC
		Eigen3::Eigen)

add_library(update_CUDA)

target_sources(update_CUDA 
    PRIVATE
        update.cu)
        
target_include_directories(update_CUDA
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_link_libraries(update_CUDA
	PUBLIC
		Eigen3::Eigen)

add_library(build_linear_system)

target_sources(build_linear_system
    PRIVATE
        build_linear_system.cu)
        
target_include_directories(build_linear_system
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_link_libraries(build_linear_system
	PUBLIC
		Eigen3::Eigen)

target_link_libraries(base_edge 
    PUBLIC
		OpenMP::OpenMP_CXX
        base_edge_CUDA 
        update_CUDA 
        build_linear_system)
