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

if [ ! -d "$SERVICES_DELETED_PATH" ]; then
  mkdir -p "$SERVICES_DELETED_PATH"
fi

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

if test -f "$JOBS_PATH/services/$1.js"; then
  rm -rf ${JOBS_PATH}/services/$1.js || true
  sed -i "/const $1Jobs =/d" $JOBS_PATH/index.js
  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Jobs' -t 'Jobs deleted')
fi

sed -i "/const $1 = require('.\/services\/$1\/router.js');/d" $PROJECT_PATH/RPC/router.js
sed -i "/methods = Object.assign(methods,{$1: $1})/d" $PROJECT_PATH/RPC/router.js
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Route' -t 'Deleted')

while true; do
  echo $(print_message -w 'true' -i 'continue' -m 'Service' -s "$2" -c 'Delete' -a 'Storage' -t "ATTENTION: I will delete anyway the logical link to the storage/index.js, do you want I delete physically the files stored into $1's storage? the deletion will be irreversible, if you are not sure then make a backup of the folder: $SERVICES_STORAGES/buckets/$1 then you can delete manually the folder if you not need it -> [y =  yes delete files stored / n = no keep the files stored and delete only the logical link to the storage]")
  read yn
  case $yn in
    [Yy]* ) 
      rm -rf ${SERVICES_STORAGES}/buckets/$1 || true;
      echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Storage' -t 'Files Deleted');break;;
    [Nn]* )  echo $(print_message -i 'end' -m 'Service' -s "$2" -c 'Delete' -a 'Storage' -t 'Physically deletion aborted'); break;;
    * )  echo $(print_message -i 'end'-m 'Service' -s "$2" -c 'Delete' -a 'Answer' -t 'Invalid! Please answer yes or no [y/n]');;    
  esac
done

sed -i "/const storage_$1/d" $SERVICES_STORAGES/index.js
sed -i "/storage_$1/d" $SERVICES_STORAGES/index.js
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Delete' -a 'Storage' -t 'Logical link Deleted')



echo $(print_message -i 'end' -m 'Service' -s "$1" -c 'Delete' -t 'Deletion completed')