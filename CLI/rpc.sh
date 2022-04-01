#!/bin/bash

set -e

source ./env/.env
source ./helpers/text.sh

echo "$TBOLD"'⋗ PRISMA CLUSTER MANAGEMENT ⋖'"$TREGULAR"
echo "$TBOLD"'⋗ Don'"'"'t run any operation if you don'"'"'t know what you are doing! ⋖'"$TREGULAR"
echo "$TBOLD"'⋗ Author: Falci William Peter ⋖'"$TREGULAR"
printf "\n\n"


if [ -z "$1" ]; then
  echo $(print_message -e 'true' -i 'end' -m 'Core' -s 'Arguments' -c 'Invalid' -t 'No arguments parsed, example: yarn rpc [enviroment] [handler] [command] [optional service name]')
  exit
else
  if ([ "$1" != "service" ] && [ "$1" != "backup" ] && [ "$1" != "db" ] && [ "$1" != "master_interface" ] ); then
    echo $(print_message -e 'true' -i 'end' -m 'Core' -s 'Argument #1' -c 'Invalid' -t 'Value accepted: service, backup, db, master_interface')
  else
    if [ $1 == "service" ]; then
    echo $(print_message -i 'start' -m 'SERVICE HANDLER' -t 'READY')
    shift

    ./modules/services/service.sh $ENV_PATH $@
    exit
    fi

    if [ $1 == "backup" ]; then
      echo $(print_message -i 'start' -m 'BACKUP HANDLER' -t 'READY')
      shift

      ./modules/backups/backup.sh $ENV_PATH $@
      exit
    fi

    if [ $1 == "db" ]; then
      echo $(print_message -i 'start' -m 'DB HANDLER' -t 'READY')
      shift

      ./modules/db/db.sh $ENV_PATH $@
      exit
    fi

    if [ $1 == "master_interface" ]; then
      echo $(print_message -i 'start' -m 'MASTER INTERFACE HANDLER' -t 'READY')
      shift

      ./modules/master_interface/master_interface.sh $ENV_PATH $@
      exit
    fi
  fi
fi