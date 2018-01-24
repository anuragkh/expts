#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

host=${1:-"localhost"}
nudp="2"

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
  if [ $i == "1" ]; then
    echo "Loading trace @ ep $i on port $port with tcp schema"
    ssh $host $sbin/../common/load-trace.sh $sbin/tcp_schema.txt\
      $sbin/traces/flow${i} localhost $port&
  else
    echo "Loading trace @ ep $i on port $port with udp schema"
    ssh $host $sbin/../common/load-trace.sh $sbin/udp_schema.txt\
      $sbin/traces/flow${i} localhost $port&
  fi
done
wait
echo "Done loading traces on endpoints"
