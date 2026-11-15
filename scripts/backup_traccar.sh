#!/bin/bash
set -euo pipefail

BACKUP_DIR="/var/backups/traccar"
DATE=$(date -u +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/traccar_$DATE.sql.gz"
TEMP_FILE="${BACKUP_FILE}.tmp"

umask 077

mkdir -p "$BACKUP_DIR"

# Remove incomplete backups if the script fails
trap 'rm -f "$TEMP_FILE"' EXIT

# Back up Traccar using local MySQL socket authentication
mysqldump --no-defaults \
    --user=root \
    --protocol=socket \
    --single-transaction \
    --quick \
    --no-tablespaces \
    --set-gtid-purged=OFF \
    --databases traccar | gzip > "$TEMP_FILE"

# Verify compressed backup integrity
gzip -t "$TEMP_FILE"

# Publish completed backup atomically
mv "$TEMP_FILE" "$BACKUP_FILE"

# Keep backups for approximately 14 days
find "$BACKUP_DIR" \
    -type f \
    -name 'traccar_*.sql.gz' \
    -mtime +13 \
    -delete

echo "Backup completed: $BACKUP_FILE"
