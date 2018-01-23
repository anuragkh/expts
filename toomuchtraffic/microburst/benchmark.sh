#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

host=${1:-"localhost"}

function gen_queries() {
  host=$1
  nflows=$2
  rm -f queries.txt
  for ep in `seq 2 $nflows`; do
    port=$((9090 + ep))
    echo "$host:$port:flow${ep}:vlan1_tag==256&&vlan2_tag==36609:SUM(ipv4_total_length)" >> queries.txt
  done
}

$sbin/../../common/teardown.sh $host

for nudp in 1 2 4 8 16; do
  $sbin/../setup.sh microburst $host $nudp
  gen_queries $host $((nudp + 1))
  # Warmup runs
  for run in {1..10}; do
    $sbin/../diagnosis.sh queries.txt 
  done
  # Actual runs
  for run in {1..10}; do
    $sbin/../diagnosis.sh queries.txt
  done
  mv results.txt udp${nudp}.txt
  rm -f queries.txt
  $sbin/../../common/teardown.sh $host
done
