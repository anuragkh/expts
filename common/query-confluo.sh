#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

ep_list=${1:-"eps.txt"}
filter=${2:-""}
aggregate=${3:-""}

$sbin/query-confluo/build/bin/query_confluo $ep_list $filter $aggregate
