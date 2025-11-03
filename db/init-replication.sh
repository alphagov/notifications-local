#!/bin/bash
set -e

echo "Appending replication settings to pg_hba.conf..."

# This adds the replication rule to the end of pg_hba.conf
# This script is run by the entrypoint after pg_hba.conf is created.
echo 'host replication notify 0.0.0.0/0 md5' >> "$PGDATA/pg_hba.conf"
