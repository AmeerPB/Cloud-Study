#!/bin/bash

# Variables
INSTANCE_ID="i-XXXXXXXXXXXXX"  # Replace with your test1 instance ID
VOLUME_ID="vol-XXXXXXXXXXXXX"  # Replace with your volume ID to snapshot
REGION="ap-south-1"                # Replace with your AWS region
DATE=$(date +'%Y%m%d-%H%M%S')
TAG_KEY="XXX"
TAG_VALUE="Development"




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




# Step 8: Stop the instance
echo "Stopping the instance $INSTANCE_ID..."
aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION




# Wait for the instance to stop
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID --region $REGION

if [ $? -ne 0 ]; then
    echo "Instance stopping failed or timed out."
    exit 1
fi

echo "Instance $INSTANCE_ID stopped."




# Step 9: Detach the current root volume
echo "Detaching the current root volume..."
CURRENT_ROOT_VOLUME_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query "Reservations[].Instances[].BlockDeviceMappings[?DeviceName=='/dev/sda1'].Ebs.VolumeId" --output text)

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




# Step 10: Attach the new volume as the root volume
echo "Attaching the new volume $NEW_VOLUME_ID as the root volume..."
aws ec2 attach-volume --volume-id $NEW_VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sda1 --region $REGION




# Wait for the volume to attach
aws ec2 wait volume-in-use --volume-ids $NEW_VOLUME_ID --region $REGION

if [ $? -ne 0 ]; then
    echo "New volume attaching failed or timed out."
    exit 1
fi

echo "New volume $NEW_VOLUME_ID attached as the root volume."



# Step 11: Start the instance
echo "Starting the instance $INSTANCE_ID..."
aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION



# Wait for the instance to start
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

if [ $? -ne 0 ]; then
    echo "Instance starting failed or timed out."
    exit 1
fi

echo "Instance $INSTANCE_ID started."

# Output the details of the new volume
aws ec2 describe-volumes --volume-ids $NEW_VOLUME_ID --region $REGION

echo "Volume creation and attachment process completed successfully."