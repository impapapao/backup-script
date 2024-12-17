#!/bin/bash

# Variables
source_dir="$HOME/Documents/scripts/"
backup_dir="$HOME/Documents/backup/"
log_file="/var/log/backup.log"
current_date=$(date +'%Y-%m-%d_%H-%M-%S')
backup_name="backup_${current_date}.tar.gz"

# Log function
log() {
	echo "$(date)] $1" | tee -a "$log_file"
}
# Checking for backup directory
if [[ ! -d "$backup_dir" ]]; then
	log "Backup directory does not exist. Creating it..."
	mkdir -p "$backup_dir" || { log "Failed to create backup directory!"; exit 1; }
fi

# Creating backup
log "Starting backup of $source_dir to $backup_dir/$backup_name..."
if tar -czf "$backup_dir/$backup_name" "$source_dir" 2>>"$log_file"; then
	log "Backup completed successfully: $backup_name"
else
	log "Backup failed!"
	exit 1
fi

# Deleting old backup
log "Cleaning up old backup..."
find "$backup_dir" -type f -name "*.tar.gz" -mtime +30 -exec rm -f {} \; 2>>"$log_file"


# Function to Maintain 3 backups only
rotation_backup() {
    log "Maintaining only the latest 3 backups..."

    # Populate backups array using safer method
    backups=($(find "$backup_dir" -type f -name "backup_*.tar.gz" | sort -r))

    # Debugging: Print array content
    log "Backups found: ${backups[@]}"

    # If more than 3 backups exist, delete the oldest
    if [[ ${#backups[@]} -gt 3 ]]; then
        log "Found ${#backups[@]} backups. Removing older ones..."

        for ((i=3; i<${#backups[@]}; i++)); do
            rm -f "${backups[$i]}" && log "Removed old backup: ${backups[$i]}"
        done
    else
        log "Only ${#backups[@]} backups found. No cleanup needed."
    fi
}

# Main
rotation_backup

log "Backup script completed."
exit 0

