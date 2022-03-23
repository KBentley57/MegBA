add_library(base_edge)

target_sources(base_edge
    PRIVATE
        base_edge.cpp)

add_library(base_edge_CUDA)

target_sources(base_edge_CUDA
    PRIVATE
        base_edge.cu)

add_library(update_CUDA)

target_sources(update_CUDA 
    PRIVATE
        update.cu)

add_library(build_linear_system)

target_sources(build_linear_system
    PRIVATE
        build_linear_system.cu)

target_link_libraries(base_edge 
    PUBLIC
        base_edge_CUDA 
        update_CUDA 
        build_linear_system)