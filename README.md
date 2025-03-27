# Postgres: Extension to Official Image Adding Creation of Multiple Users/DBs, Backup & Restore Functions


This Docker image extends the [official PostgreSQL](https://hub.docker.com/_/postgres) image to support the creation of multiple databases and users at startup, as well as automated backups with configurable retention policies and scheduling options. It is ideal for environments where multiple isolated databases are required, and regular backups are essential.


Available on Docker: [eyjo1/multi-postgres](https://hub.docker.com/r/eyjo1/multi-postgres)
Source on GitHub: [ey-jo/docker-postgres](https://github.com/ey-jo/docker-postgres)


## Still in Development
Things may break. If you notice something, feel free to open an issue on GitHub.


## Usage

### Environment Parameters
All [configurations](https://github.com/docker-library/docs/blob/master/postgres/README.md#environment-variables) from the official Postgres Image can be used here as well.

#### Required Parameters
- `POSTGRES_USER`: The username for the PostgreSQL superuser. Will be used as root and for all automated tasks. If not provided "root" will be used.

#### Optional Parameters
##### User and DB Creation
- `LIST_DATABASE`: A comma-separated list of databases to be created.
- `LIST_USER`: A comma-separated list of users to be created, corresponding to the databases listed in `LIST_DATABASE`.
- `LIST_PASSWORD`: An optional comma-separated list of passwords for the users listed in `LIST_USER`.

Leave all empty to create none. This is the default.\
The comma-separated lists must not contain spaces! Like in [examples](#example-usage).\
If used all lists must contain the same amount of items. The only exception being an empty `LIST_PASSWORD` to create Users without Passwords.\
The entire creation process can be found [here](create-multiple-postgresql-databases.sh).

##### Backups
Backups are disabled by default.
- `BACKUP_LIMIT`: The number of backups to keep before deleting the oldest one. Set to `0` to disable deletion of old backups. Default is `5`.
- `BACKUP_INTERVAL`: The number of days between each backup. Set to `0` to disable backups. Default is `0`.
- `BACKUP_HOUR`: The hour of time when the backup will be created. Must be between `0` and `23`. Default is `1`.
- `BACKUP_TIME_FORMAT`: Overwrites `BACKUP_INTERVAL` and `BACKUP_HOUR`. Use [cron syntax](https://docs.gitlab.com/ee/topics/cron/#cron-syntax).

The backup process is scheduled using cron. Either use `BACKUP_INTERVAL` and `BACKUP_HOUR` or set your own schedule using `BACKUP_TIME_FORMAT` to create the cronjob.

Backups are disabled by default.

## Volumes
In the same way as the official Postgres image, data of all databases are stored in `/var/lib/postgresql/data`.

Backups are placed in the `/backups` directory.

## Example Usage
### Docker Run Example

```sh
docker run -d \
    --name postgres \
    -p 5432:5432 \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=password \
    -e LIST_DATABASE=db1,db2 \
    -e LIST_USER=user1,user2 \
    -e LIST_PASSWORD=pass1,pass2 \
    -e BACKUP_LIMIT=5 \
    -e BACKUP_INTERVAL=1 \
    -e BACKUP_HOUR=2 \
    -v /path/to/data:/var/lib/postgresql/data \
    -v /path/to/backups:/backups \
    eyjo1/multi-postgres
```

### Docker Compose Example

```yaml
services:
  postgres:
    image: eyjo1/multi-postgres
    container_name: postgres
    ports:
      - 5432:5432
    environment:
      POSTGRES_USER: root
      POSTGRES_PASSWORD: password
      LIST_DATABASE: db1,db2
      LIST_USER: user1,user2
      LIST_PASSWORD: pass1,pass2
      BACKUP_LIMIT: 5
      BACKUP_INTERVAL: 1
      BACKUP_HOUR: 2
    volumes:
      - /path/to/data:/var/lib/postgresql/data
      - /path/to/backups:/backups
```

### Explanation

This configuration sets up a PostgreSQL instance with a root user named `root` and the password `password`. It creates two databases, `db1` and `db2`, each with a corresponding user, `user1` and `user2`, and their respective passwords, `pass1` and `pass2`. This setup is beneficial for environments where multiple isolated databases are required, allowing different users to access their respective databases securely.

The backup configuration ensures data safety by keeping the last 5 backups and running daily at 2 AM. This automated backup process helps in maintaining regular backups without manual intervention, providing a reliable way to restore data in case of any data loss or corruption. The use of environment variables makes it easy to customize the setup according to specific needs, enhancing flexibility and ease of deployment.