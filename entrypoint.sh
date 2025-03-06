#!/bin/bash
set -e

# Set up the cron job for backups
if [ -n "$BACKUP_TIME_FORMAT" ]; then
    echo "${BACKUP_TIME_FORMAT} ${SCRIPT_DIR}/backup.sh" > /cronjob.txt
    crontab /cronjob.txt
elif [ "$BACKUP_INTERVAL" -ne 0 ]; then
    echo "0 ${BACKUP_HOUR} */${BACKUP_INTERVAL} * * ${SCRIPT_DIR}/backup.sh" > /cronjob.txt
    crontab /cronjob.txt
fi

# Start cron service
service cron start

# Execute the original entrypoint of the postgres image
exec docker-entrypoint.sh "$@"