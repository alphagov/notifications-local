# notifications-local
Run Notify locally

## Requirements

All of the following repositories should be checked out in adjacent directories:

* [notifications-api](https://github.com/alphagov/notifications-api.git)
* [notifications-admin](https://github.com/alphagov/notifications-admin.git)
* [notifications-template-preview](https://github.com/alphagov/notifications-template-preview.git)
* [document-download-api](https://github.com/alphagov/document-download-api.git)
* [document-download-frontend](https://github.com/alphagov/document-download-frontend.git)
* [notifications-antivirus](https://github.com/alphagov/notifications-antivirus.git)
* [notifications-credentials](https://github.com/alphagov/notifications-credentials.git)

You can just run the `./clone-repos.sh` script if you have git+ssh configureed. This will importantly also run `make generate-version-file` in each repo, which is needed by most of the app dockerfiles.
### Pre Requisites

If you haven't run the clone repos above as you already had them downloaded, just make sure to generate the versions for these repos

`cd notifications-admin` and run `make generate-version-file` to get a vesrion file for the local build of notifications-admin
`cd notfications-api` and `make generate-version-file`
`cd notfications-template-preview` and `make generate-version-file`

## Running/accessing services

### Profiles

#### Default profile

Run `make up` to start Notify in the default profile.

This will not run the celery-beat worker for the main notify API, or the antivirus app.

We don't enable celery beat by default because it can generate a lot of log messages/spam to the service output, frustrating the developer experience.

We don't enable antivirus by default because it takes a long time to start up.

#### Enabling antivirus

Run `make antivirus up`.

This will make sure the antivirus-api and antivirus-celery tasks run, and set ANTIVIRUS_ENABLED on the appropriate apps.

#### Enabling celery-beat

Run `make beat up`

This will enable the notify-api-celery-beat worker.

#### Enabling both

These can be combined with `make beat antivirus up`

### Accessing your local Notify services

The services should all be accessed at `<service>.localhost:<port>` rather than just using `localhost:<port>`. In chromium-based browsers `.localhost` should automatically resolve to  the loopback address, but if it doesn't you will need to manually edit `/etc/hosts` to include each service address explicitly against `127.0.0.1`.

Example:
```
127.0.0.1       notify.localhost notify-api.localhost document-download-api.localhost document-download-frontend.localhost template-preview-api.localhost antivirus-api.localhost
```

Service list:
 - notify-admin: `notify.localhost:6012`
 - notify-api: `notify-api.localhost:6011`
 - document-download-frontend: `document-download-frontend.localhost:7001`
 - document-download-api: `document-download-api.localhost:7000`
 - template-preview-api: `template-preview-api.localhost:6013`
 - antivirus-api: `antivirus-api.localhost:6016`

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


# Todo

* Get local venvs inside containers so that we can edit/debug dependencies
* Work out breakpoints (probably rdb/equivalent)
* Investigate antivirus-api slow startups
* See if can get frontend assets hot rebuilding
* Investigate amd/arm docker images for antivirus and template-preview
  * antivirus-celery The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested        0.0s
  * template-preview-api The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested    0.0s
  * antivirus-api The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested           0.0s
  * template-preview-celery The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested 0.0s
