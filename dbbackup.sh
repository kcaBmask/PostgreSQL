#!/bin/bash

############# Configurations
DB_NAME="dbname"
DB_USER="dbuser"
DB_PASSWORD="dbpass"
DB_HOST="dbhost"
BACKUP_DIR="/opt/adopisoft/dbbackup"
DATE=$(date +\%Y-\%m-\%d_\%H-\%M-\%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$DATE.sql"
RETENTION_DAYS=5  ##### Number of days to keep backups

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Create backup
export PGPASSWORD="$DB_PASSWORD"
pg_dump -h $DB_HOST -U $DB_USER -F c -b -v -f $BACKUP_FILE $DB_NAME

# Remove backups older than the specified retention period
find $BACKUP_DIR -type f -name "*.sql" -mtime +$RETENTION_DAYS -exec rm {} \;
