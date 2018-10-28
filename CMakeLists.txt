cmake_minimum_required(VERSION 2.8.8)

project(metallurgy)

set (CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake")

include(cotire)

set(CMAKE_CXX_FLAGS "-std=c++0x")
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} \
    -framework AppKit \
    -framework Metal \
    -framework MetalKit"
)

add_subdirectory(metallurgy)
add_subdirectory(executables)
