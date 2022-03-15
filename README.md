# PRISMA CLUSTER

Created with:[![Generic badge](https://img.shields.io/badge/prisma-3.10.0-blue.svg)](https://www.prisma.io/) [![Generic badge](https://img.shields.io/badge/yarn-1.22.10-cyan.svg)](https://yarnpkg.com/) [![Generic badge](https://img.shields.io/badge/npx-8.5.1-red.svg)](https://www.npmjs.com/package/npx) [![Generic badge](https://img.shields.io/badge/node-16.0.0-green.svg)](https://nodejs.org/it) [![Generic badge](https://img.shields.io/badge/dotenvcli-5.0.0-magenta.svg)](https://www.npmjs.com/package/dotenv-cli) [![Generic badge](https://img.shields.io/badge/docker-20.10.12-blue.svg)](https://www.docker.com/) [![Generic badge](https://img.shields.io/badge/dockercompose-2.3.3-blue.svg)](https://docs.docker.com/compose/) [![Generic badge](https://img.shields.io/badge/jayson-3.6.6-blue.svg)](https://github.com/tedeh/jayson) 
----------------------
## Disclaimer

Prisma Cluster is not officially Releated to Prisma.io , I named this project "Prisma Cluster" because it use the powerfull of Prisma's introspection and interfacing .

This project have the goal to make more "simple" make an Microservice infrastructure and use it with an RPC server to provide data. The same project is already pre-configured to be scalable in a Replication structure where this project has a slave DB from an exnternal Master.

The Repository will be updated everytime it's needed, the same project is released with Open Source License, The usage and configuration is your business.

## Example of 2 services
![Schermata del 2022-03-08 18-21-16](https://user-images.githubusercontent.com/36926081/157291288-3b59caa9-5b69-4c3e-b53e-f9bb39d6efd4.png)

----------------------

## Features
- [x] Service Creation
- [x] Service Removal
- [x] Service Local Migration
- [x] Service Dev/Prod Deploy
- [x] Backup System
- [x] Backup Rollback
- [x] Prisma Studio
- [x] Introspection
- [x] Postgress Replication pre-configured 
- [x] RPC Server using Jayson
- [ ] RPC Client using Jayson (Will be applied to API Server - resource external from this repository)
- [ ] Write documentation on "Quick Start"

## Global Requirements
- Node
- Docker
- Docker-Compose
- [Prisma](https://www.prisma.io/docs/concepts/components/prisma-cli/installation): `yarn global add prisma`
- Dotenv-cli: `yarn global add dotenv-cli`

## Workflow

```plaintext
┌─ Local Workflow
├─ do your yob
├─ migrate your changes to your local db using Prisma Cluster CLI
└─ test your changes
   ├─ push your changes in your own branch
   └─ at the task completation make a pull request to Development Branch, 
      if you removed some services specify it into Pull Request reporting the service's name deleted
      └─> Development Workflow
          ├─ Fetch changes
          ├─ run the global deploy (to apply all migrations changes) using Prisma Cluster CLI
          |  └─> if the devs deleted some services check it and apply the deleation manually using Prisma Cluster CLI
          └─ test
             └─ at the end of the test if stable make a pull request to Master branch
                └─> Production Workflow
                   ├─ Fetch changes
                   └─> run the global deploy (to apply all migrations changes) using Prisma Cluster CLI
                       └─> if the devs deleted some services check it and apply delete manually using Prisma Cluster CLI
   
```

## Project Tree
```plaintext
┌ prisma-cluster
├─ CLI
|  ├─ env
|  |  ├─ .blank.env
|  |  └─ .env                             (Not provided - copy blank.env and replace the values)
|  ├─ helpers
|  |  └─ text.sh
|  ├─ modules
|  |  ├─ backups
|  |  |  ├─ commands
|  |  |  |  ├─ create.sh
|  |  |  |  └─ rollback.sh
|  |  |  └─ backup.sh 
|  |  ├─ db
|  |  |  ├─ commands
|  |  |  |  ├─ fetch.sh
|  |  |  |  └─ import.sh
|  |  |  └─ db.sh
|  |  └─ services
|  |     ├─ commands
|  |     |  ├─ create.sh
|  |     |  ├─ delete.sh
|  |     |  ├─ deploy.sh
|  |     |  ├─ method.sh
|  |     |  ├─ migrate.sh
|  |     |  └─ studio.sh
|  |     └─ service.sh 
|  ├─ package.json
|  └─ rpc.sh
├─ DB
|  ├─ import
|  |  └─ [file-to-import].sql
|  ├─ replication                         (postgres replication slave mode config folder)
|  |  ├─ config 
|  |  |  ├─ blank.pg_hba.conf       
|  |  |  ├─ blank.postgresql.conf
|  |  |  ├─ pg_hba.conf                   (Not provided - copy blank.pg_hba.conf - be sure to fix the permission)
|  |  |  └─ postgresql.conf               (Not provided - copy blank.postgresql.conf - be sure to fix the permission)
|  |  ├─ env
|  |  |  ├─ .blank.env.replication
|  |  |  └─ .env                          (Not provided - copy blank.env.replication and replace the values)
|  |  ├─ scripts
|  |  |  └─ subscriptions
|  |  |     ├─ single-subscription.sh     (postgres make subscription script)
|  |  |     └─ supscriptions.sh           (postgres make subscriptions from file "tables" script)
|  |  ├─ MAKE_REPL_USER_SQL.sh
|  |  └─ Tables                           (list of tables in subscriptions to parent DB)
|  ├─ blank.docker-compose.replication.yml
|  ├─ docker-compose.replication.yml      (Not provided - copy blank.docker-compose.replication.yml and replace the values)
|  ├─ docker-compose.yml
|  └─ server.sh
├─ RPC  
|  ├─ node_modules                        (not provided - run yarn from this RPC folder)
|  ├─ services
|  |  └─ [service-name] * n
|  |     ├─ controller                    (rpc server functions)
|  |     ├─ method                        (rpc server methods)
|  |     ├─ model
|  |     |  ├─ interface                  (rpc model interface)
|  |     |  ├─ prisma
|  |     |  |  └─ schema.prisma           (prisma rpc model generator and migration handler)
|  |     |  └─ .gitignore
|  |     └─ routes                        (rpc server routing)
|  ├─ services-backups
|  |  └─ [dd/mm/YYYY_hh_mm_ss].tar.gz
|  ├─ services-deleted
|  |  └─ [service_name]
|  ├─ .gitignore
|  ├─ package.json
|  └─ server_rpc.js
├─ .gitignore
└─ README.md
```
## PRISMA CLUSTER CLI

- Locate `euroingro-services/CLI`
- From the folder run `yarn rpc [commands]`
- 
### Available commands:
- **SERVICE**
- - **Create**: ```yarn rpc service create [service-name]```
- - **Delete**: ```yarn rpc service delete [service-name]```
- - **Method**: ```yarn rpc service method [service-name] add [method-name]```
- - **Migrate**: ```yarn rpc service migrate [mode/service-name]```
- - - Specific Service: ```yarn rpc service migrate [service-name]```
- - - All Services: ```yarn rpc service migrate global```
- - **Deploy**: ```yarn rpc service deploy [mode/service-name]```
- - - Specific Service: ```yarn rpc service deploy [service-name]```
- - - All Services: ```yarn rpc service deploy global```
- **BACKUP**
- - **Create**: ```yarn rpc backup create```
- - **Rollback**: ```yarn rpc backup rollback [dd/mm/YYYY_hh_mm_ss]```
- **DB**
- - **Fetch**: ```yarn rpc db fetch [service-name]```
- - **Import**: ```yarn rpc db import [service-name] [file-to-import.sql]```

#### SERVICE > CREATE:
- Will create the service running automatically this actions:
- - Service Folder Structure under ```./services/[service-name]```
- - RPC Router injection in ```[root]/router.js```
- - Creation of [service-name] db into Postgress
- - Creation of user's db (ower of [service-name] db)
- - Saving of enviroment variables to link prisma to db created

#### SERVICE > DELETE:
- Will delete the service running automatically this actions:
- - Deletion of ```./services/[service-name]```
- - Deletion of [service-name] DB
- - Deletion of [service-name] DB's user
- - Deletion of enviroment variables related to [service-name] DB's user
- - Deletion of [service-name] router injection into RPC router ```[root]/router.js```
- - Create a deletion file under ```./services-deleted/' named with [service-name] and containing Operator's Name and Reason of deletion

#### SERVICE > METHOD:
- Will create the method of the service running automatically this actions:
- - Creation of [method-name] controller under ```./services/[service-name]/controllers/[method-name]_controller.js```
- - Creation of [method-name] method under ```./services/[service-name]/methods/[method-name]_method.js```
- - Injection of [method-name] into [service-name]'s router
- - Auto configuration of [method-name] controller with [service-name]'s model interface

#### SERVICE > MIGRATE:
- Apply schema changes to DB
- Make migration file

#### SERVICE > DEPLOY (MUST BE RUNNED ONLY ON DEV / PRODUCTION)
- Apply migrations to DB
- Loop the ```./services-deleted``` to check if some services must be deleted

#### SERVICE > STUDIO
- Will serve Prisma Studio for the target service on http://localhost:5555

#### BACKUP > CREATE:
- Will create a full dump of all DBs (Schema and Data
- Will create a Bk of current enviroment variables
- Will create a Bk of all current services controllers and routes
- Will zip the all previous points

#### BACKUP > ROLLBACK (ATTENTION ON USE IT):
- Will apply the backup you specifiend deletegin all services and databases to re-apply them from the backup

#### DB > IMPORT:
- Will run the sql file to the service's db, the file must be located under `/database/import`

#### DB > FETCH (ATTENTION ON USE IT):
- This command will fetch the entire database generating Prisma model, the usage scenario is when you need import structure from an already exist DB (so previously you used DB > Import) and then you need generate the model's interface, if you use it outside this scenario be carefull on generate conflicts with migrations

----------------------

## POSTGRES REPLICATION SLAVE MODE

### Quick Start

- From ```prisma-cluster/DB/replication/env``` make ```.env.replication``` from ```.blank.env.replication``` replacing the values
- Locate ```prisma-cluster/DB/replication/scripts``` and run ```MAKE_REPL_USER_SQL.sh``` this will generate ```00-Create_repl_user.sql``` under ```prisma-cluster/DB/replication/init```
- Locate ```prisma-cluster/DB/replication/config``` make ```pg_hba.conf``` and ```postgresql.conf``` from ```blank.pg_hba.conf``` and ```blank.postgresql.conf```
- Locate ```prisma-cluster/DB``` make ```docker-compose.replication.yml``` from ```blank.docker-compose.replication.yml``` and replace value
- Using ```prisma-cluster/DB/server.sh replication up --build -d``` (for the building and up) or ```./database/server.sh replication up -d``` (for the up) Docker will run Postgres with Replication's Configuration, fetched from ```prisma-cluster/DB/replication/config```.

#### If Docker return permission denied on conf files please be sure to fix the permission, example:
![image (1)](https://user-images.githubusercontent.com/36926081/158415349-13ad3194-49fd-45d0-ab66-187a8e820e76.jpg)

#### Concept
Considering the scenario of 2 Postgres Servers:

- First Server: MAIN data center (where you stored all your data like, users, orders, invoices or other kind of data)
- Second Server: Prisma Cluster Postgres Server (so this project)

In a scenario like that you need "move" the data from First Server to the Second, the Replication Mode allow you to run the Second Server in "Slave" mode ready to receive Publications from the First Server, you have just to configure some lines :P\

#### Configuration on First Server:

- Create the user will run the publications: ```sql CREATE ROLE [first-server-replication-user] REPLICATION LOGIN PASSWORD '[first-server-replication-user-password]';```
- Edit the ```pg_hba.conf``` (usually located in ```/var/lib/postgresql/data/```) adding: ```host    all             [POSTGRES_REPLICATION_USER from ./database/.env.replication]       slave_node              md5``` under IPv4 connections
- Edit the ```postgresql.conf``` enable ```wal_level``` and set it to ```logical```
- Make a host rule for ```slave_node``` and point it to this project host

#### Configuration Second Server (this project):
In ```prisma-cluster/DB/replication/env/env.replication``` apply:

- master_node: your First Server IP
- PARENT_REPLICATION_DB: the db's name contain the data into First Server
- PARENT_REPLICATION_USER: user will rul the publications on First Server
- PARENT_REPLICATION_PASSWORD: user's password will run the publication on First Server
- Under ```prisma-cluster/DB/replication/scripts``` run ```MAKE_REPL_USER_SQL.sh``` - This script will generate automatically the SQL to create replication user of this project

#### Creation of a publication (to run on First Server):

- From psql run  ```sql CREATE PUBLICATION [table-name]_pub FOR TABLE [table-name];``` - This will create the publication
- From psql run ```sql GRANT ALL ON [table-name] TO [first-server-replication-user];``` - This will grant the access
- From psql run ```sql pg_dump -U [first-server-root] [first-server-db] -t [table-name] -s | psql -U [POSTGRES_SLAVE_USER from ./database/.env.replication] -h slave_node``` this will apply the schema on slave server (this poject server)
- Now you can subscribe from the slave server 

#### Subscription (to run from Second Server)

- From ```prisma-cluster/DB/replication/scripts``` run ```single-subscription.sh [table-name]```


If you did everything right then will work XD



What do this script? The script will add the table to ```tables``` to keep track of tables subscribed, then generate the SQL of subscription under ```prisma-cluster/DB/replication/init``` in this way everytime the docker will be mounted will import the subscriptions if they not exist already, then if the docker container is running will directly invoke psql to generate the subscription