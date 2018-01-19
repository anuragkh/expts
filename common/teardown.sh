#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

host=${1:-"localhost"}

echo "Tearing down eps"
ssh $host $sbin/stop-confluo.sh 
echo "Done tearing down endpoints"
