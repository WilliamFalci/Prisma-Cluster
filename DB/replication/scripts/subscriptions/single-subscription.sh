#!/bin/bash
source ../../../../CLI/env/.env
source ../../env/.env.replication


if [ -z "$2" ]; then
  check='true'
else
  check="$2"
fi

if [ check == 'true' ]; then
  if grep -w "$1" ../tables; then
    echo '> Subscription already exist'
    exit
  fi
fi


docker exec -it ${DOCKER_CONTAINER} pg_dump -U $POSTGRES_USER -d master  -t $1 -s > ../../init/01-Create_table_$1.sql

echo "CREATE SUBSCRIPTION $1_sub CONNECTION 'dbname=${PARENT_REPLICATION_DB} host=master_node user=${PARENT_REPLICATION_USER} password=${PARENT_REPLICATION_PASSWORD}' PUBLICATION $1_pub_$DEVICE_NAME" > ../../init/02-Create_sub_$1.sql
echo "> SQL: sub_$1 -> created"

if [ "$(docker container inspect $DOCKER_CONTAINER -f '{{.State.Running}}')" == "true" ]; then
  docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "CREATE SUBSCRIPTION $1_sub_$DEVICE_NAME CONNECTION 'dbname=${PARENT_REPLICATION_DB} host=master_node user=${PARENT_REPLICATION_USER} password=${PARENT_REPLICATION_PASSWORD}' PUBLICATION $1_pub_$DEVICE_NAME";
else
  echo "> Docker: $DOCKER_CONTAINER is offline skipping"
fi

if grep -w "$1" ../tables; then
  echo 'done'
else
  echo $1 >> ../tables
  echo "> $1 added to tables subscribed"
fi