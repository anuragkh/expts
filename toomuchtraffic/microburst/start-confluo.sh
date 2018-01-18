#!/usr/bin/env bash

epid=${1:-"1"}
confluo_path=${2:-"/data/anuragk/confluo"}

port=$((9090 + $epid))
nohup $confluo_path/build/bin/confluod --address=0.0.0.0 --port $port\
    --data-path=$confluo_path/data/host_$i 2>$confluo_path/log/stderr/host_$i.stderr\
    1>$confluo_path/log/stdout/host_$1.stdout &
