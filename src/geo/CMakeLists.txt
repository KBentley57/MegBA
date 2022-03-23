
add_library(geo)

target_sources(geo
    PRIVATE 
        angle_axis.cu 
        distortion.cu 
        rotation2D.cu 
        analytical_derivatives.cu)
        
target_compile_options(geo
	PRIVATE
		$<$<BUILD_INTERFACE:$<COMPILE_LANGUAGE:CUDA>>:--extended-lambda --expt-relaxed-constexpr>)
		
set_target_properties(geo
	PROPERTIES
		CUDA_SEPARABLE_COMPILATION ON)	
        
target_include_directories(geo
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
		$<BUILD_INTERFACE:${NCCL_INCLUDE_DIR}>)
        
target_link_libraries(geo
	PUBLIC
		Eigen3::Eigen)
        

