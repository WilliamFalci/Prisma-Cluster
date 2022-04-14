#!/bin/bash
source ../../../../CLI/env/.env
source ../../env/.env.replication

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat < ../tables); do
  ./single-subscription.sh $i
done