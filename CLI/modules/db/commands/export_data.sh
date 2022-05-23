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
  echo $(print_message -e 'true' -i 'end' -m 'DB' -s 'Export Data' -c 'Argument #1' -a 'Invalid' -t 'Available: global, [service-name]')
  exit
fi

currentDate="data_$(date +%d-%m-%Y"_"%H_%M_%S)"
bk_name=dump_${currentDate}.sql

if [ ! -d "$DATA_EXPORT" ]; then
  mkdir -p "$DATA_EXPORT"
fi

mkdir -p "$DATA_EXPORT/$currentDate"
mkdir -p "$DATA_EXPORT/$currentDate/db"
mkdir -p "$DATA_EXPORT/$currentDate/data"

if [ $1 == "global" ]; then
  echo $(print_message -i 'continue' -m 'Export Data' -s 'DB' -c 'Docker' -t 'Exporting...')
  docker exec -t "${DOCKER_CONTAINER}" pg_dumpall --exclude-database=master --exclude-database=pg_database -U ${POSTGRES_USER} --data-only --no-privileges --no-owner > $DATA_EXPORT/$currentDate/db/$bk_name

  touch $DATA_EXPORT/$currentDate/global.txt
  while true; do
    echo $(print_message -w 'true' -i 'continue' -m 'Export Data' -s "Storage" -c 'Files' -t "Do you want export the relative files as well?")
    read yn
    case $yn in
      [Yy]* ) 
        cp -r $SERVICES_STORAGES/buckets $DATA_EXPORT/$currentDate/data      
        echo $(print_message -i 'continue' -m 'Export Data' -s "Storage" -c "All" -a "Files" -t 'Files Exported');break;;
      [Nn]* )  echo $(print_message -i 'end' -m 'Export Data' -s "Storage" -c 'Files' -t 'Aborted'); exit;;
      * )  echo $(print_message -i 'continue' -m 'Export Data' -s "Storage" -c 'Files' -a 'Answer' -t 'Invalid! Please answer yes or no [y/n]');;    
    esac
  done
else
  if [ ! -d "$SERVICES_PATH/$1" ]; then
    echo $(print_message -i 'end' -m 'DB' -s 'Export Data' -c 'Export' -t 'Nothing to export, the service do not exist')
    exit
  fi

  touch $DATA_EXPORT/$currentDate/service.txt

  echo $(print_message -i 'continue' -m 'Export Data' -s 'DB' -c 'Docker' -a "$1" -t 'Exporting...')
  docker exec -t "${DOCKER_CONTAINER}" pg_dump -U ${POSTGRES_USER} -d $1  --data-only --no-privileges --no-owner > $DATA_EXPORT/$currentDate/db/$1.sql
  echo $(print_message -i 'continue' -m 'Export Data' -s 'DB' -c 'Docker' -a "$1" -t 'Data Exported...')
  while true; do
    echo $(print_message -w 'true' -i 'continue' -m 'Export Data' -s "Storage" -c 'Files' -t "Do you want export the relative files as well?")
    read yn
    case $yn in
      [Yy]* )
        if [ -d "$SERVICES_STORAGES/buckets/$1" ]; then
          cp -r $SERVICES_STORAGES/buckets/$1 $DATA_EXPORT/$currentDate/data
          echo $(print_message -i 'continue' -m 'Export Data' -s "Storage" -c "$1" -a "Service" -t 'Files Exported');
        else
          echo $(print_message -i 'continue' -m 'Export Data' -s "Storage" -c "$1" -a "Service" -t 'Has no files to export');
        fi
        break;;
      [Nn]* )  echo $(print_message -i 'end' -m 'Export Data' -s "Storage" -c 'Files' -t 'Aborted'); break;;
      * )  echo $(print_message -i 'continue' -m 'Export Data' -s "Storage" -c 'Files' -a 'Answer' -t 'Invalid! Please answer yes or no [y/n]');;    
    esac
  done
fi

cd $DATA_EXPORT
tar -zcvf $currentDate.tar.gz ./$currentDate
rm -r ./$currentDate/

echo $(print_message -i 'end' -m 'DB' -s 'Export Data' -c 'Export' -t 'Completed')
