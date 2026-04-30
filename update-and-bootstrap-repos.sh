#!/usr/bin/env bash

repositories=('notifications-api' 'notifications-admin' 'notifications-template-preview' 'document-download-api' 'document-download-frontend' 'notifications-antivirus' 'notifications-utils')
not_on_main=()
for repository in ${repositories[@]}; do
    echo "Pulling latest changes for $repository"
    (cd ../$repository && \
    current_branch=$(git rev-parse --abbrev-ref HEAD) && \
    if [ "$current_branch" != "main" ]; then
        echo "Skipping: Not on main branch (repo: $repository, current branch: $current_branch)"
        exit 0
    fi && \
    git pull && make bootstrap-with-docker) || {
        if [ $? -eq 0 ]; then
            not_on_main+=("$repository")
        else
            exit 1
        fi
    }
done

if [ ${#not_on_main[@]} -gt 0 ]; then
    echo ""
    echo "Skipped repos (not on main branch): ${not_on_main[*]}"
fi
