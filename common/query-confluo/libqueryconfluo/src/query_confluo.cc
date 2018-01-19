#include <cstdlib>
#include <cstdio>
#include <string>
#include <fstream>
#include <streambuf>

#include "rpc_client.h"
#include "string_utils.h"
#include "time_utils.h"

void print_usage(char* exec) {
  fprintf(stderr, "Usage: %s [end-points] [query]\n", exec);
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
  if (argc != 3) {
    fprintf(stderr, "Must specify at least one end-point\n");
    print_usage(argv[0]);
    return -1;
  }

  std::vector<endpoint> eps;
  std::ifstream epfile(argv[1]);
  std::string query = argv[2];
  std::string ep_str;
  while (std::getline(epfile, ep_str)) {
    auto splits = utils::string_utils::split(ep_str, ':');
    if (splits.size() != 3) {
      fprintf(stderr, "Malformed endpoint: %s\n", ep_str.c_str());
      print_usage(argv[0]);
      return -1;
    }
    endpoint ep;
    ep.host = splits[0];
    try {
      ep.port = std::stoi(splits[1]);
    } catch (std::exception& e) {
      fprintf(stderr, "Malformed endpoint: %s (%s)\n", ep_str.c_str(),
              e.what());
      print_usage(argv[0]);
      return -1;
    }
    ep.trace = splits[2];
    eps.push_back(ep);
  }

  std::vector<confluo::rpc::rpc_client> clients(eps.size());
  std::vector<uint64_t> snap(eps.size());
  std::vector<bool> res(eps.size());

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
  query_all(res, query, clients);
  auto qt2 = utils::time_utils::cur_us();

  // Breakdown connections
  disconnect_all(clients);

  auto ct = (ct2 - ct1);
  auto st = (st2 - st1);
  auto qt = (qt2 - qt1);
  auto t = ct + st + qt;
  std::cout << t << " " << ct << " " << st << " " << qt << "\n";
  for (auto r : res)
    std::cerr << " " << r << " ";
  std::cerr << "\n";

  return 0;
}
