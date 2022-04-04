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
  echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Jobs' -c 'Arugment #1' -t 'command not parsed, available: add')
  exit
fi

if [ "$1" == 'add' ]; then
  if [ -z "$2" ]; then
    echo $(print_message -e 'true' -i 'end' -m 'Service' -s 'Jobs' -c 'Arugment #2' -t 'method name not parsed')
    exit
  fi
  job_name=$2

  mkdir -p $JOBS_PATH
  mkdir -p $JOBS_PATH/services

  if [ ! -f "$JOBS_PATH/services/$service.js" ]; then

    if [ -z "$3" ]; then
      master_mode=''
    else
      if [ "$3" == 'include_master' ]; then
        master_mode="\nconst { master_interface } = require('${MASTER_PATH}/master_interface.js')"
      fi
    fi

    job_code="
      const path = require('path');
      \nrequire('dotenv').config({ path: path.resolve('$ENV_PATH', '.env') }); // SUPPORT .ENV FILES
      \nconst { storage_$service } = require('$SERVICES_STORAGES/index.js')
      \nconst processCWD = process.cwd()
      \nprocess.chdir('$SERVICES_PATH/$service/model');
      \nconst { PrismaClient } = require('$SERVICES_PATH/$service/model/interface')
      \nconst interface = new PrismaClient()
      \nprocess.chdir(processCWD)
      ${master_mode}
      \nconst CronJob = require('cron').CronJob;
      \nconst TZ = Intl.DateTimeFormat().resolvedOptions().timeZone
      \n
      \nmodule.exports = {
      \n}
    "

    echo -e $job_code > $JOBS_PATH/services/$service.js
    echo $(print_message -i 'continue' -m 'Service' -s 'Job' -c 'Main File' -t 'Created')
  fi

  sed -i "/^module.exports = {/a\ \ $job_name: new CronJob('* * * * * *', () => {console.log('emailerJobs > ${job_name} > is Running!');}, null, true, TZ)," $JOBS_PATH/services/$service.js

  if [ ! -f "$JOBS_PATH/index.js" ]; then
    echo -e '' > $JOBS_PATH/index.js
  fi

  if grep -w "${service}Jobs" $JOBS_PATH/index.js; then
    echo $(print_message -i 'end' -m 'Service' -s 'Job' -c 'Add' -t ''"$job_name"' > Job Added')
  else
    sed -i "1i const ${service}Jobs = require('.\/services\/${service}.js')" $JOBS_PATH/index.js
    sed -i "$ a ${service}Jobs" $JOBS_PATH/index.js
    echo $(print_message -i 'end' -m 'Service' -s 'Job' -c 'Add' -t ''"$job_name"' > Job Added')
  fi
fi