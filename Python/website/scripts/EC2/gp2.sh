#!/bin/bash

# Get EBS volumes with type GP2
gp2_volumes=$(aws ec2 describe-volumes \
    --filters Name=volume-type,Values=gp2 \
    --query 'Volumes[*].[VolumeId, AvailabilityZone, Size, VolumeType]' \
    --output json)

# Check if there are any GP2 volumes
if [[ -z $gp2_volumes ]]; then
    echo "No GP2 volumes found."
else
    # Print header for the table
    printf "%-20s | %-20s | %-10s | %-10s\n" "Volume ID" "Availability Zone" "Size (GB)" "Volume Type"
    printf "%-20s | %-20s | %-10s | %-10s\n" "--------------------" "--------------------" "----------" "-----------"

    # Loop through each GP2 volume and print its details in table format
    echo $gp2_volumes | jq -r '.[] | "\(.[0])|\(.[1])|\(.[2])|\(.[3])"' | while IFS='|' read -r volume_id availability_zone size volume_type; do
        printf "%-20s | %-20s | %-10s | %-10s\n" "$volume_id" "$availability_zone" "$size" "$volume_type"
    done
fi
