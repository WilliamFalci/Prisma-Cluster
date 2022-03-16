#!/bin/bash

if [ -z "$1" ]; then
  printf '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

echo $(print_message -i 'continue' -m 'Backup' -s "Global" -t 'Current envirotment backup started')

currentDate=$(date +%d-%m-%Y"_"%H_%M_%S)
bk_name=dump_${currentDate}.sql

if [ ! -d "$SERVICES_BACKUP" ]; then
  mkdir -p "$SERVICES_BACKUP"
fi

mkdir -p "$SERVICES_BACKUP/$currentDate"
mkdir -p "$SERVICES_BACKUP/$currentDate/env"
mkdir -p "$SERVICES_BACKUP/$currentDate/db"

cp $ENV_PATH/.env $SERVICES_BACKUP/$currentDate/env
docker exec -t "${DOCKER_CONTAINER}" pg_dumpall --exclude-database=master -U ${POSTGRES_USER} > $SERVICES_BACKUP/$currentDate/db/$bk_name
echo $(print_message -i 'continue' -m 'Backup' -s 'Global' -t 'Current envirotment backup finished')

mkdir -p "$SERVICES_BACKUP/$currentDate/services/"
for d in $SERVICES_PATH/* ; do
  service=$(basename $d)
  mkdir -p "$SERVICES_BACKUP/$currentDate/services/$service"
  cp -r $SERVICES_PATH/$service/controllers $SERVICES_BACKUP/$currentDate/services/$service/controllers
  cp -r $SERVICES_PATH/$service/methods $SERVICES_BACKUP/$currentDate/services/$service/methods
  cp $SERVICES_PATH/$service/router.js $SERVICES_BACKUP/$currentDate/services/$service/router.js
  echo $(print_message -i 'continue' -m 'Backup' -s "$service" -a 'Backup' -t 'Done')
done

cd $SERVICES_BACKUP
tar -zcvf $currentDate.tar.gz ./$currentDate
rm -r ./$currentDate/

echo $(print_message -i 'end' -m 'Backup' -s 'Global' -t 'Bakcup name: '"$currentDate"'')

# docker cp $DB_LOCAL_BK_PATH/$bk_name $DOCKER_CONTAINER:/backups/$bk_name