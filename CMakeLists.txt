cmake_minimum_required(VERSION 3.16.1)

set(PROJECT_NAME selfsim)

project(${PROJECT_NAME} LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)

set(PROJECT_ROOT ${CMAKE_SOURCE_DIR})
set(PROJECT_BIN "${PROJECT_ROOT}/bin")

# # trapper

# list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# file(DOWNLOAD https://raw.githubusercontent.com/kabukunz/trapper/main/Trapper.cmake "${CMAKE_MODULE_PATH}/Trapper.cmake")

# include(Trapper)

# # libigl

# trapper_add_package(
#     libigl
#     https://github.com/kabukunz/libigl.git
#     5749e43a6862a88a61d5a82cb478e595e0cd65b3
    
#     HEADER_ONLY
#     VERBOSE

#     SOURCE_DIR "${CMAKE_SOURCE_DIR}/dep"
#     )

# set nanoflann dir
set(libigl_DIR ${CMAKE_SOURCE_DIR}/include/libigl CACHE STRING "libigl DIR")

# set nanoflann include dir (with no target)
include_directories(${PROJECT_NAME} PUBLIC "${libigl_DIR}/include")
include_directories(${PROJECT_NAME} PUBLIC "${libigl_DIR}/include/igl/opengl/glfw/imgui")

# eigen
set(eigen_DIR "${libigl_DIR}/external/eigen")
include_directories(${eigen_DIR})



# # libigl
# set(libigl_DIR "${PROJECT_ROOT}/include/libigl")
# add_subdirectory(${libigl_DIR})

# # eigen
# set(eigen_DIR "${libigl_DIR}/external/eigen")





# include_directories(${libigl_DIR}/external/glad)
file(GLOB_RECURSE HEADERS_INC1 ${CMAKE_CURRENT_SOURCE_DIR}/include/cpp-spline/*.h)
# file(GLOB_RECURSE SOURCES_INC1 ${CMAKE_CURRENT_SOURCE_DIR}/include/cpp-spline/*.cpp)
file(GLOB_RECURSE HEADERS_INC2 ${CMAKE_CURRENT_SOURCE_DIR}/include/sqlite/*.h)
# file(GLOB_RECURSE SOURCES_INC2 ${CMAKE_CURRENT_SOURCE_DIR}/include/sqlite/*.cpp)

file(GLOB_RECURSE HEADERS src/*.h)
file(GLOB_RECURSE SOURCES src/*.cpp)

set(MAIN src/nd_descriptor.cpp)

add_executable(${PROJECT_NAME} ${SOURCES} ${SOURCES_INC1} ${SOURCES_INC2} ${MAIN})

target_include_directories(${PROJECT_NAME} PUBLIC src include)
# target_include_directories(${PROJECT_NAME} PUBLIC ${eigen_DIR})
# target_include_directories(${PROJECT_NAME} PUBLIC ${libigl_DIR}/include)

set_target_properties(${PROJECT_NAME} 
    PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BIN})
