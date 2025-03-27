#!/bin/bash

# Source the variables from the environment
. /etc/environment

# migrate
FILE=$1
DB_NAME=$2


createdb ${DB_NAME}
pgloader "$FILE" pgsql://${POSTGRES_USER}@localhost/${DB_NAME}


# Check if the migration was successful
if [[ $? -eq 0 ]]; then
    echo "Migration completed successfully."
else
    echo "Migration failed."
    exit 1
fi