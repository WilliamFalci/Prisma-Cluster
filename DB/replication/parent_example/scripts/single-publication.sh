#!/bin/bash
MODE=$1  ### IF YOU HAVE SUB FOLDER FOR ENVS LIKE: LOCAL/DEV/PRODUCTION
source /xxx/xxx/backend_parent_project/.envs/.${MODE}/.postgres ### ENVIROMENT VARIABLES OF POSTGRES CONNECTION
source ../.replication.env
shift

if [ -z "$1" ]; then
  echo 'Miss table name'
  exit;
fi

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

init_table="true"

if [ ! -z "$3" ]; then
  init_table="$3"
fi

docker exec -it $DJANGO_POSTGRES_CONTAINER psql -U ${POSTGRES_USER} -d euroingro -c "CREATE PUBLICATION $1_pub FOR TABLE $1;"
docker exec -it $DJANGO_POSTGRES_CONTAINER psql -U ${POSTGRES_USER} -d euroingro -c "GRANT ALL ON $1 TO repl_user;"

if [ init_table == "true" ]; then
  docker exec -it $DJANGO_POSTGRES_CONTAINER bash -c "pg_dump -U ${POSTGRES_USER} -d euroingro -t $1 -s | psql -U repl_user -d master -h slave_node"
fi


if grep -w "$1" ../tables; then
  echo 'done'
else
  echo $1 >> ../tables
  echo "> $1 added to tables subscribed"
fi