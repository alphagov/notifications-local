#!/usr/bin/env bash

repositories=('notifications-local' 'notifications-api' 'notifications-admin' 'notifications-template-preview' 'document-download-api' 'document-download-frontend' 'notifications-antivirus' 'notifications-utils' 'notifications-aws')
for repository in ${repositories[@]}; do
    if [ -d "../$repository" ]; then
        current_branch=$(cd ../$repository && git branch --show-current)
        if [ "$current_branch" = "main" ]; then
            echo "Pulling latest changes for $repository"
            (cd ../$repository && git pull)
        else
            echo "Skipping $repository (on branch: $current_branch)"
        fi
    else
        echo "Skipping $repository (directory not found)"
    fi
done
