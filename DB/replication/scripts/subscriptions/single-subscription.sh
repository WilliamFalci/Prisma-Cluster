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
    echo 'Subscription already exist'
    exit
  fi
fi


if docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -lqt | cut -d \| -f 1 | grep -qw "$1"; then
  docker exec -it ${DOCKER_CONTAINER} pg_dump -U $POSTGRES_USER -d master --no-privileges --no-owner -t $1 -s 
  echo 'Table already exist, dumped the local one'
else
  docker exec -it  ${DOCKER_CONTAINER} bash -c "export PGPASSWORD='${PARENT_REPLICATION_PASSWORD}'; pg_dump -h master_node -U ${PARENT_REPLICATION_USER} -d ${PARENT_REPLICATION_DB} -t $1 --no-privileges --no-owner -s" > ../../init/02-Create_table_$1.sql
  cat ../../init/02-Create_table_$1.sql | docker exec -i "${DOCKER_CONTAINER}" psql -U ${POSTGRES_USER} -d master
  echo 'Table created from the master'
fi

echo "CREATE SUBSCRIPTION $1_sub_$DEVICE_NAME CONNECTION 'dbname=${PARENT_REPLICATION_DB} host=master_node user=${PARENT_REPLICATION_USER} password=${PARENT_REPLICATION_PASSWORD}' PUBLICATION $1_pub" > ../../init/03-Create_sub_$1.sql
echo "SQL: sub_$1_$DEVICE_NAME -> created"

if [ "$(docker container inspect $DOCKER_CONTAINER -f '{{.State.Running}}')" == "true" ]; then
  
  docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "CREATE SUBSCRIPTION $1_sub_$DEVICE_NAME CONNECTION 'dbname=${PARENT_REPLICATION_DB} host=master_node user=${PARENT_REPLICATION_USER} password=${PARENT_REPLICATION_PASSWORD}' PUBLICATION $1_pub";
else
  echo "Docker: $DOCKER_CONTAINER is offline skipping"
fi

if grep -w "$1" ../tables; then
  echo 'done'
else
  echo $1 >> ../tables
  echo "$1 added to tables subscribed"
fi