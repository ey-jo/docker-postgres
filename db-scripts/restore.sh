#!/bin/bash

# Source the variables from the environment
. /etc/environment

BACKUP_FILE=$1


# Check if all arguments are provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# Restore the database
pg_restore -e -U "$POSTGRES_USER" -d postgres "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Database restored successfully."
else
    echo "Failed to restore the database."
    exit 1
fi