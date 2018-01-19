#include <cstdlib>
#include <cstdio>
#include <string>
#include <fstream>
#include <streambuf>

#include "rpc_client.h"
#include "string_utils.h"
#include "time_utils.h"

void print_usage(char* exec) {
  fprintf(stderr, "Usage: %s [end-points]\n", exec);
}

struct endpoint {
  std::string host;
  int port;
  std::string trace;
};

void connect_all(std::vector<confluo::rpc::rpc_client>& clients,
                 const std::vector<endpoint>& eps) {
  std::vector<std::thread> workers;
  for (size_t i = 0; i < eps.size(); i++) {
    workers.push_back(std::thread([i, &eps, &clients]() {
      clients[i].connect(eps[i].host, eps[i].port);
      clients[i].set_current_atomic_multilog(eps[i].trace);
    }));
  }

  for (size_t i = 0; i < eps.size(); i++) {
    workers[i].join();
  }
}

void snapshot_all(std::vector<uint64_t>& snap,
                  std::vector<confluo::rpc::rpc_client>& clients) {
  std::vector<std::thread> workers;
  for (size_t i = 0; i < clients.size(); i++) {
    workers.push_back(std::thread([i, &clients, &snap]() {
      snap[i] = clients[i].num_records();
    }));
  }

  for (size_t i = 0; i < clients.size(); i++) {
    workers[i].join();
  }
}

void query_all(std::vector<bool>& res, const std::string& filter_expr,
               std::vector<confluo::rpc::rpc_client>& clients) {
  std::vector<std::thread> workers;
  for (size_t i = 0; i < clients.size(); i++) {
    workers.push_back(std::thread([i, filter_expr, &res, &clients]() {
      res[i] = clients[i].execute_filter(filter_expr).has_more();
    }));
  }

  for (size_t i = 0; i < clients.size(); i++) {
    workers[i].join();
  }
}

void disconnect_all(std::vector<confluo::rpc::rpc_client>& clients) {
  for (auto& client : clients) {
    client.disconnect();
  }
}

int main(int argc, char** argv) {
  if (argc == 1) {
    fprintf(stderr, "Must specify at least one end-point\n");
    print_usage(argv[0]);
    return -1;
  }

  int num_eps = argc - 1;
  std::vector<endpoint> eps(num_eps);
  for (int i = 1; i < argc; i++) {
    auto splits = utils::string_utils::split(std::string(argv[i]), ':');
    if (splits.size() != 3) {
      fprintf(stderr, "Malformed endpoint: %s\n", argv[i]);
      print_usage(argv[0]);
      return -1;
    }
    eps[i - 1].host = splits[0];
    try {
      eps[i - 1].port = std::stoi(splits[1]);
    } catch (std::exception& e) {
      fprintf(stderr, "Malformed endpoint: %s (%s)\n", argv[i], e.what());
      print_usage(argv[0]);
      return -1;
    }
    eps[i - 1].trace = splits[2];
  }

  std::vector<confluo::rpc::rpc_client> clients(eps.size());
  std::vector<uint64_t> snap(eps.size());
  std::vector<bool> res(eps.size());
  while (true) {
    std::string query_str;
    std::getline(std::cin, query_str);
    auto query_parts = utils::string_utils::split(query_str, ',');
    std::string aggregate_expr = query_parts[0];
    std::string filter_expr = query_parts[1];

    // Setup connections
    auto ct1 = utils::time_utils::cur_us();
    connect_all(clients, eps);
    auto ct2 = utils::time_utils::cur_us();

    // Emulate snapshot algorithm
    auto st1 = utils::time_utils::cur_us();
    snapshot_all(snap, clients);
    auto st2 = utils::time_utils::cur_us();

    // Execute query
    auto qt1 = utils::time_utils::cur_us();
    query_all(res, filter_expr, clients);
    auto qt2 = utils::time_utils::cur_us();

    // Breakdown connections
    disconnect_all(clients);

    auto ct = (ct2 - ct1);
    auto st = (st2 - st1);
    auto qt = (qt2 - qt1);
    auto tot = ct + st + qt;
    fprintf(stderr, "Query time: %llu us (%llu us + %llu us + %llu us)\n", tot,
            ct, st, qt);
    fprintf(stderr, "Result vector: ");
    for (auto r : res) {
      fprintf(stderr, " %u ", r);
    }
    fprintf(stderr, "\n");
  }

  return 0;
}
