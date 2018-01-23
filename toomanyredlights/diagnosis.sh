#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

$sbin/../common/query-confluo.sh $sbin/queries.txt 1>>results.txt 2>>log.stderr
