#!/usr/bin/env bash

# Variables
INSTANCE_ID="i-0d8d7dc32424335ab"  # Replace with your test1 instance ID
INSTANCE_2_ID="i-054dbc5e0fa6e94a8"
VOLUME_ID="vol-0b04424c1a61eac29"  # Replace with your volume ID to snapshot
REGION="us-west-1"                # Replace with your AWS region
DATE=$(date +'%Y%m%d-%H%M%S')
TAG_KEY="UAT"
TAG_VALUE="Development"
AUTOMATION_DOCUMENT_NAME="NewRunbook"
MAX_CHECK_TIME=600  # 600 seconds = 10 minutes
START_TIME=$(date +%s)
STATUS="pending"



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




# Step 9: Detach the current root volume
echo "Detaching the current root volume..."
CURRENT_ROOT_VOLUME_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_2_ID --region $REGION --query "Reservations[].Instances[].BlockDeviceMappings[?DeviceName=='/dev/xvda'].Ebs.VolumeId" --output text)

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




# Step 10: Attach the new volume to the instance-2 as the root volume
echo "Attaching the new volume $NEW_VOLUME_ID as the root volume..."
aws ec2 attach-volume --volume-id $NEW_VOLUME_ID --instance-id $INSTANCE_2_ID --device /dev/xvda --region $REGION




# Wait for the volume to attach
aws ec2 wait volume-in-use --volume-ids $NEW_VOLUME_ID --region $REGION

if [ $? -ne 0 ]; then
    echo "New volume attaching failed or timed out."
    exit 1
fi

echo "New volume $NEW_VOLUME_ID attached as the root volume."





# Step 11: Start an automation execution
echo "Starting an automation execution..."
AUTOMATION_EXECUTION_ID=$(aws ssm start-automation-execution --document-name $AUTOMATION_DOCUMENT_NAME --output text --region $REGION --query 'AutomationExecutionId')

if [ -z "$AUTOMATION_EXECUTION_ID" ]; then
    echo "Failed to start automation execution."
    exit 1
fi

echo "Automation execution started successfully with execution ID: $AUTOMATION_EXECUTION_ID."


# # Step 12: Wait for the automation execution to complete
# echo "Waiting for automation execution $AUTOMATION_EXECUTION_ID to complete..."
# aws ssm wait automation-execution-completed --automation-execution-id $AUTOMATION_EXECUTION_ID --region $REGION

# if [ $? -ne 0 ]; then
#     echo "Automation execution failed or timed out."
#     exit 1
# fi

# echo "Automation execution $AUTOMATION_EXECUTION_ID completed successfully."


# Step 12: Wait for the automation execution to complete
# This loop will check for a total of 10 minute and will exit automatically 
# Unless the exec status becoms "Success"

while [ "$STATUS" != "Success" ]; do
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

    if [ $ELAPSED_TIME -gt $MAX_CHECK_TIME ]; then
        echo "Maximum check time exceeded. Exiting."
        exit 1
    fi

    STATUS=$(aws ssm get-automation-execution --automation-execution-id $AUTOMATION_EXECUTION_ID --query 'AutomationExecution.AutomationExecutionStatus' --output text)
    
    if [ "$STATUS" == "Success" ]; then
        echo "Automation execution $AUTOMATION_EXECUTION_ID completed successfully."
    elif [ "$STATUS" == "TimedOut" ]; then
        echo "Automation execution $AUTOMATION_EXECUTION_ID timed out."
        exit 1
    else
        echo "Automation execution $AUTOMATION_EXECUTION_ID is $STATUS. Checking again in 1 minute..."
        sleep 60
    fi
done











