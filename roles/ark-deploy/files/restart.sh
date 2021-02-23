#!/bin/bash

# Necessary variables.
now=`date +"%Y-%m-%d_%H%M%S"`
service="ark"
# How many minutes to delay server restart.
delay=10
# Time in seconds for delay interval
sleeptime=60

# RCON Parameters
rcon_path="/arkserver/tools/rcon"
rcon_ip="127.0.0.1"
rcon_port=24092
rcon_pass="SrX.4355\!123\!"

# ARK specific folders.
ark_data="/arkserver/ShooterGame/Saved"
ark_backup="/arkserver/backup"
retention_days=3

# Announce every 60 seconds for shutdown.
until [ $delay == 0 ]
do
  rcon_cmd="$rcon_path -a$rcon_ip -p$rcon_port -P$rcon_pass broadcast Server is going to restart in $delay minutes."
  eval $rcon_cmd
  ((delay--))
  sleep $sleeptime
done

# Force server to write current world to disk.
rcon_cmd="$rcon_path -a$rcon_ip -p$rcon_port -P$rcon_pass saveworld"
eval $rcon_cmd

# Stop the server.
systemctl stop $service

# Check if the backup directory exists. If not, create it.
if [ ! -d $ark_backup ]; then
  echo "Directory does not exist: $ark_backup"
  echo "Creating..."
  mkdir $ark_backup
fi

# Remove any files out of the backup directory older than the specified days to retain.
echo "Removing backup files older than $retention_days days."
find $ark_backup -maxdepth 1 -type f -mtime +$retention_days -exec rm {} \;

# Backup ark data to backup folder.
tar -zcvf "$ark_backup/ark_backup_daily_$now.tar.gz" $ark_data

# Start the server.
systemctl start $service
