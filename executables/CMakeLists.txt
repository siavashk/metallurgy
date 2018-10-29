project(metallurgycl)

set(METAL_SHADERS
    ${CMAKE_SOURCE_DIR}/metallurgy/shaders.metal
)

set_source_files_properties(
    ${METAL_SHADERS}
    PROPERTIES
    LANGUAGE
    METAL
)

set_source_files_properties(
    ${METAL_SHADERS}
    PROPERTIES
    MACOSX_PACKAGE_LOCATION
    Resources
)

add_executable(metallurgycl MACOSX_BUNDLE main.cpp ${METAL_SHADERS})

target_include_directories(metallurgycl PRIVATE ${CMAKE_SOURCE_DIR}/metallurgy)

target_link_libraries(metallurgycl metallurgy)

cotire(metallurgycl)
