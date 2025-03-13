#!/bin/bash

# Source the variables from the .vars file
. ./.vars

BACKUP_FILE=$1


# Check if all arguments are provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

# Restore the database
pg_restore -U $POSTGRES_USER -1 $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "Database restored successfully."
else
    echo "Failed to restore the database."
    exit 1
fi