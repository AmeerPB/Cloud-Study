#!/usr/bin/env bash

# Variables
INSTANCE_ID="i-xxxxxxxxxxxxx"  # Replace with your test1 instance ID
INSTANCE_2_ID="i-xxxxxxxxxxx"
VOLUME_ID="vol-xxxxxxxxxxx"  # Replace with your volume ID to snapshot
REGION="ap-south-1"                # Replace with your AWS region
DATE=$(date +'%Y%m%d-%H%M%S')
TAG_KEY="UAT"
TAG_VALUE="Development"
REPORT_SERVER_IP="X.X.4.34"
SERVER_USERNAME="ubuntu"
SSH_KEY_LOCATION="/home/ubuntu/X/X.pem"



# Step 1: Create a snapshot of the volume
echo "Creating snapshot of volume $VOLUME_ID..."
SNAPSHOT_ID=$(aws ec2 create-snapshot --volume-id $VOLUME_ID --description "Snapshot of $VOLUME_ID from $INSTANCE_ID on $DATE" --query SnapshotId --output text --region $REGION)

 

if [ -z "$SNAPSHOT_ID" ]; then
    echo "Failed to create snapshot."
    exit 1
fi

 

echo "Snapshot $SNAPSHOT_ID created successfully."

 

 

# Step 2: Tag the snapshot
echo "Tagging snapshot $SNAPSHOT_ID..."
aws ec2 create-tags --resources $SNAPSHOT_ID --tags Key=Name,Value="Snapshot-$DATE" Key=$TAG_KEY,Value=$TAG_VALUE --region $REGION

 


# Step 3: Wait for the snapshot to complete
echo "Waiting for snapshot $SNAPSHOT_ID to complete..."
aws ec2 wait snapshot-completed --snapshot-ids $SNAPSHOT_ID --region $REGION

 

if [ $? -ne 0 ]; then
    echo "Snapshot creation failed or timed out."
    exit 1
fi

 

echo "Snapshot $SNAPSHOT_ID completed."

 

# Step 4: Determine the availability zone of the existing volume
echo "Determining the availability zone of the existing volume $VOLUME_ID..."
AVAILABILITY_ZONE=$(aws ec2 describe-volumes --volume-ids $VOLUME_ID --region $REGION --query "Volumes[0].AvailabilityZone" --output text)

 

if [ -z "$AVAILABILITY_ZONE" ]; then
    echo "Failed to determine the availability zone of the existing volume."
    exit 1
fi

 

echo "Existing volume $VOLUME_ID is in availability zone $AVAILABILITY_ZONE."

 

# Step 5: Create a new gp3 volume from the snapshot in the same availability zone
echo "Creating a new gp3 volume from snapshot $SNAPSHOT_ID in availability zone $AVAILABILITY_ZONE..."
NEW_VOLUME_ID=$(aws ec2 create-volume --snapshot-id $SNAPSHOT_ID --volume-type gp3 --availability-zone $AVAILABILITY_ZONE --query VolumeId --output text --region $REGION)

 

if [ -z "$NEW_VOLUME_ID" ]; then
    echo "Failed to create volume from snapshot."
    exit 1
fi

 

echo "New volume $NEW_VOLUME_ID created successfully from snapshot $SNAPSHOT_ID."

 

# Step 6: Tag the new volume
echo "Tagging new volume $NEW_VOLUME_ID..."
aws ec2 create-tags --resources $NEW_VOLUME_ID --tags Key=Name,Value="Volume-$DATE" Key=$TAG_KEY,Value=$TAG_VALUE --region $REGION

 
# Step 7: Wait for the new volume to become available
echo "Waiting for the new volume $NEW_VOLUME_ID to become available..."
aws ec2 wait volume-available --volume-ids $NEW_VOLUME_ID --region $REGION

 

if [ $? -ne 0 ]; then
    echo "New volume creation failed or timed out."
    exit 1
fi

 

echo "New volume $NEW_VOLUME_ID is now available."

# Step 8: Stop the instance 2
echo "Stopping the instance $INSTANCE_2_ID..."
aws ec2 stop-instances --instance-ids $INSTANCE_2_ID --region $REGION

 
# Wait for the instance to stop
aws ec2 wait instance-stopped --instance-ids $INSTANCE_2_ID --region $REGION

 

if [ $? -ne 0 ]; then
    echo "Instance stopping failed or timed out."
    exit 1
fi

 

echo "Instance $INSTANCE_2_ID stopped."

 

# Step 8.1: Change the instance type
echo "Changing the instance type of $INSTANCE_2_ID to r6a.2xlarge..."
aws ec2 modify-instance-attribute --instance-id $INSTANCE_2_ID --instance-type "{\"Value\": \"r6a.2xlarge\"}" --region $REGION
[ $? -ne 0 ] && log_and_exit "Failed to change the instance type."

 

echo "Instance type changed to r6a.2xlarge."

 
# Step 9: Detach the current root volume
echo "Detaching the current root volume..."
CURRENT_ROOT_VOLUME_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_2_ID --region $REGION --query "Reservations[].Instances[].BlockDeviceMappings[?DeviceName=='/dev/sda1'].Ebs.VolumeId" --output text)

 

if [ -z "$CURRENT_ROOT_VOLUME_ID" ]; then
    echo "Failed to find the current root volume."
    exit 1
fi

 

aws ec2 detach-volume --volume-id $CURRENT_ROOT_VOLUME_ID --region $REGION


# Wait for the volume to detach
aws ec2 wait volume-available --volume-ids $CURRENT_ROOT_VOLUME_ID --region $REGION

 

if [ $? -ne 0 ]; then
    echo "Current root volume detaching failed or timed out."
    exit 1
fi

 

echo "Current root volume $CURRENT_ROOT_VOLUME_ID detached."

 

# Step 10: Attach the new volume to instance-2 as the root volume
echo "Attaching the new volume $NEW_VOLUME_ID as the root volume..."
aws ec2 attach-volume --volume-id $NEW_VOLUME_ID --instance-id $INSTANCE_2_ID --device /dev/sda1 --region $REGION

 

# Wait for the volume to attach
aws ec2 wait volume-in-use --volume-ids $NEW_VOLUME_ID --region $REGION
if [ $? -ne 0 ]; then
    echo "New volume attaching failed or timed out."
    exit 1
fi
echo "New volume $NEW_VOLUME_ID attached as the root volume."

 

# Stop MySQL service forcefully
echo "Stopping MySQL service forcefully..."
sudo systemctl stop mysql

 

# Verify if MySQL stopped successfully
sudo systemctl status mysql

 
# Backup the original configuration file
sudo mv /etc/mysql/mariadb.conf/50-server.cnf /etc/mysql/mariadb.conf/50-server.bk$DATE

 

# Rename the UAT configuration file to the production configuration file
sudo mv /etc/mysql/mariadb.conf/50-server-uat /etc/mysql/mariadb.conf/50-server.cnf

 

# Stop the instance
echo "Stopping instance $INSTANCE_2_ID..."
aws ec2 stop-instances --instance-ids $INSTANCE_2_ID --region $REGION

 

# Wait for the instance to stop
aws ec2 wait instance-stopped --instance-ids $INSTANCE_2_ID --region $REGION
if [ $? -ne 0 ]; then
    echo "Instance $INSTANCE_2_ID failed to stop or timed out."
    exit 1
fi
echo "Instance $INSTANCE_2_ID stopped successfully."

 

# Change instance type from r6a.2xlarge to t3a.medium
echo "Changing instance type to t3a.medium..."
aws ec2 modify-instance-attribute --instance-id $INSTANCE_2_ID --instance-type "{\"Value\": \"t3a.medium\"}" --region $REGION

 

# Start the instance
echo "Starting instance $INSTANCE_2_ID..."
aws ec2 start-instances --instance-ids $INSTANCE_2_ID --region $REGION

 

# Wait for the instance to start
aws ec2 wait instance-running --instance-ids $INSTANCE_2_ID --region $REGION
if [ $? -ne 0 ]; then
    echo "Instance $INSTANCE_2_ID failed to start or timed out."
    exit 1
fi
echo "Instance $INSTANCE_2_ID started successfully."




ssh ubuntu@instance2 -- sudo mv /etc/mysql/mariadb.conf/50-server.cnf /etc/mysql/mariadb.conf/50-server.cnf.back$(date +%d%b%Y-%H%M)
ssh ubuntu@instance2 -- sudo mv /etc/mysql/mariadb.conf/50-server.cnf.bak /etc/mysql/mariadb.conf/50-server.cnf
 

# Enable MySQL service
echo "Enabling MySQL service..."
sudo systemctl enable mysql

 

# Start MySQL service
echo "Starting MySQL service..."
sudo systemctl start mysql

 

# Wait for MySQL service to be active
echo "Waiting for MySQL service to be active..."
sudo systemctl is-active --quiet mysql
while [ $? -ne 0 ]; do
    sleep 5
    sudo systemctl is-active --quiet mysql
done
echo "MySQL service is active."

 

echo "Setup complete."