#!/bin/bash

if [ -z "$1" ]; then
  printf '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

if [ -f "$DATA_EXPORT/$1.tar.gz" ]; then
  bk=$1

  yarn rpc backup create
  
  cd $DATA_EXPORT
  echo $(print_message -i 'continue' -m 'Restore Data' -s "$bk" -c 'Dump' -a 'Decompression' -t 'Started')
  tar -xf $bk.tar.gz
  echo $(print_message -i 'continue' -m 'Restore Data' -s "$bk" -c 'Dump' -a 'Decompression' -t 'End')

  if [ -f "$DATA_EXPORT/$bk/global.txt" ]; then
    cat $DATA_EXPORT/$bk/db/dump_$bk.sql | docker exec -i "${DOCKER_CONTAINER}" psql -U ${POSTGRES_USER}
  else
    for f in $DATA_EXPORT/$bk/db/*.sql
    do
      filename=$(basename $f .sql)
      cat $DATA_EXPORT/$bk/db/$filename.sql | docker exec -i "${DOCKER_CONTAINER}" psql -U ${POSTGRES_USER} -d $filename
    done
  fi

  subdircount=$(find $DATA_EXPORT/$bk/data -maxdepth 1 -type d | wc -l)

  if [[ "$subdircount" -eq 1 ]]
  then
    echo $(print_message -i 'continue' -m 'Restore Data' -s '$bk' -c 'Dump' -a 'Storage' -t 'Nothing to apply')
  else
    if [ -f "$DATA_EXPORT/$bk/global.txt" ]; then
        if [ -f "$SERVICES_STORAGES/buckets" ]; then
          rm -R $SERVICES_STORAGES/buckets
        fi
        cp -R $DATA_EXPORT/$bk/data/buckets $SERVICES_STORAGES
        echo $(print_message -i 'continue' -m 'Restore Data' -s '$bk' -c 'Dump' -a 'Storage' -t 'Files applied')
    else
      for d in $DATA_EXPORT/$bk/data/* ; do
        service=$(basename $d)
        if [ -d "$SERVICES_STORAGES/buckets/$service" ]; then
          rm -R $SERVICES_STORAGES/buckets/$service
        fi
        cp -R $DATA_EXPORT/$bk/data/$service $SERVICES_STORAGES/buckets/$service
        echo $(print_message -i 'continue' -m 'Restore Data' -s '$bk' -c "$service dump" -a 'Storage' -t 'Files applied')
      done
    fi
  fi

  rm -R $DATA_EXPORT/$bk

  echo $(print_message -i 'end' -m 'Restore Data' -s "$bk" -c 'Dump' -t 'Applied')
else
  echo $(print_message -e 'true' -i 'end' -m 'Restore Data' -s "$bk" -c 'Not Found' -t 'Data do not exist')
fi