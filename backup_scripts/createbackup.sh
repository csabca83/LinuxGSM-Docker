#!/bin/bash

timestamp=$(date +%Y-%m-%d_%H-%M-%S)
main_path="/home/ubuntu/LinuxGSM-Docker"
bucket_name="cseregy_bucket"
bucket_folder="mcserver"

# Stop the mcserver Docker container
docker-compose down

# Create the tar.gz file
echo "Creating backup_${timestamp}.tar.gz from the directories in data..."
tar -czf $main_path/backup_$timestamp.tar.gz ./data/*
echo "backup_${timestamp}.tar.gz created!"

# Check the number of backups in the Oracle bucket
num_backups=$(oci os object list --bucket-name ${bucket_name} --prefix mcserver/backup_ | jq '.data | length')

# If there are more than 2 backups, delete the oldest backup
if [[ $num_backups -gt 1 ]]; then
  # Get the name of the oldest backup file
  echo "Found 2 backups!";
  oldest_backup=$(oci os object list --bucket-name ${bucket_name} --prefix ${bucket_folder}/backup_ --fields name,timeCreated | jq -r '.data | sort_by(.["time-created"]) | .[0].name')

  echo "Deleting the older one ${oldest_backup} ...";
  # Delete the oldest backup file
  oci os object delete --force --bucket-name $bucket_name --name $oldest_backup
  echo "${oldest_backup} deleted!";
fi

# Upload the backup file to Oracle Cloud Storage
oci os object put --bucket-name $bucket_name --file $main_path/backup_$timestamp.tar.gz --name $bucket_folder/backup_$timestamp.tar.gz

# Remove the backup file
echo "Removing local backup_${timestamp}.tar.gz ..."
rm $main_path/backup_$timestamp.tar.gz
echo "backup_${timestamp}.tar.gz removed!"

# Start docker again
docker-compose up -d