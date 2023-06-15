# notifications-local
Run Notify locally

## Preparing env files

Each of the services needs to have some environment variables defined. We have template .env files in the root of the repository and the `./generate-env-files.sh` script will walk through collecting the required secrets and generating the correct files into the `private/` directory. This should obviously never be committed and is excluded in `.gitignore`.

* Run `./generate-env-files.sh` and follow the instructions.

## Copying existing local DB to new Docker DB

We've got the docker postgres DB exposed on non-standard port 5433 so that it doesn't interfere with any other local postgres you might already have running. Probably good to reconcile this at some point. Similar with redis which for docker is exposed on 6380 (standard port is 6379).

* Make sure local postgres service is running (on standard port 5432)
* Run `docker-compose up db -d` to start docker postgres.
* Run `psql postgresql://notify:notify@localhost:5433/postgres -c 'drop database notification_api; create database notification_api'`
* Run `pg_dump -d notification_api | psql postgresql://notify:notify@localhost:5433/notification_api` to copy local postgres to docker postgres
* Run `docker-compose down db`

