#!/bin/bash

main_path="/home/ubuntu/LinuxGSM-Docker"
bucket_name="cseregy_bucket"
bucket_folder="mcserver"

# Download the newest backup file from Oracle Cloud Storage
newest_backup=$(oci os object list --bucket-name ${bucket_name} --prefix ${bucket_folder}/backup_ --fields name,timeCreated | jq -r '.data | sort_by(.["time-created"]) | .[-1].name')
echo "Selected backup is ${newest_backup}"
oci os object get --bucket-name $bucket_name --name $newest_backup --file backup.tar.gz

# Stop the Docker containers using docker-compose
docker-compose down

# Remove all the folders from the ~/LinuxGSM-Docker/data folder
echo "Removing current data folder ..."
sudo rm -rf data
echo "Current data folder removed!"

# Extract the downloaded tar.gz to the data folder
echo "Unzipping downloaded backup ..."
sudo tar -xzf $main_path/backup.tar.gz
echo "Downloaded backup is unzipped!"

# Delete the downloaded tar.gz file
echo "Removing backup.tar.gz ..."
sudo rm $main_path/backup.tar.gz
echo "backup.tar.gz removed!"

# Start the Docker containers using docker-compose
docker-compose up -d