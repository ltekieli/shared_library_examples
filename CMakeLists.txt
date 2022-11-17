cmake_minimum_required(VERSION 3.22)
project(shlibs VERSION 0.1)

add_library(f2 f2/f2.cpp)
target_include_directories(f2
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)
set_target_properties(f2 PROPERTIES
    SOVERSION "${shlibs_VERSION_MAJOR}"
    VERSION "${shlibs_VERSION}"
)

add_library(f1 f1/f1.cpp)
target_link_libraries(f1
    PRIVATE
        f2
)
set_target_properties(f1 PROPERTIES
    SOVERSION "${shlibs_VERSION_MAJOR}"
    VERSION "${shlibs_VERSION}"
)

add_executable(main main.cpp)
target_link_libraries(main f1)
