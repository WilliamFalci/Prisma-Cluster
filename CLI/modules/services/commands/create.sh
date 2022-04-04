#!/bin/bash

if [ -z "$1" ]; then
  echo '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

if [ -z "$1" ]; then
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Create' -c 'Arugment #1' -t 'Service Name not parsed')
  exit
fi

create_credentials="true"

if [ ! -z "$2" ]; then
  create_credentials=$2
fi

only_master="false"
if [ ! -z "$3" ]; then
  only_master=$3
fi

echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -t 'Creation Started')

rm -rf ${SERVICES_DELETED_PATH}/$1 || true

mkdir -p $SERVICES_PATH/$1

echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Folder' -t 'Service folder created: ./services/'"$1"'')

cd $SERVICES_PATH/$1
mkdir -p $SERVICES_PATH/$1/controllers
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Folder' -t 'Controller folder created: ./services/'"$1"'/controller')

mkdir -p $SERVICES_PATH/$1/methods
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Folder' -t 'Methods folder created: ./services/'"$1"'/methods')

if [ "$only_master" == "false" ]; then
  mkdir -p $SERVICES_PATH/$1/model
  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Folder' -t 'Model folder created: ./services/'"$1"'/model')
fi 
router_code="
  \nmodule.exports = (args,callback) => {
  \n}
"
echo -e $router_code > $SERVICES_PATH/$1/router.js

if [ "$only_master" == "false" ]; then
  cd $SERVICES_PATH/$1/model

  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Prisma' -t 'Invoked to init model')
  npx prisma init
  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Prisma' -t 'Configured')

  rm ./.env
  sed -i "s/\DATABASE_URL/SERVICE_${1^^}_DB_URL/" ./prisma/schema.prisma

  sed -i "/provider = \"prisma-client-js\"/a\\
  \toutput   = \"../interface\"" ./prisma/schema.prisma

  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Prisma' -t 'Pointed to the Database')
fi 

if [ "$create_credentials" == "true" ]; then
  service_user=$(openssl rand -base64 29 | tr -d "=+/0123456789" | cut -c1-25 | tr '[:upper:]' '[:lower:]') 
  service_password=$(openssl rand -hex 20);
  envUser="SERVICE_${1^^}_DB_USER=$service_user"
  envPassword="SERVICE_${1^^}_DB_PASSWORD=$service_password"
  dbConnection="SERVICE_${1^^}_DB_URL=postgresql://$service_user:$service_password@localhost:$POSTGRES_PORT/$1?schema=public"

  printf "\n\n$envUser" >> $ENV_PATH/.env
  printf "\n$envPassword" >> $ENV_PATH/.env
  printf "\n$dbConnection" >> $ENV_PATH/.env

  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Credentials' -t 'Created')

  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -d master -c "create user $service_user with encrypted password '$service_password';")")
  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Credentials' -t 'Service'"'"'s db user: '"$service_user"' with password: '"$service_password"' created')


  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -d master -c "CREATE DATABASE $1 WITH OWNER = $service_user ENCODING 'UTF8' LC_COLLATE 'en_US.utf8' LC_CTYPE 'en_US.utf8';")")
  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Credentials' -t 'Service'"'"'s database created')

  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -d master -c "GRANT ALL PRIVILEGES ON DATABASE $1 to $service_user;")")
  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -d master -c "ALTER USER $service_user CREATEDB;")")
  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -d $1 -c "ALTER DEFAULT PRIVILEGES FOR USER $service_user IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $service_user;")")

  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Credentials' -t 'Service'"'"'s db user: '"$service_user"' have now access to '"$1"''"'"'s DB')
fi

echo -e "const storage_$1 = require('filestorage').create(\`\${__dirname}/buckets/$1\`)\n$(cat $SERVICES_STORAGES/index.js)" > $SERVICES_STORAGES/index.js
sed -i "/^module.exports = {/a\ \ storage_$1," $SERVICES_STORAGES/index.js
echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Storage' -t 'Created')


sed -i "/^\/\/ DO NOT ALTER OR DELETE THIS LINE - IMPORT SERVICES METHODS/a \const $1 = require('./services/$1/router.js');" $PROJECT_PATH/RPC/router.js
sed -i "/^let methods = {}/a \methods = Object.assign(methods,{$1: $1});" $PROJECT_PATH/RPC/router.js


echo $(print_message -i 'end' -m 'Service' -s "$1" -c 'Create' -t 'Done')