#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

host=${1:-"127.0.0.1"}

$sbin/../common/teardown.sh $host

$sbin/setup.sh $host

# Warmup
for i in {1..10}; do
  $sbin/../common/query-confluo.sh $sbin/queries.txt 1>>/dev/null 2>>/dev/null
done

# Actual runs
for i in {1..10}; do
  $sbin/../common/query-confluo.sh $sbin/queries.txt 1>>results.txt 2>>log.stderr
done

$sbin/../common/teardown.sh $host
