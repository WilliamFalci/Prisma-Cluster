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
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Deploy' -c 'Arugment #1' -t 'Service Name not parsed')
  exit
fi


echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c 'Backup' -a 'Global' -t 'I'"'"'m generating a global backup before deploy')
yarn rpc backup create


if [ $1 == "global" ]; then
  cd $SERVICES_PATH
  for d in */ ; do
    service=${d/"/"/""}

    if [ ! -d "$SERVICES_PATH/$service/model" ]; then
       continue
    fi

    cd $SERVICES_PATH/$service/model
    echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'DB' -t 'Checking if exist')

    if docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -lqt | cut -d \| -f 1 | grep -qw "$service"; then
      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'DB' -t 'Already exist')
    else
      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'DB' -t 'Not exist... start to generate it')

      service_user=$(openssl rand -base64 29 | tr -d "=+/0123456789" | cut -c1-25 | tr '[:upper:]' '[:lower:]') 
      service_password=$(openssl rand -hex 20);
      envUser="SERVICE_${service^^}_DB_USER=$service_user"
      envPassword="SERVICE_${service^^}_DB_PASSWORD=$service_password"
      dbConnection="SERVICE_${service1^^}_DB_URL=postgresql://$service_user:$service_password@localhost:$POSTGRES_PORT/$service?schema=public"

      printf "\n\n$envUser" >> $ENV_PATH/.env
      printf "\n$envPassword" >> $ENV_PATH/.env
      printf "\n$dbConnection" >> $ENV_PATH/.env

      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "create user "$service_user" with encrypted password '$service_password';")")
      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'Credentials' -t 'Service'"'"'s db user: '"$service_user"' with password: '"$service_password"' created')

      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "CREATE DATABASE $service WITH OWNER = $POSTGRES_USER ENCODING 'UTF8' LC_COLLATE 'en_US.utf8' LC_CTYPE 'en_US.utf8';")")
      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'DB' -t 'Service'"'"'s database created')

      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "grant all privileges on database $service to "$service_user";")")
      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'Docker' -t "$(docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "ALTER USER "$service_user" CREATEDB;")")
      echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'DB Access' -t 'Service'"'"'s db user: '"$service_user"' have now access to '"$service"''"'"'s DB')

      source $ENV_PATH/.env
    fi
    echo $(print_message -i 'continue' -m 'Service' -s 'Deploy' -c "$service" -a 'Prisma' -t 'Invoked to deploy')
    dotenv -e $ENV_PATH/.env -- npx prisma migrate deploy
  done

  for f in $SERVICES_DELETED_PATH/* ; do
    service_deleted=${f##*/}
    if docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -lqt | cut -d \| -f 1 | grep -qw "${service_deleted}"; then
      cd $CLI_PATH
      yarn rpc service delete $service_deleted
    fi
  done

  echo $(print_message -i 'end' -m 'Service' -s 'Global' -c 'Deploy' -t 'Completed')
  exit
else
  cd $SERVICES_PATH/$1/model
  printf "╠ Service > ${TC_CYAN}$1 > Deploy\n"

    
  echo $(print_message -i 'continue' -m 'Service' -s "$1" -c 'Deploy' -t 'Started')
  dotenv -e $ENV_PATH/.env -- npx prisma migrate deploy
  echo $(print_message -i 'end' -m 'Service' -s "$1" -c 'Deploy' -t 'Completed')
  exit
fi