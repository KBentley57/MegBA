
add_library(jet_vector)

target_sources(jet_vector
	PRIVATE
		jet_vector.cpp)
		
target_include_directories(jet_vector
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>)
				
add_library(jet_vector_CUDA)

target_sources(jet_vector_CUDA
	PRIVATE
		jet_vector.cu)
		
target_include_directories(jet_vector_CUDA
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_link_libraries(jet_vector_CUDA
	PUBLIC
		Eigen3::Eigen)

add_library(jet_vector_math_impl_CPU)

target_sources(jet_vector_math_impl_CPU
	PRIVATE
		jet_vector_math_impl.cpp)
		
target_include_directories(jet_vector_math_impl_CPU
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
		
target_link_libraries(jet_vector_math_impl_CPU
	PUBLIC
		Eigen3::Eigen)
		
add_library(jet_vector_math_impl_CUDA)

target_sources(jet_vector_math_impl_CUDA
	PRIVATE
		jet_vector_math_impl.cu)
		
target_include_directories(jet_vector_math_impl_CUDA
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)

target_link_libraries(jet_vector_math_impl_CUDA
	PUBLIC
		Eigen3::Eigen)


target_link_libraries(jet_vector
	PUBLIC
		jet_vector_CUDA 
		jet_vector_math_impl_CPU 
		jet_vector_math_impl_CUDA)
