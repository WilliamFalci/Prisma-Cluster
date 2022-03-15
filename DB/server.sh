#!/bin/bash

if [ $1 == "replication" ]; then
  shift
  command="$@"
  docker-compose --env-file ../CLI/env/.env -f docker-compose.replication.yml $command
else
  command="$*"
  docker-compose --env-file ../CLI/env/.env $command
fi