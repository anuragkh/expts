#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

controller=${1:-"localhost"}
host=${2:-"localhost"}
nudp=${3:-"8"}
confluo_path=${4:-"/data/anuragk/confluo"}

ssh $host mkdir -p $confluo_path/log/stderr $confluo_path/log/stdout $confluo_path/data

nhosts=$((nudp + 1))
echo "Starting $nhosts endpoints..."
for i in `seq 1 $nhosts`; do
  echo "Starting ep $i on port $port"
  ssh $host $sbin/start-confluo.sh $i &
done
wait

echo "Done starting up endpoints"
echo "Loading data on endpoints..."
load_trace="$sbin/../load-trace"

