FROM postgres:17.3

# Set root user credentials
ENV POSTGRES_USER="root"
ENV POSTGRES_DB=${POSTGRES_USER}

# Environment variables for multiple databases with users and passwords
ENV LIST_DATABASE=""
ENV LIST_USER=""
ENV LIST_PASSWORD=""

# Directory where the backup files will be saved
ARG BACKUP_DIR="/backups"
# Directory where the scripts will be placed
ARG SCRIPT_DIR="/opt/scripts"

# Days between backups
ENV BACKUP_INTERVAL=0
# Hour of the day the backup process will be executed
ENV BACKUP_HOUR=1
# Number of backup files to keep
ENV BACKUP_LIMIT=5

# Optional: custom cron schedule expression, if provided overwrites the BACKUP_INTERVAL and BACKUP_HOUR
# Expected format: "minute hour day month day-of-week"
ENV BACKUP_TIME_FORMAT=""


# Install cron
RUN apt update -y && apt install -y cron

# Create backup directories and files
RUN mkdir -p ${BACKUP_DIR}
RUN mkdir -p ${SCRIPT_DIR}

# Store environment variables in a file for the backup script
RUN echo "POSTGRES_USER=${POSTGRES_USER}" > ${SCRIPT_DIR}/.vars && \
    echo "BACKUP_DIR=${BACKUP_DIR}" >> ${SCRIPT_DIR}/.vars && \
    echo "BACKUP_LIMIT=${BACKUP_LIMIT}" >> ${SCRIPT_DIR}/.vars

# Copy the backup script and make it executable
COPY scripts/backup.sh ${SCRIPT_DIR}/backup.sh
RUN chmod +x ${SCRIPT_DIR}/backup.sh

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create the users with corresponding databases
RUN mkdir -p /docker-entrypoint-initdb.d/
COPY create-multiple-postgresql-databases.sh /docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh
RUN chmod +x /docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["postgres"]