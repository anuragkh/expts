#!/usr/bin/env bash

port=${1:-"9090"}
confluo_path=${2:-"/data/anuragk/confluo"}

host="localhost"
bind_addr="0.0.0.0"

mkdir -p $confluo_path/log/stderr $confluo_path/log/stdout $confluo_path/data

nohup $confluo_path/build/bin/confluod --address=$bind_addr --port $port\
    --data-path=$confluo_path/data/${host}_${port}\
    2>$confluo_path/log/stderr/${host}_${port}.stderr\
    1>$confluo_path/log/stdout/${host}_${port}.stdout &
