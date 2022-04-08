#!/bin/bash

if [ -z "$1" ]; then
  echo '> env not parsed from parent';
  exit
else
  source $1/.env
  source $CLI_PATH/helpers/text.sh
  shift
fi

service=$1
shift

if [ -z "$1" ]; then
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Method' -c 'Arugment #1' -t 'command not parsed, available: add, remove')
  exit
fi

if [ "$1" == 'add' ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Method' -c 'Arugment #2' -t 'method name not parsed')
    exit
  fi
  method_name=$2

  only_master="false"
  if [ ! -z "$3" ]; then
    only_master=$3
  fi
  
  if [ "$only_master" == "false" ]; then
    controller_code="
      const path = require('path');
      \nrequire('dotenv').config({ path: path.resolve('$ENV_PATH', '.env') }); // SUPPORT .ENV FILES
      \nconst { storage_$service } = require('$SERVICES_STORAGES/index.js')
      \nconst processCWD = process.cwd()
      \nprocess.chdir('$SERVICES_PATH/$service/model');
      \nconst { PrismaClient } = require('$SERVICES_PATH/$service/model/interface')
      \nconst interface = new PrismaClient()
      \nprocess.chdir(processCWD)
      \n
      \nmodule.exports = async (args) => { 
      \n\t
      \n}
    "
  fi

  if [ "$only_master" == "master_only" ]; then
    controller_code="
      const path = require('path');
      \nrequire('dotenv').config({ path: path.resolve('$ENV_PATH', '.env') }); // SUPPORT .ENV FILES
      \nconst { storage_$service } = require('$SERVICES_STORAGES/index.js')
      \nconst { master_interface } = require('${MASTER_PATH}/master_interface.js');
      \n
      \nmodule.exports = async (args) => { 
      \n\t
      \n}
    "
  fi

  echo -e $controller_code > $SERVICES_PATH/$service/controllers/${method_name}_controller.js
  echo $(print_message -i 'continue' -m 'Service' -s 'Method' -c 'Add' -t ''"$method_name"' > Controller created')

  method_code="
    const ${method_name}_controller = require('../controllers/${method_name}_controller')
    \n
    \nmodule.exports = async (args,callback) => { 
    \n\tconst {error,result} = await ${method_name}_controller(args)
    \n\treturn callback(error,result)
    \n}
  "
  echo -e $method_code > $SERVICES_PATH/$service/methods/${method_name}_method.js
  echo $(print_message -i 'continue' -m 'Service' -s 'Method' -c 'Add' -t ''"$method_name"' > Method created')

  echo -e "const ${method_name}_method = require('./methods/${method_name}_method')\n$(cat $SERVICES_PATH/$service/router.js)" > $SERVICES_PATH/$service/router.js
  
  sed -i "/^module.exports = {/a\ \ ${method_name}: (args,callback) => ${method_name}_method(args, callback)," $SERVICES_PATH/$service/router.js

  echo $(print_message -i 'continue' -m 'Service' -s 'Method' -c 'Add' -t ''"$method_name"' > Route added')
  echo $(print_message -i 'end' -m 'Service' -s 'Method' -c 'Add' -t ''"$method_name"' Done')
fi

if [ "$1" == 'delete' ]; then
  while true; do
    echo $(print_message -w 'true' -i 'continue' -m 'Service' -s "$1" -c 'Method' -a "$2" -t 'Are you sure to delete this method? You will lose all code related of this method [y/n]')
    read yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) echo $(print_message -i 'end' -m 'Service' -s "$1" -c 'Method' -a "$2" -t 'Delete aborted'); exit;;
      * )  echo $(print_message -i 'continue' -m 'Service' -s "$2" -c 'Delete' -a 'Answer' -t 'Invalid! Please answer yes or no [y/n]');;    
    esac
  done
  method_name=$2

  rm -rf $SERVICES_PATH/$service/controllers/${method_name}_controller.js || true
  echo $(print_message -i 'continue' -m 'Service' -s 'Method' -c 'Delete' -t ''"$method_name"' > Controller deleted')
  rm -rf $SERVICES_PATH/$service/methods/${method_name}_method.js || true
  echo $(print_message -i 'continue' -m 'Service' -s 'Method' -c 'Delete' -t ''"$method_name"' > Method deleted')

  sed -i "/const ${method_name}_method = require('.\/methods\/${method_name}_method')/d" $SERVICES_PATH/$service/router.js
  sed -i "/\ \ ${method_name}: (args,callback) => ${method_name}_method(args, callback),/d" $SERVICES_PATH/$service/router.js

  echo $(print_message -i 'continue' -m 'Service' -s 'Method' -c 'Delete' -t ''"$method_name"' > Removed from router')
  echo $(print_message -i 'end' -m 'Service' -s 'Method' -c 'Delete' -t ''"$method_name"' Done')
fi