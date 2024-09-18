#!/bin/bash

# Get overprovisioned instance recommendations
overprovisioned_instances=$(aws compute-optimizer get-ec2-instance-recommendations \
    --filters name=Finding,values=Overprovisioned \
    --query 'instanceRecommendations[*].[instanceArn, instanceName, finding, findingReasonCodes]' \
    --output json)

# Check if there are any overprovisioned instances
if [[ -z $overprovisioned_instances ]]; then
    echo "No overprovisioned instances found."
else
    # Print header for the table
    printf "%-20s | %-20s | %-15s | %-40s\n" "Instance ID" "Instance Name" "Finding" "Finding Reason Codes"
    printf "%-20s | %-20s | %-15s | %-40s\n" "--------------------" "--------------------" "---------------" "----------------------------------------"

    # Loop through each instance and print its details in table format
    echo $overprovisioned_instances | jq -r '.[] | "\(.[0])|\(.[1])|\(.[2])|\(.[3])"' | while IFS='|' read -r arn name finding reasons; do
        instance_id=$(echo "$arn" | cut -d'/' -f2)
        printf "%-20s | %-20s | %-15s | %-40s\n" "$instance_id" "$name" "$finding" "$reasons"
    done
fi
