FROM postgres:17.4

# Set root user credentials
ENV POSTGRES_USER="root"
ENV POSTGRES_DB=${POSTGRES_USER}

# Environment variables for multiple databases with users and passwords
# Comma-separated list of database names to be created during initialization
ENV LIST_DATABASE=""
ENV LIST_USER=""
ENV LIST_PASSWORD=""

# Directory where the backup files will be saved
ARG BACKUP_DIR="/backups"
# Directory to bind files to be migrated
ARG DB_DIR="/migrate"

# Days between backups
ENV BACKUP_INTERVAL=0
# Hour of the day the backup process will be executed
ENV BACKUP_HOUR=1
# Number of backup files to keep
ENV BACKUP_LIMIT=5

# Optional: custom cron schedule expression, if provided overwrites the BACKUP_INTERVAL and BACKUP_HOUR
# Expected format: "minute hour day month day-of-week"
ENV BACKUP_TIME_FORMAT=""


# Install cron and pgloader
RUN apt update -y && apt-get update -y && apt install -y cron && apt-get install -y pgloader && rm -rf /var/lib/apt/lists/*

# Create directories and files
RUN mkdir -p ${BACKUP_DIR}
RUN mkdir -p ${DB_DIR}

# Store environment variables in a file for the backup script
RUN echo "POSTGRES_USER=${POSTGRES_USER}" >> /etc/environment && \
    echo "BACKUP_DIR=${BACKUP_DIR}" >> /etc/environment && \
    echo "BACKUP_LIMIT=${BACKUP_LIMIT}" >> /etc/environment && \
    echo "DB_DIR=${DB_DIR}" >> /etc/environment


# Copy the backup script and make it executable
COPY db-scripts/backup.sh /usr/local/bin/backup
RUN chmod +x /usr/local/bin/backup
# Copy the restore script and make it executable
COPY db-scripts/restore.sh /usr/local/bin/restore
RUN chmod +x /usr/local/bin/restore
# Copy the migrate script and make it executable
COPY db-scripts/migrate.sh /usr/local/bin/migrate
RUN chmod +x /usr/local/bin/migrate

# Copy the script for creation of multiple users and databases
RUN mkdir -p /docker-entrypoint-initdb.d/
COPY create-multiple-postgresql-databases.sh /docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh
RUN chmod +x /docker-entrypoint-initdb.d/create-multiple-postgresql-databases.sh

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["postgres"]