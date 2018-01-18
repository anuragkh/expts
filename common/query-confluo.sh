#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

ep_list=${1:-"eps.txt"}

IFS=$'\r\n' GLOBIGNORE='*' command eval "EPS=($(cat $ep_list))"
echo "Endpoints: ${EPS[@]}"

$sbin/query-confluo/build/bin/query_confluo ${EPS[@]}
