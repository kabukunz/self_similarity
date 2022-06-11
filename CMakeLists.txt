cmake_minimum_required(VERSION 3.16.1)

set(PROJECT_NAME selfsim)

project(${PROJECT_NAME} LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 14)

set(PROJECT_ROOT ${CMAKE_SOURCE_DIR})
set(PROJECT_BIN "${PROJECT_ROOT}/bin")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# trapper
set(TRAPPER_FILE "${CMAKE_MODULE_PATH}/Trapper.cmake")
if(NOT EXISTS ${TRAPPER_FILE})
    file(DOWNLOAD https://raw.githubusercontent.com/kabukunz/trapper/main/Trapper.cmake ${TRAPPER_FILE})
endif()
include(${TRAPPER_FILE})

# libigl

# build libigl as a static library, if OFF use it as header-only library    
set(LIBIGL_USE_STATIC_LIBRARY ON CACHE BOOL "" FORCE)


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
option(LIBIGL_WITH_TRIANGLE          "Use Triangle"                     ON)
# option(LIBIGL_WITH_MMG               "Use Mmg"                          OFF)
option(LIBIGL_WITH_PREDICATES        "Use exact predicates"             ON)
option(LIBIGL_WITH_XML               "Use XML"                          ON)
option(LIBIGL_WITH_PNG               "Use PNG"                          OFF)


# trapper_add_package(
#     libigl
#     https://github.com/libigl/libigl.git
#     v2.1.0
    
#     HEADER_ONLY
#     VERBOSE

#     SOURCE_DIR "${CMAKE_SOURCE_DIR}/dep"
#     )

# set nanoflann dir
# set(libigl_DIR ${TRAPPER_SOURCE_DIR} CACHE STRING "libigl DIR")
set(libigl_DIR "${CMAKE_SOURCE_DIR}/include/libigl" CACHE STRING "libigl DIR" FORCE)

message(WARNING "libigl_DIR: ${libigl_DIR}")

# set nanoflann include dir (with no target)
# add_subdirectory(${libigl_DIR})
include_directories("${libigl_DIR}/include")
# include_directories("${libigl_DIR}/include/igl/opengl/glfw/imgui")
include_directories("${libigl_DIR}/external/glad/include")
include_directories("${libigl_DIR}/external/glfw/include")
include_directories("${libigl_DIR}/external/imgui")
include_directories("${libigl_DIR}/external/libigl-imgui")
include_directories("${libigl_DIR}/external")



# this is not in libigl, there's a version mismatch
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include/libigl/external/imgui/examples")



# eigen
set(eigen_DIR "${libigl_DIR}/external/eigen")
include_directories(${PROJECT_NAME} PUBLIC ${eigen_DIR})



# # libigl
# set(libigl_DIR "${PROJECT_ROOT}/include/libigl")
# add_subdirectory(${libigl_DIR})

# # eigen
# set(eigen_DIR "${libigl_DIR}/external/eigen")

# find_package(OpenMP REQUIRED)
set (OpenMP_INCLUDES "/usr/local/opt/libomp/include")
set (OpenMP_omp_LIBRARY "/usr/local/opt/libomp/lib/libomp.dylib")

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message("-- Setting OpenMP flags on MacOs. Assuming `brew install libomp`")
    if(CMAKE_C_COMPILER_ID MATCHES "Clang\$")
        set(OpenMP_C_FLAGS "-Xpreprocessor -fopenmp -I${OpenMP_INCLUDES}" CACHE INTERNAL "OpenMP flags for Xcode toolchain.")
        set(OpenMP_C_LIB_NAMES "omp" CACHE INTERNAL "OpenMP lib name for Xcode toolchain.")
        set(OpenMP_omp_LIBRARY ${OpenMP_omp_LIBRARY} CACHE INTERNAL "OpenMP lib name for Xcode toolchain.")
    endif()

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang\$")
        set(OpenMP_CXX_FLAGS "-Xpreprocessor -fopenmp -I${OpenMP_INCLUDES}" CACHE INTERNAL "OpenMP flags for Xcode toolchain.")
        set(OpenMP_CXX_LIB_NAMES "omp" CACHE INTERNAL "OpenMP lib name for Xcode toolchain.")
        set(OpenMP_omp_LIBRARY ${OpenMP_omp_LIBRARY} CACHE INTERNAL "OpenMP lib name for Xcode toolchain.")
    endif()
endif()


# if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")

#     if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
#         set(OpenMP_C_FLAGS "-Xpreprocessor -fopenmp")
#         set(OpenMP_C_LIB_NAMES "omp")
#         set(OpenMP_omp_LIBRARY omp)
#     endif()

#     if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
#         set(OpenMP_CXX_FLAGS "-Xpreprocessor -fopenmp")
#         set(OpenMP_CXX_LIB_NAMES "omp")
#         set(OpenMP_omp_LIBRARY omp)
#     endif()

# endif()

# find_package(OpenMP REQUIRED)

# add_executable(helloworld helloworld.cxx)
# target_link_libraries(helloworld PRIVATE OpenMP::OpenMP_CXX)

# include_directories(${libigl_DIR}/external/glad)
# file(GLOB_RECURSE HEADERS_INC ${CMAKE_CURRENT_SOURCE_DIR}/include/cpp-spline/*.h)
# list(APPEND HEADERS_INCLUDE ${HEADERS_INC})
# file(GLOB_RECURSE HEADERS_INC ${CMAKE_CURRENT_SOURCE_DIR}/include/sqlite/*.h)
# list(APPEND HEADERS_INCLUDE ${HEADERS_INC})
# file(GLOB_RECURSE HEADERS_INC ${CMAKE_CURRENT_SOURCE_DIR}/include/ctpl/*.h)
# list(APPEND HEADERS_INCLUDE ${HEADERS_INC})
# file(GLOB_RECURSE HEADERS_INC ${CMAKE_CURRENT_SOURCE_DIR}/include/nvidia/*.h)
# list(APPEND HEADERS_INCLUDE ${HEADERS_INC})
# file(GLOB_RECURSE HEADERS_INC ${OpenMP_INCLUDES})
# list(APPEND HEADERS_INCLUDE ${HEADERS_INC})


set(SOURCES 
src/nd_descriptor.cpp
src/matching/spherical_threshold.cpp
src/matching/stroke_transfer.cpp
# src/matching/parameterization/moebius_registration.cpp
src/matching/parameterization/discrete_exponential_map.cpp
src/matching/parameterization/curve_unrolling.cpp
src/matching/parameterization/pt_unfolding.cpp
src/matching/desire_set.cpp
src/matching/quadratic_bump.cpp
src/matching/threshold.cpp
src/matching/constrained_relation_solver.cpp
src/matching/self_similarity/self_similarity_map.cpp
src/matching/surface_stroke.cpp
src/matching/geodesic_fan.cpp
# src/unit_tests/stroke_transfer/test_stroke_transfer.cpp
src/experiments/stroke_transfer_exp.cpp
src/algorithms/shortest_path.cpp
src/shape_signatures/wave_kernel_signature.cpp
src/shape_signatures/shape_diameter_signature.cpp
src/shape_signatures/texture_signature.cpp
src/shape_signatures/hks.cpp
src/shape_signatures/spectral_signature.cpp
src/shape_signatures/heat_kernel_signature.cpp
src/shape_signatures/shape_signature.cpp
# src/utilities/ocl/oclUtils.cpp
# src/utilities/ocl/cmd_arg_reader.cpp
# src/utilities/ocl/shrUtils.cpp
src/utilities/multithreading.cpp
src/attributes/transfer/meshmatch.cpp
src/benchmarks/model_manifest.cpp
src/benchmarks/eigen_decomp.cpp
src/gui/control_display.cpp
src/geometry/geometry.cpp
src/geometry/mesh.cpp
src/geometry/segmentation/surface_by_numbers.cpp
src/geometry/segmentation/spectral_clustering.cpp
src/geometry/patch.cpp
src/geometry/component.cpp
src/geometry/tests/intersection.cpp
)

message(WARNING ${SOURCES})


# file(GLOB_RECURSE HEADERS src/*.h)
# file(GLOB_RECURSE SOURCES src/*.cpp)

set(HEADERS 
src/matching/desire_set.h
src/matching/constrained_relation_solver.h
src/matching/parameterization/discrete_exponential_map.h
src/matching/parameterization/curve_unrolling.h
# src/matching/parameterization/moebius_registration.h
src/matching/parameterization/pt_unfolding.h
src/matching/quadratic_bump.h
src/matching/threshold.h
src/matching/surface_stroke.h
src/matching/stroke_transfer.h
src/matching/geodesic_fan.h
src/matching/spherical_threshold.h
src/matching/self_similarity/self_similarity_map.h
# src/unit_tests/unit_tests.h
# src/unit_tests/stroke_transfer/test_stroke_transfer.h
src/experiments/stroke_transfer_exp.h
src/algorithms/shortest_path.h
src/shape_signatures/texture_signature.h
src/shape_signatures/hks.h
src/shape_signatures/spectral_signature.h
src/shape_signatures/shape_diameter_signature.h
src/shape_signatures/heat_kernel_signature.h
src/shape_signatures/shape_signature.h
src/shape_signatures/wave_kernel_signature.h
src/utilities/multithreading.h
src/utilities/eigen_read_write_binary.h
src/utilities/gen_id.h
src/utilities/timer.h
src/utilities/units.h
src/attributes/transfer/meshmatch.h
src/benchmarks/eigen_decomp.h
src/benchmarks/model_manifest.h
src/gui/control_display.h
src/geometry/segmentation/surface_by_numbers.h
src/geometry/segmentation/spectral_clustering.h
src/geometry/tests/intersection.h
src/geometry/mesh.h
src/geometry/patch.h
src/geometry/component.h
src/geometry/geometry.h
)

message(WARNING ${HEADERS})

set(MAIN src/nd_descriptor.cpp)

add_executable(${PROJECT_NAME} ${SOURCES} ${MAIN})

target_include_directories(${PROJECT_NAME} PUBLIC src include)
# target_include_directories(${PROJECT_NAME} PUBLIC ${eigen_DIR})
# target_include_directories(${PROJECT_NAME} PUBLIC ${libigl_DIR}/include)

target_include_directories(${PROJECT_NAME} PUBLIC "${OpenMP_INCLUDES}")
target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include/ctpl")
target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include/mobreg/include")
target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include/cpp-spline/spline/src/main/cpp")

target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include/nvidia")

# target_link_libraries(${PROJECT_NAME} igl::opengl_glfw)

set_target_properties(${PROJECT_NAME} 
    PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BIN})

