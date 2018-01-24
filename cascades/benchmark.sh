#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

host=${1:-"127.0.0.1"}

$sbin/../common/teardown.sh $host

$sbin/setup.sh $host

for qbatch in 1 2; do
  qfile=$sbin/queries${qbatch}.txt
  rfile=$sbin/results${qbatch}.txt
  lfile=$sbin/log${qbatch}.txt
  # Warmup
  for i in {1..10}; do
    $sbin/../common/query-confluo.sh $qfile 1>>/dev/null 2>>/dev/null
  done
  # Actual runs
  for i in {1..10}; do
    $sbin/../common/query-confluo.sh $qfile 1>>$rfile 2>>$lfile
  done
done

$sbin/../common/teardown.sh $host
