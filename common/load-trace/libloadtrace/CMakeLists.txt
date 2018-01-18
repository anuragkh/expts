set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})

find_package(Threads REQUIRED)

add_executable(load_trace src/load_trace.cc)
target_link_libraries(load_trace thrift rpcclient ${CMAKE_THREAD_LIBS_INIT})
add_dependencies(load_trace rpcclient thrift)
