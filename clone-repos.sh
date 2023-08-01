#!/usr/bin/env bash

repositories=('notifications-api' 'notifications-admin' 'notifications-template-preview' 'document-download-api' 'document-download-frontend' 'notifications-antivirus')
for repository in ${repositories[@]}; do
    (cd .. && git clone "git@github.com:alphagov/$repository")
    (cd ../$repository && make generate-version-file)
done
