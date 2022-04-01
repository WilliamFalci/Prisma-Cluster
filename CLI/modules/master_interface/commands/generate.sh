#!/bin/bash

if [ -z "$1" ]; then
  echo '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

if [ ! -d $MASTER_PATH ]; then
  mkdir -p $MASTER_PATH
  mkdir -p $MASTER_PATH/model
  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Generate' -a 'Folder' -t 'Model folder created: ./master/model')

  cd $MASTER_PATH/model

  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Create' -a 'Prisma' -t 'Invoked to init model')
  npx prisma init
  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Create' -a 'Prisma' -t 'Configured')

  rm ./.env
  sed -i "s/\DATABASE_URL/MASTER_READ_DB_URL/" ./prisma/schema.prisma

  sed -i "/provider = \"prisma-client-js\"/a\\
  \toutput   = \"../interface\"" ./prisma/schema.prisma

  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Create' -a 'Prisma' -t 'Pointed to the Database')

  master_user=$(openssl rand -base64 29 | tr -d "=+/0123456789" | cut -c1-25 | tr '[:upper:]' '[:lower:]') 
  master_password=$(openssl rand -hex 20);

  envUser="MASTER_READ_DB_USER=$master_user"
  envPassword="MASTER_READ_DB_PASSWORD=$master_password"
  dbConnection="MASTER_READ_DB_URL=postgresql://$master_user:$master_password@localhost:$POSTGRES_PORT/master?schema=public"

  printf "\n\n$envUser" >> $ENV_PATH/.env
  printf "\n$envPassword" >> $ENV_PATH/.env
  printf "\n$dbConnection" >> $ENV_PATH/.env

  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Create' -a 'Credentials' -t 'Created')

  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Create' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -d master -c "create user $master_user with encrypted password '$master_password';")")
  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Create' -a 'Credentials' -t 'master'"'"'s db user: '"$master_user"' with password: '"$master_password"' created')

  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Create' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -d master -c "GRANT CONNECT ON DATABASE master TO $master_user;")")
  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Create' -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -d master -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO $master_user;")")

  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Create' -a 'Credentials' -t 'master'"'"'s db user: '"$master_user"' have now access to 'master''"'"'s DB')

  dotenv -e $ENV_PATH/.env -- npx prisma db pull
  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Fetch' -a 'Prisma' -t 'Introspection done')

  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -a 'Prisma' -t 'Invoked to generate client interface')
  dotenv -e $ENV_PATH/.env -- npx prisma generate
  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -a 'Prisma' -t 'Generation of client interface done')


  master_interface_code="
    const path = require('path');
    \nrequire('dotenv').config({ path: path.resolve('$ENV_PATH', '.env') }); // SUPPORT .ENV FILES
    \nconst processCWD = process.cwd()
    \nprocess.chdir('$MASTER_PATH/model');
    \nconst { PrismaClient } = require('$MASTER_PATH/model/interface')
    \nconst master_interface = new PrismaClient()
    \nprocess.chdir(processCWD)
    \n
    \nmodule.exports = { master_interface }
  "
  echo -e $master_interface_code > $MASTER_PATH/master_interface.js

  echo $(print_message -i 'end' -m 'Master Interface' -s "Model" -c 'Create' -t 'Done')
else
  echo $(print_message -i 'end' -m 'Master Interface' -s "Model" -c 'Create' -t 'Aborted, master interface already exist')
fi