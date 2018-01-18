#include <cstdlib>
#include <cstdio>
#include <string>
#include <fstream>
#include <streambuf>

#include "rpc_client.h"

int main(int argc, char** argv) {
  if (argc < 5) {
    fprintf(stderr, "Usage: %s [schema] [trace] [host] [port]\n",
            argv[0]);
    return -1;
  }

  std::string schema_file = argv[1];
  std::string trace_file = argv[2];
  std::string host = argv[3];
  int port = std::atoi(argv[4]);

  // Read schema from file
  fprintf(stderr, "Reading schema...\n");
  std::ifstream schema_in(schema_file);
  std::string schema((std::istreambuf_iterator<char>(schema_in)),
                         std::istreambuf_iterator<char>());
  schema_in.close();
  fprintf(stderr, "Read schema: [%s]\n", schema.c_str());

  // Read trace from file
  fprintf(stderr, "Reading trace...\n");
  std::ifstream trace_in(trace_file);
  trace_in.seekg(0, std::ios::end);
  size_t trace_bytes = trace_in.tellg();
  char* trace_buf = new char[trace_bytes];
  trace_in.seekg(0, std::ios::beg);
  trace_in.read(trace_buf, trace_bytes);
  trace_in.close();
  fprintf(stderr, "Read trace with %zu bytes\n", trace_bytes);

  // Load trace to Conlfuo
  fprintf(stderr, "Loading trace...\n");
  confluo::rpc::rpc_client client(host, port);
  client.create_atomic_multilog(trace_file, schema,
                                confluo::storage::storage_mode::IN_MEMORY);
  size_t pkt_size = client.current_schema().record_size();
  size_t num_pkts = trace_bytes / pkt_size;
  for (size_t i = 0; i < num_pkts; i++) {
    confluo::rpc::record_data rec(trace_buf + i * pkt_size, pkt_size);
    client.append(rec);
  }
  fprintf(stderr, "Finished loading %zu packets\n", num_pkts);

  return 0;
}
