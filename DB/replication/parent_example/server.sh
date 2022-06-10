#!/bin/bash

if [ $1 == "replication" ]; then
  shift
  command="$@"
  CURRENT_UID=$(id -u):$(id -g) docker-compose --env-file ./xxxx/postgres/replication/.replication.env -f dev-replication.yml $command
else
  command="$*"
  CURRENT_UID=$(id -u):$(id -g) docker-compose -f dev.yml $command
fi
