#!/bin/bash
source ../../../CLI/env/.env
source ../env/.env.replication

echo "CREATE USER $POSTGRES_REPLICATION_USER WITH ENCRYPTED PASSWORD '$POSTGRES_REPLICATION_PASSWORD';" > ../init/00-Create_repl_user.sql
echo "GRANT ALL PRIVILEGES ON DATABASE master TO $POSTGRES_REPLICATION_USER;" >> ../init/00-Create_repl_user.sql