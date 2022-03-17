#!/bin/bash

if [ -z "$1" ]; then
  printf '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

if [ -z "$1" ]; then
  echo $(print_message -e 'true' -i 'end' -m 'DB' -s 'Argument #1' -c 'Invalid' -t 'Miss service name')
  exit
fi

service=$1

if [ -d "$SERVICES_PATH/$service" ]; then
  echo $(print_message -i 'continue' -m 'DB' -s "$service" -c 'Fetch' -a 'Prisma' -t 'Invoked to run the introspection...')
  cd $SERVICES_PATH/$service/model

  dotenv -e $ENV_PATH/.env -- npx prisma db pull
  echo $(print_message -i 'continue' -m 'DB' -s "$service" -c 'Fetch' -a 'Prisma' -t 'Introspection done')

  echo $(print_message -i 'continue' -m 'DB' -s "$service" -c 'Fetch' -a 'Prisma' -t 'Invoked to generate client interface')
  dotenv -e $ENV_PATH/.env -- npx prisma generate
  echo $(print_message -i 'continue' -m 'DB' -s "$service" -c 'Fetch' -a 'Prisma' -t 'Generation of client interface done')
  echo $(print_message -i 'end' -m 'DB' -s "$service" -c 'Fetch' -a 'Prisma' -t 'Service fetched')
else
  echo $(print_message -e 'true' -i 'end' -m 'DB' -s "$service" -c 'Service' -a 'Folder' -t 'Not exist')
fi