#!/bin/bash

# Get a list of all EC2 snapshots
snapshots=$(aws ec2 describe-snapshots --query 'Snapshots[*].[SnapshotId,StartTime]' --output text)

# Sort snapshots by creation time (ascending)
sorted_snapshots=$(echo "$snapshots" | sort -k 2)

echo "Snapshot ID       Creation Time"
echo "-------------------------------------"

# Loop through each sorted snapshot and print its ID and creation time
while read -r snapshot; do
    snapshot_id=$(echo "$snapshot" | awk '{print $1}')
    creation_time=$(echo "$snapshot" | awk '{$1=""; print $0}')
    echo "$snapshot_id    $creation_time"
done <<< "$sorted_snapshots"
