cmake_minimum_required(VERSION 3.16.1)

set(PROJECT_NAME selfsim)

project(${PROJECT_NAME} LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)

set(PROJECT_ROOT ${CMAKE_SOURCE_DIR})
set(PROJECT_BIN "${PROJECT_ROOT}/bin")

# trapper

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

file(DOWNLOAD https://raw.githubusercontent.com/kabukunz/trapper/main/Trapper.cmake "${CMAKE_MODULE_PATH}/Trapper.cmake")

include(Trapper)

# libigl

# build libigl as a static library, if OFF use it as header-only library    
set(LIBIGL_USE_STATIC_LIBRARY OFF CACHE BOOL "" FORCE)
set(LIBIGL_USE_PREBUILT_LIBRARIES OFF CACHE BOOL "" FORCE)


option(LIBIGL_WITH_ANTTWEAKBAR       "Use AntTweakBar"                  OFF)
option(LIBIGL_WITH_CGAL              "Use CGAL"                         OFF)
option(LIBIGL_WITH_COMISO            "Use CoMiso"                       OFF)
option(LIBIGL_WITH_CORK              "Use Cork"                         OFF)
option(LIBIGL_WITH_TETGEN            "Use Tetgen"                       OFF)
option(LIBIGL_WITH_LIM               "Use LIM"                          OFF)
option(LIBIGL_WITH_MATLAB            "Use Matlab"                       OFF)
option(LIBIGL_WITH_MOSEK             "Use MOSEK"                        OFF)
option(LIBIGL_WITH_EMBREE            "Use Embree"                       OFF)
option(LIBIGL_WITH_VIEWER            "Use OpenGL viewer"                ON)
option(LIBIGL_WITH_OPENGL            "Use OpenGL"                       ON)
option(LIBIGL_WITH_OPENGL_GLFW       "Use GLFW"                         ON)
option(LIBIGL_WITH_OPENGL_GLFW_IMGUI "Use ImGui"                        ON)
option(LIBIGL_WITH_PYTHON            "Use Python"                       OFF)
option(LIBIGL_WITH_TRIANGLE          "Use Triangle"                     OFF)
option(LIBIGL_WITH_MMG               "Use Mmg"                          OFF)
option(LIBIGL_WITH_PREDICATES        "Use exact predicates"             ON)
option(LIBIGL_WITH_XML               "Use XML"                          ON)
option(LIBIGL_WITH_PNG               "Use PNG"                          OFF)


trapper_add_package(
    libigl
    https://github.com/kabukunz/libigl.git
    5749e43a6862a88a61d5a82cb478e595e0cd65b3
    
    HEADER_ONLY
    VERBOSE

    SOURCE_DIR "${CMAKE_SOURCE_DIR}/dep"
    )

# set nanoflann dir
set(libigl_DIR ${TRAPPER_SOURCE_DIR} CACHE STRING "libigl DIR")

message(WARNING "libigl_DIR: ${libigl_DIR}")

# set nanoflann include dir (with no target)
add_subdirectory(${libigl_DIR})
include_directories("${libigl_DIR}/include")
include_directories("${libigl_DIR}/include/igl/opengl/glfw/imgui")
include_directories("${libigl_DIR}/external/glad/include")
include_directories("${libigl_DIR}/external/glfw/include")
include_directories("${libigl_DIR}/external/imgui")



# eigen
set(eigen_DIR "${libigl_DIR}/external/eigen")
include_directories(${PROJECT_NAME} PUBLIC ${eigen_DIR})



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
