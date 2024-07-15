#!/usr/bin/env bash


# Variables
INSTANCE_ID="i-xxxxxxxxxxxxx"  # Replace with your test1 instance ID
INSTANCE_2_ID="i-xxxxxxxxxxx"
VOLUME_ID="vol-xxxxxxxxxxx"  # Replace with your volume ID to snapshot
REGION="ap-south-1"                # Replace with your AWS region
DATE=$(date +'%Y%m%d-%H%M%S')
TAG_KEY="XXX"
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
 
# Step 8: Delete the snapshot
echo "Deleting the snapshot $SNAPSHOT_ID..."
aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID --region $REGION
 
if [ $? -ne 0 ]; then
    echo "Failed to delete snapshot $SNAPSHOT_ID."
    exit 1
fi
 
echo "Snapshot $SNAPSHOT_ID deleted successfully."

# Step 9: Stop the instance 2
echo "Stopping the instance $INSTANCE_2_ID..."
aws ec2 stop-instances --instance-ids $INSTANCE_2_ID --region $REGION
 
 
 
# Step 10: Wait for the instance to stop
aws ec2 wait instance-stopped --instance-ids $INSTANCE_2_ID --region $REGION
 
if [ $? -ne 0 ]; then
    echo "Instance stopping failed or timed out."
    exit 1
fi
 
echo "Instance $INSTANCE_2_ID stopped."
 
# Step 11: Detach the current root volume
echo "Detaching the current root volume..."
CURRENT_ROOT_VOLUME_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_2_ID --region $REGION --query "Reservations[].Instances[].BlockDeviceMappings[?DeviceName=='/dev/sda1'].Ebs.VolumeId" --output text)
 
if [ -z "$CURRENT_ROOT_VOLUME_ID" ]; then
    echo "Failed to find the current root volume."
    exit 1
fi
 
aws ec2 detach-volume --volume-id $CURRENT_ROOT_VOLUME_ID --region $REGION
 
# Step 12: Wait for the volume to detach
aws ec2 wait volume-available --volume-ids $CURRENT_ROOT_VOLUME_ID --region $REGION
 
if [ $? -ne 0 ]; then
    echo "Current root volume detaching failed or timed out."
    exit 1
fi
 
echo "Current root volume $CURRENT_ROOT_VOLUME_ID detached."
 
# Step 13: Attach the new volume to instance-2 as the root volume
echo "Attaching the new volume $NEW_VOLUME_ID as the root volume..."
aws ec2 attach-volume --volume-id $NEW_VOLUME_ID --instance-id $INSTANCE_2_ID --device /dev/sda1 --region $REGION
# step  12: Wait for the volume to attach
aws ec2 wait volume-in-use --volume-ids $NEW_VOLUME_ID --region $REGION
if [ $? -ne 0 ]; then
    echo "New volume attaching failed or timed out."
    exit 1
fi
echo "New volume $NEW_VOLUME_ID attached as the root volume."
 
# Step 14: Start the instance 2
echo "Starting instance $INSTANCE_2_ID..."
aws ec2 start-instances --instance-ids $INSTANCE_2_ID --region $REGION
 
# step 15:  Wait for the instance to start
aws ec2 wait instance-running --instance-ids $INSTANCE_2_ID --region $REGION
if [ $? -ne 0 ]; then
    echo "Instance $INSTANCE_2_ID failed to start or timed out."
    exit 1
fi
 
echo "Instance $INSTANCE_2_ID started successfully."

# Step 16: Removing host key entry
echo "Sleeping for 5 mins"
sleep 300
ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R "[X.X.4.34]:8288"
 
# Step 17: Backup the MySQL config file

ssh -v -o StrictHostKeyChecking=no -i $SSH_KEY_LOCATION $SERVER_USERNAME@$REPORT_SERVER_IP -p 8288 -- sudo mv /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.backup.$(date +%d%b%Y-%H%M) 
ssh -v -o StrictHostKeyChecking=no -i $SSH_KEY_LOCATION $SERVER_USERNAME@$REPORT_SERVER_IP -p 8288 -- sudo mv /etc/mysql/mariadb.conf.d/50-server-UAT /etc/mysql/mariadb.conf.d/50-server.cnf
 
 
# Step 18: Enable MySQL service
echo "Enabling MySQL service..."
ssh -v -o StrictHostKeyChecking=no -i $SSH_KEY_LOCATION $SERVER_USERNAME@$REPORT_SERVER_IP -p 8288 -- sudo systemctl enable mysql
 
 
# Step 19: Restart Instance-2
#ssh -v -o StrictHostKeyChecking=no -i $SSH_KEY_LOCATION $SERVER_USERNAME@$REPORT_SERVER_IP -p 8288 -- sudo reboot


# Step 20: Stop the instance 2
echo "Stopping the instance $INSTANCE_2_ID..."
aws ec2 stop-instances --instance-ids $INSTANCE_2_ID --region $REGION
 
 
 
# Step 21: Wait for the instance to stop
aws ec2 wait instance-stopped --instance-ids $INSTANCE_2_ID --region $REGION
 
if [ $? -ne 0 ]; then
    echo "Instance stopping failed or timed out."
    exit 1
fi
 
echo "Instance $INSTANCE_2_ID stopped."


# Step 22: Start the instance 2
echo "Starting instance $INSTANCE_2_ID..."
aws ec2 start-instances --instance-ids $INSTANCE_2_ID --region $REGION

# step 23:  Wait for the instance to start
aws ec2 wait instance-running --instance-ids $INSTANCE_2_ID --region $REGION
if [ $? -ne 0 ]; then
    echo "Instance $INSTANCE_2_ID failed to start or timed out."
    exit 1
fi

echo "Instance $INSTANCE_2_ID started successfully."