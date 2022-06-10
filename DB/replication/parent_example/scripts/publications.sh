#!/bin/bash
MODE=$1  ### IF YOU HAVE SUB FOLDER FOR ENVS LIKE: LOCAL/DEV/PRODUCTION
source /xxx/xxx/backend_parent_project/.envs/.${MODE}/.postgres ### ENVIROMENT VARIABLES OF POSTGRES CONNECTION

init_table="true"
if [ ! -z "$2" ]; then
  init_table=$2
else
  echo "YOU HAVE TO SPECIFY IF I HAVE TO INIT THE TABLE ON SLAVE_NODE!"
  exit
fi

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat < ../tables); do
  ./single-publication.sh $MODE $i false $init_table
done