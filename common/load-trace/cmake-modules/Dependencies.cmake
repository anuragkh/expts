include(ExternalProject)

set(CONFLUO_INSTALL_DIR ${CMAKE_BINARY_DIR}/confluo)
set(GIT_TAG "single-machine" CACHE STRING "GitHub branch/tag to build")

ExternalProject_Add(confluo
    GIT_REPOSITORY https://github.com/ucbrise/confluo.git
    GIT_TAG ${GIT_TAG}
    INSTALL_DIR ${CONFLUO_INSTALL_DIR}
    CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>"
               "-DBUILD_RPC=ON"
               "-DWITH_PY_CLIENT=OFF"
               "-DWITH_JAVA_CLIENT=OFF"
               "-DBUILD_TESTS=OFF"
               "-DBUILD_DOC=OFF"
               "-DBUILD_EXAMPLES=OFF"
)

set(CONFLUO_INCLUDE_DIR "${CONFLUO_INSTALL_DIR}/include")
set(CONFLUO_LIB_DIR "${CONFLUO_INSTALL_DIR}/lib")
include_directories(${CONFLUO_INCLUDE_DIR})
link_directories(${CONFLUO_LIB_DIR})

set(THRIFT_LIB_NAME "${CMAKE_STATIC_LIBRARY_PREFIX}thrift${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(CONFLUO_LIB_NAME "${CMAKE_STATIC_LIBRARY_PREFIX}rpcclient${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(THRIFT_LIB ${CONFLUO_LIB_DIR}/${THRIFT_LIB_NAME})
set(CONFLUO_LIB ${CONFLUO_LIB_DIR}/${CONFLUO_LIB_NAME})

add_library(thrift STATIC IMPORTED GLOBAL)
set_target_properties(thrift PROPERTIES IMPORTED_LOCATION ${THRIFT_LIB})
add_library(rpcclient STATIC IMPORTED GLOBAL)
set_target_properties(rpcclient PROPERTIES IMPORTED_LOCATION ${CONFLUO_LIB})

message(STATUS "Confluo lib: ${CONFLUO_LIB}")
message(STATUS "Thrift lib: ${THRIFT_LIB}")
