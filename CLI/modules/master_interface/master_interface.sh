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
  echo $(print_message -e 'true' -i 'end' -m 'Master Interface' -s 'Argument #1' -c 'Invalid' -t 'Available: generate, update')
  exit
fi

if ([ "$1" != "generate" ] && [ "$1" != "update" ] ] ); then
  echo $(print_message -e 'true' -i 'end' -m 'Master Interface' -s 'Argument #1' -c 'Invalid' -t 'Available: generate, update')
  exit
fi

if [ $1 == "generate" ]; then
  ./modules/master_interface/commands/generate.sh $ENV_PATH $@
  exit
fi

if [ $1 == "update" ]; then
  ./modules/master_interface/commands/update.sh $ENV_PATH $@
  exit
fi