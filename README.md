# notifications-local
A docker-compose file, and associated configuration, to run GOV.UK Notify locally in development mode.

This README needs some love and may not be in an intuitive order. Please read the entire document top-to-bottom before trying to set up your environment. Please update this README if you think something is missing, in the wrong place, or poorly described =)

## Initial setup

1) Clone this repository alongside your existing Notify repositories (if any).
    ```
    git@github.com:alphagov/notifications-local.git
    cd notifications-local
    ```

2) We need to have quite a few repositories checked out to run a full copy of GOV.UK Notify. A helper script is provided to make sure these are checked out locally (and check them out if they're not), then do some initial setup.

    Run this script:
    ```bash
    ./clone-repos.sh
    ```

3) Each of the services needs to have some environment variables defined. We have template .env files in the root of the repository a helper script automates generating real .env into the `./private` directory files from those templates, prompting for input as required. These should obviously never be committed and is excluded in `.gitignore`.

    You will need the full path of your checked-out credentials repository (cd to it and run `pwd`), your SQS queue prefix from `notifications-api/environment.sh`, and your AWS access key/secret key from `~/.aws/credentials` 
  
    Run this script and follow the instructions:
    ```bash
    ./generate-env-files.sh
    ```

5) Update your `/etc/hosts` file to handle DNS resolution for our local hostnames:

    ```bash
    echo "127.0.0.1       notify.localhost notify-api.localhost document-download-api.localhost document-download-frontend.localhost template-preview-api.localhost antivirus-api.localhost" | sudo tee -a /etc/hosts
    ```

4) This step is only required if you are switching to running GOV.UK Notify via docker-compose from the old way, where things were all run natively. To keep your local DB data, we need to copy it across to the docker DB service.
   1) Make sure local postgres service is running (on standard port 5432)
   2) Run `docker-compose up -d db` to start docker postgres.
   3) Run `psql postgresql://notify:notify@localhost:5433/postgres -c 'drop database notification_api; create database notification_api'`
   4) Run `pg_dump -d notification_api | psql postgresql://notify:notify@localhost:5433/notification_api` to copy local postgres to docker postgres
   5) If you login locally with yubikey, update your user's auth_type to email_auth temporarily: `psql postgresql://notify:notify@localhost:5433/notification_api -c "update users set auth_type='email_auth' where email_address='EMAIL_ADDRESS'"`
   6) Run `docker-compose down db`

## Running/accessing services

The default way to bring up a local version of GOV.UK Notify, after following setup, is to run `make up` from the root of this repository. This will start notify-api, notify-api-celery, notify-admin, template-preview-api, template-preview-celery, document-download-api, and document-download-preview, which will cover 95%+ of the things you need.

To also run and enable antivirus scanning, run `make antivirus up`. To run and enable celery-beat for regularly-scheduled tasks, run `make beat up`. These can be combined to `make beat antivirus up` to run *everything*.

### Accessing your local Notify services

Your GOV.UK Notify services are available at the following URLs:

 - notify-api: `http://notify-api.localhost:6011`
 - notify-admin: `http://notify.localhost:6012`
 - template-preview-api: `http://template-preview-api.localhost:6013`
 - antivirus-api: `http://antivirus-api.localhost:6016`
 - document-download-frontend: `http://document-download-frontend.localhost:7001`
 - document-download-api: `http://document-download-api.localhost:7000`

## Debugging containers

When running, the applications should all hot reload on code changes. This means you can add breakpoints into the code anywhere, and when that line is executed, the application will pause and start a debugger. To attach to the debugger you will need to open a separate terminal and run `docker attach <container>`, eg `docker attach notify-api`.

**Importantly**, to detach you should enter the control sequence Ctrl-P Ctrl-Q, **not Ctrl-C** which will kill the Flask app.

## Useful docker aliases

When using docker-compose to run GOV.UK Notify, you may fairly frequently need to interact with the docker containers, and so typing out standard docker commands in full every time can get a bit repetitive. These may be some useful aliases to set up:

```
alias dc='docker-compose'
alias da='docker attach'
alias de='docker exec -it'
```

For example, if you've added a breakpoint into one of the apps and you've triggered it, instead of typing `docker attach notify-admin` you can type `da notify-admin`. Or if you want a shell inside of one of the app containers to run arbitrary commands - eg install local utils, re-build frontend assets, etc - you can run `de notify-admin bash` instead of `docker exec -it notify-admin bash`.

# Todo

* Investigate antivirus-api slow startups
* Get frontend assets hot rebuilding for notify-admin and document-download-frontend. Until then, you can run `docker exec -it notify-admin npm run build` for an ad-hoc recompile, or `docker exec -it notify-admin npm run watch` to spin up a long-lived watcher process. Optionally add a `-d` flag to detach from the process and leave it running it the background. 
* Investigate amd/arm docker images for antivirus and template-preview
  * antivirus-celery The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested        0.0s
  * template-preview-api The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested    0.0s
  * antivirus-api The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested           0.0s
  * template-preview-celery The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested 0.0s

