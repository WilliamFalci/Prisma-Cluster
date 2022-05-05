#!/bin/bash

if [ -z "$1" ]; then
  printf '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

if [ -f "$SERVICES_BACKUP/$1.tar.gz" ]; then
  bk=$1

  cd $SERVICES_BACKUP
  echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c 'Rollback' -a 'Decompression' -t 'Started')
  tar -xf $bk.tar.gz
  echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c 'Rollback' -a 'Decompression' -t 'End')

  cp $SERVICES_BACKUP/$bk/env/.env $ENV_PATH/.env
  source $ENV_PATH/.env
  echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c 'Rollback' -a 'Enviroment' -t 'Enviroment variables restored')


  echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c 'Rollback' -a 'Docker' -t 'DB restoring started')
  
  while read database; do
    service=${database/$'\r'/}
    service_user=SERVICE_${1^^}_DB_USER
    docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "DROP DATABASE IF EXISTS $service;"
    docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "DROP USER $service_user;"
  done < <(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "SELECT datname FROM pg_database WHERE datname <> 'postgres' AND datname <> 'master' AND datistemplate = false;" 2>&1)

  cat $SERVICES_BACKUP/$bk/db/dump_$bk.sql | docker exec -i "${DOCKER_CONTAINER}" psql -U ${POSTGRES_USER}
  echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c 'Rollback' -a 'Docker' -t 'Database restored')
  
  subdircount=$(find $SERVICES_PATH -maxdepth 1 -type d | wc -l)

  if [[ "$subdircount" -eq 1 ]]
  then
    echo $(print_message -i 'continue' -m 'Services' -s 'Check' -c 'Found' -a 'False' -t 'Going ahead')
  else
    echo $(print_message -i 'continue' -m 'Services' -s 'Check' -c 'Found' -a 'True' -t 'Delete all services...')

    for k in $SERVICES_PATH/* ; do
      service=$(basename $k)
      sed -i "/const $service = require('.\/services\/$service\/router.js');/d" $PROJECT_PATH/RPC/router.js
      sed -i "/methods = Object.assign(methods,{$service: $service})/d" $PROJECT_PATH/RPC/router.js
      echo $(print_message -i 'continue' -m 'Service' -s "$service" -c 'Delete' -a 'Route Link' -t 'Done')

      sed -i "/const storage_$service = require('filestorage').create(\`\${__dirname}\/buckets\/$service\`)/d" $SERVICES_STORAGES/index.js
      sed -i "/\ \ storage_$service,/d" $SERVICES_STORAGES/index.js
      echo $(print_message -i 'continue' -m 'Service' -s "$service" -c 'Delete' -a 'Storage' -t 'Logical link Deleted')
    done

    rm -r $SERVICES_PATH/*
    echo $(print_message -i 'continue' -m 'Backup' -s 'Check' -c 'Found' -a 'False' -t 'All services deleted')
  fi
  
  while read database; do
    service=${database/$'\r'/}
    if ([[ "$service" != *"datname"* ]] && [[ "${service::1}" == [a-zA-Z] ]] && [ "${service::1}" != "-" ] && [ "${service::1}" != "(" ]); then
      if [ ! -d "$SERVICES_PATH/$service" ]; then
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c 'Service' -a "$service" -t 'Re-create service folder')
        $CLI_PATH/modules/services/commands/create.sh $ENV_PATH $service false

        cp -r $SERVICES_BACKUP/$bk/services/$service/controllers/* $SERVICES_PATH/$service/controllers
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Controllers' -t 'Restored')
        cp -r $SERVICES_BACKUP/$bk/services/$service/methods/* $SERVICES_PATH/$service/methods
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Methods' -t 'Restored')
        cp $SERVICES_BACKUP/$bk/services/$service/router.js $SERVICES_PATH/$service/router.js
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Router' -t 'Restored')

        checkMigrations=$(find $SERVICES_BACKUP/$bk/services/$service/migrations/ -maxdepth 1 -type d | wc -l)
        if [[ "$subdircount" -eq 1 ]]
        then
          echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Migrations' -t 'No migrations to restored')
        else
          mkdir $SERVICES_PATH/$service/model/prisma/migrations
          cp -r $SERVICES_BACKUP/$bk/services/$service/migrations/* $SERVICES_PATH/$service/model/prisma/migrations
          echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Migrations' -t 'Restored')
        fi
        
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c 'Service' -a "$service" -t 'Folder restored')

        cd $SERVICES_PATH/$service/model
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Prisma' -t 'Invoked to introspect service')
        dotenv -e $ENV_PATH/.env -- npx prisma db pull
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Prisma' -t 'Introspection end')
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Prisma' -t 'Invoked to generate client interface')
        dotenv -e $ENV_PATH/.env -- npx prisma generate
        echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Prisma' -t 'Generation of client interface end')
      fi
    fi
  done < <(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "SELECT datname FROM pg_database WHERE datname <> 'postgres' AND datname <> 'master' AND datistemplate = false;" 2>&1)

  for d in $SERVICES_BACKUP/$bk/services/* ; do
    service=$(basename $d)
    if [ ! -d "$SERVICES_PATH/$service" ]; then
      echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c 'Service' -a "$service" -t 'Re-create service folder')
      $CLI_PATH/modules/services/commands/create.sh $ENV_PATH $service false true

      cp -r $SERVICES_BACKUP/$bk/services/$service/controllers/* $SERVICES_PATH/$service/controllers
      echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Controllers' -t 'Restored')
      cp -r $SERVICES_BACKUP/$bk/services/$service/methods/* $SERVICES_PATH/$service/methods
      echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Methods' -t 'Restored')
      cp $SERVICES_BACKUP/$bk/services/$service/router.js $SERVICES_PATH/$service/router.js
      echo $(print_message -i 'continue' -m 'Backup' -s "$bk" -c "$service" -a 'Router' -t 'Restored')
    fi
  done

  rm -r $SERVICES_BACKUP/$bk
  echo $(print_message -i 'end' -m 'Backup' -s "$bk" -c 'Rollback' -a 'Global' -t 'Cluster restored to: '"$bk"'')
else
  echo $(print_message -e 'true' -i 'end' -m 'Backup' -s "$bk" -c 'Not Found' -t 'Backup not exist')
fi