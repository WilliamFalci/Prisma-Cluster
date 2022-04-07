#!/bin/bash

if [ -z "$1" ]; then
  printf '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

shift

if [ -z "$1" ]; then
  echo $(print_message -e 'true' -i 'end' -m 'DB' -s 'Argument #1' -c 'Invalid' -t 'Miss service name')
  exit
fi

if [ -z "$2" ]; then
  echo $(print_message -e 'true' -i 'end' -m 'DB' -s 'Argument #1' -c 'Invalid' -t 'Miss import file name')
  exit
fi

service=$1
import=$2

if [ -f "$DOCKER_DB_IMPORT_PATH/$2" ]; then
  echo $(print_message -i 'continue' -m 'DB' -s 'Import' -c "$import" -a 'Docker' -t 'File found... importing...')
  
  if [ "$service" == "master" ]; then
    user='master'
  else
    user=SERVICE_${1^^}_DB_USER
  fi

  cat $DOCKER_DB_IMPORT_PATH/$import | docker exec -i "${DOCKER_CONTAINER}" psql -U ${user} -d $service
  echo $(print_message -i 'end' -m 'DB' -s "$service" -c 'Import' -a "$import" -t 'Imported')
else
  echo $(print_message -e 'true' -i 'end' -m 'DB' -s "$service" -c 'Import' -a "$import" -t 'Import file not found, be sure the file is located inside: '"$DOCKER_DB_IMPORT_PATH"'')
fi