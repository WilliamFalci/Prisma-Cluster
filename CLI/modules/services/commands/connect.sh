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
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Connect' -c 'Arugment #1' -t 'Service Name not parsed')
  exit
fi


if [ -z "$2" ]; then
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Connect' -c 'Arugment #1' -t 'Method Name not parsed')
  exit
fi

service=$1
method=$2

sed -i "/^const processCWD = process.cwd()/aconst { master_interface } = require(process.env.MASTER_PATH + '/master_interface.js');" $SERVICES_PATH/$service/controllers/${method}_controller.js
echo $(print_message -i 'continue' -m 'Service' -s "$service" -c 'Master Interface' -t ''"$service"' > Master Interface added')
