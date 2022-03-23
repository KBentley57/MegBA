
add_library(geo)

target_sources(geo
    PRIVATE 
        angle_axis.cu 
        distortion.cu 
        rotation2D.cu 
        analytical_derivatives.cu)
