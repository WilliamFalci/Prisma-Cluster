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
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Argument #1' -c 'Invalid' -t 'Available: schema, create, migrate, delete, deploy, studio')
  exit
fi

if ([ "$1" != "schema" ] && [ "$1" != "create" ]  && [ "$1" != "migrate" ]  && [ "$1" != "delete" ]  && [ "$1" != "deploy" ]   && [ "$1" != "studio" ] && [ "$1" != "method" ] ); then
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Argument #1' -c 'Invalid' -t 'Available: method, schema, create, migrate, delete, deploy, studio')
  exit
fi

if [ $1 == "schema" ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Schema' -c 'Miss' -t 'Service Name')
    exit;
  fi
    echo $(print_message -i 'end' -m 'Service' -s "$2" -c 'Opening' -t 'Schema')
    code $SERVICES_PATH/$2/model/prisma/schema.prisma;
  exit
fi

if [ $1 == "create" ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Create' -c 'Miss' -t 'Service Name')
    exit;
  fi
  shift;
  ./modules/services/commands/create.sh $ENV_PATH $@
  exit
fi

if [ $1 == "migrate" ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Migrate' -c 'Miss' -t 'Service Name')
    exit;
  fi
  shift
  ./modules/services/commands/migrate.sh $ENV_PATH $@
  exit
fi

if [ $1 == "studio" ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Studio' -c 'Miss' -t 'Service Name')
    exit;
  fi
  shift
  ./modules/services/commands/studio.sh $ENV_PATH $@
  exit
fi

if [ $1 == "method" ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Method' -c 'Miss' -t 'Service Name')
    exit;
  fi
  shift
  ./modules/services/commands/method.sh $ENV_PATH $@
  exit
fi

if [ $1 == "delete" ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Delete' -c 'Miss' -t 'Service Name')
    exit;
  fi
  while true; do
    echo $(print_message -w 'true' -i 'continue' -m 'Service' -s "$2" -c 'Delete' -t 'Are you sure to delete this service? You will lose all data related of this service [y/n]')
    read yn
    case $yn in
      [Yy]* ) 
        shift;
        ./modules/services/commands/delete.sh $ENV_PATH $@
        break;;
      [Nn]* )  echo $(print_message -i 'end' -m 'Service' -s "$2" -c 'Delete' -t 'Aborted'); exit;;
      * )  echo $(print_message -i 'end'-m 'Service' -s "$2" -c 'Delete' -a 'Answer' -t 'Invalid! Please answer yes or no [y/n]');;    
    esac
  done
  exit
fi

if [ $1 == "deploy" ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Deploy' -c 'Arguments' -a 'Invalid' -t 'Available: global, [service name]')
    exit;
  fi
  while true; do
    echo $(print_message -w 'true' -i 'continue' -m 'Service' -s "$2" -c 'Deploy' -t 'Are you sure to deploy this service? All migrations will be applied to the Database [y/n]')
    read yn
    case $yn in
      [Yy]* ) 
        shift;
        ./modules/services/commands/deploy.sh $ENV_PATH $@
        break;;
      [Nn]* )  echo $(print_message -i 'end' -m 'Service' -s "$2" -c 'Deploy' -t 'Aborted'); exit;;
      * )  echo $(print_message -i 'end' -m 'Service' -s "$2" -c 'Deploy' -a 'Answer' -t 'Invalid! Please answer yes or no [y/n]');;
    
    esac
  done
  exit
fi