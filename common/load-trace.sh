#!/usr/bin/env bash

sbin="`dirname "$0"`"
sbin="`cd "$sbin"; pwd`"

schema=${1:-"schema.txt"}
trace=${2:-"trace/flow1"}
host=${3:-"localhost"}
port=${4:-"9090"}

ltrace_path="$sbin/load-trace"
ltrace_bin="$ltrace_path/build/bin"
ltrace=$ltrace_bin/load_trace

mkdir -p $ltrace_path/log/stderr $ltrace_path/log/stdout

$ltrace $schema $trace $host $port\
  2> $ltrace_path/log/stderr/${host}_${port}.stderr\
  1> $ltrace_path/log/stdout/${host}_${port}.stdout
