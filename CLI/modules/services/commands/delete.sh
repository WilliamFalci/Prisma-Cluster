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


echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -t 'Pleas insert your name')
read -r operator

echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -t 'Please insert the reason of deletion')
read -r reason


touch $SERVICES_DELETED_PATH/$1
printf "Dev: $operator" > $SERVICES_DELETED_PATH/$1
printf "\nDate: $(date +'%d-%m-%Y %T')" >> $SERVICES_DELETED_PATH/$1
printf "\nReason: $reason" >> $SERVICES_DELETED_PATH/$1

user=SERVICE_${1^^}_DB_USER

rm -rf ${SERVICES_PATH}/$1 || true
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -t 'Drop Database')
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "DROP DATABASE $1 WITH (FORCE);")")

echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -t 'Drop user: '""${!user}""'')
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "drop user "${!user}";")")


sed -i "/SERVICE_${1^^}_DB_USER/d" $ENV_PATH/.env
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Enviroment' -t 'Variable '"SERVICE_${1^^}_DB_USER"' deleted')
sed -i "/SERVICE_${1^^}_DB_PASSWORD/d" $ENV_PATH/.env
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Enviroment' -t 'Variable '"SERVICE_${1^^}_DB_PASSWORD"' deleted')
sed -i "/SERVICE_${1^^}_DB_URL/d" $ENV_PATH/.env
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Enviroment' -t 'Variable '"SERVICE_${1^^}_DB_URL"' deleted')
sed -i '/^$/d' $ENV_PATH/.env


sed -i "/const $1 = require('.\/services\/$1\/router.js');/d" $PROJECT_PATH/RPC/router.js
sed -i "/methods = Object.assign(methods,{$1: $1})/d" $PROJECT_PATH/RPC/router.js

echo $(print_message -i 'end' -m 'Service' -s "$1" -c 'Delete' -t 'Deletion completed')