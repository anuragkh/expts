#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

expt=${1:-"priority"}
controller=${2:-"localhost"}
host=${3:-"localhost"}
nudp=${4:-"8"}

nhosts=$((nudp + 1))
echo "Starting $nhosts endpoints..."
for i in `seq 1 $nhosts`; do
  port=$((9090 + i))
  echo "Starting ep $i on port $port"
  ssh $host $sbin/../common/start-confluo.sh $port &
done
wait
echo "Done starting up endpoints"

echo "Loading traces on endpoints..."
for i in `seq 1 $nhosts`; do
  port=$((9090 + i))
  echo "Loading trace @ ep $i on port $port"
  if [ $i == "1" ]; then
    ssh $host $sbin/../common/load-trace.sh $sbin/tcp_schema.txt\
      $sbin/$expt/traces/flow${i} localhost $port&
  else
    ssh $host $sbin/../common/load-trace.sh $sbin/udp_schema.txt\
      $sbin/$expt/traces/flow${i} localhost $port&
  fi
done
wait
echo "Done loading traces on endpoints"
