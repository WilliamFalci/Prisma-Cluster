#!/bin/bash

if [ -z "$1" ]; then
  echo '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

if [ -d $MASTER_PATH ]; then
  cd $MASTER_PATH/model
  dotenv -e $ENV_PATH/.env -- npx prisma db pull
  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -c 'Fetch' -a 'Prisma' -t 'Introspection done')

  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -a 'Prisma' -t 'Invoked to generate client interface')
  dotenv -e $ENV_PATH/.env -- npx prisma generate
  echo $(print_message -i 'continue' -m 'Master Interface' -s "Model" -a 'Prisma' -t 'Generation of client interface done')


  echo $(print_message -i 'end' -m 'Master Interface' -s "Model" -c 'Create' -t 'Done')
else
  echo $(print_message -i 'end' -m 'Master Interface' -s "Model" -c 'Create' -t 'Aborted, master interface do not exist')
fi