#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

host=${1:-"127.0.0.1"}

neps=3
echo "Starting $neps endpoints..."
for i in `seq 1 $neps`; do
  port=$((9090 + i))
  echo "Starting ep $i on port $port"
  ssh $host $sbin/../common/start-confluo.sh $port &
done
wait
echo "Done starting up endpoints"

echo "Loading trace @ ep 1 on port $port with tcp schema (1)"
ssh $host $sbin/../common/load-trace.sh $sbin/tcp_schema1.txt\
  $sbin/traces/flow1 127.0.0.1 9091 &
echo "Loading trace @ ep 2 on port $port with udp schema"
ssh $host $sbin/../common/load-trace.sh $sbin/udp_schema.txt\
  $sbin/traces/flow2 127.0.0.1 9092 &
echo "Loading trace @ ep 3 on port $port with tcp schema (2)"
ssh $host $sbin/../common/load-trace.sh $sbin/tcp_schema2.txt\
  $sbin/traces/flow3 127.0.0.1 9093 &
wait
echo "Done loading traces on endpoints"
