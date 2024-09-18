#!/bin/bash

# Get a list of all EC2 snapshots
snapshots=$(aws ec2 describe-snapshots --query 'Snapshots[*].[SnapshotId,StartTime]' --output text)

echo "Snapshot ID        Created Time"
echo "-----------------------------------"

# Loop through each snapshot
while IFS=$'\t' read -r snapshot_id start_time; do
    # Format the start time to display human-readable time
    formatted_start_time=$(date -d $start_time +'%Y-%m-%d %H:%M:%S')

    # Print the snapshot ID and created time
    printf "%-20s %s\n" "$snapshot_id" "$formatted_start_time"
done < <(echo "$snapshots" | sort -k2)
