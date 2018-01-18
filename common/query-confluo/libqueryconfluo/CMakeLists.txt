set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})

find_package(Threads REQUIRED)

add_executable(query_confluo src/query_confluo.cc)
target_link_libraries(query_confluo thrift rpcclient ${CMAKE_THREAD_LIBS_INIT})
add_dependencies(query_confluo rpcclient thrift)
