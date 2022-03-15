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
  echo $(print_message -e 'true' -i 'end' -m 'DB' -s 'Argument #1' -c 'Invalid' -t 'Available: import, fetch')
  exit
fi

if ([ "$1" != "import" ] && [ "$1" != "fetch" ] ); then
  echo $(print_message -e 'true' -i 'end' -m 'DB' -s 'Argument #1' -c 'Invalid' -t 'Available: import, fetch')
  exit
fi

if [ $1 == "import" ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'DB' -c 'Arguments' -a 'Invalid' -t 'Miss [service name]')
    exit;
  fi
  ./modules/db/commands/import.sh $ENV_PATH $*
  exit
fi

if [ $1 == "fetch" ]; then
  shift
  ./modules/db/commands/fetch.sh $ENV_PATH $1
  exit
fi