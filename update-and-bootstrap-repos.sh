#!/usr/bin/env bash

repositories=(
    'notifications-api' \
    'notifications-admin' \
    'notifications-template-preview' \
    'document-download-api' \
    'document-download-frontend' \
    'notifications-antivirus' \
    'notifications-utils'
)
not_on_main=()
do_build=false
full_line=$(printf '%*s' "${COLUMNS:-100}" '' | tr ' ' '-')

for arg in "$@"; do
    case "$arg" in
        --build)
            do_build=true
            ;;
    esac
done

echo "$full_line"
if [ "$do_build" = true ]; then
    echo "[info] Pulling and building docker containers for each repository"
else
    echo "[info] Pulling latest changes for each repository only (no build)"
fi

# Pull latest changes for each repository
for repository in ${repositories[@]}; do
    echo "$full_line"
    echo "[$repository] Pulling latest changes \n"
    (cd ../$repository && \
    current_branch=$(git rev-parse --abbrev-ref HEAD) && \
    if [ "$current_branch" != "main" ]; then
        echo "[$repository] Skipping: Not on main branch (repo: $repository, current branch: $current_branch)"
        exit 0
    fi && git fetch origin main && git pull) || {
        if [ $? -eq 0 ]; then
            not_on_main+=("$repository")
        else
            exit 1
        fi
    }
done

if [ "$do_build" = true ]; then
    # Build docker containers for each repository
    for repository in ${repositories[@]}; do
        echo "$full_line"
        echo "[$repository] Building docker container \n"
        (cd ../$repository && make bootstrap-with-docker) || {
            if [ $? -eq 0 ]; then
                not_on_main+=("$repository")
            else
                exit 1
            fi
        }
    done
fi

if [ ${#not_on_main[@]} -gt 0 ]; then
    echo ""
    echo "Skipped repos (not on main branch): ${not_on_main[*]}"
fi

echo "$full_line"

