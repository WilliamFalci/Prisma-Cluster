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
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Delete' -c 'Arugment #1' -t 'Service Name not parsed')
  exit
fi

if [ $1 == "global" ]; then
  cd $SERVICES_PATH
  for d in */ ; do
    service_name=${d/"/"/""}

    cd $SERVICES_PATH/$service_name/model
    echo $(print_message -i 'continue' -m 'Service' -s "$service_name" -c 'Migrate' -a 'Prisma' -t 'Invoking for migration')
    dotenv -e $ENV_PATH/.env -- npx prisma migrate dev
  done
  echo $(print_message -i 'end' -m 'Service' -s 'Global' -a 'Migration' -t 'Completed')
  exit
else
  if [ -d "$SERVICES_PATH/$1" ]; then
    cd $SERVICES_PATH/$1/model
    echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Migrate' -a 'Prisma' -t 'Invoking for migration')
    dotenv -e $ENV_PATH/.env -- npx prisma migrate dev
    echo $(print_message -i 'end' -m 'Service' -s "$1" -a 'Migration' -t 'Completed')
    exit
  else
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s "$1" -t 'Not Exist')
    exit
  fi
fi

