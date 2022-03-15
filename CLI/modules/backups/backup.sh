#!/bin/bash

if [ -z "$1" ]; then
   printf '> env not parsed from parent\n';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

if [ -z "$1" ]; then
  echo $(print_message -e 'true' -i 'end' -m 'Backup' -s 'Argument #1' -c 'Invalid' -t 'Available: create, rollback')
  exit
fi

if ([ "$1" != "create" ] && [ "$1" != "rollback" ] ); then
  echo $(print_message -e 'true' -i 'end' -m 'Backup' -s 'Argument #1' -c 'Invalid' -t 'Available: create, rollback')
  exit
fi

if [ $1 == "create" ]; then
  ./modules/backups/commands/create.sh $ENV_PATH
  exit
fi

if [ $1 == "rollback" ]; then
  shift
  ./modules/backups/commands/rollback.sh $ENV_PATH $1
  exit
fi