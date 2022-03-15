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
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Studio' -c 'Arugment #1' -t 'Service Name not parsed')
  exit
fi

if [ -d "$SERVICES_PATH/$1" ]; then
    cd $SERVICES_PATH/$1/model
    dotenv -e $ENV_PATH/.env -- npx prisma studio
    exit
else
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s "$1" -t 'Not Exist')
  exit
fi