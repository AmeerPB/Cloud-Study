#!/bin/bash

# Function to check stopped instances and their launch time
check_stopped_instances() {
    # Get list of stopped instances
    stopped_instances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped --query 'Reservations[*].Instances[*].{ID:InstanceId,LaunchTime:LaunchTime}' --output text)
    
    if [ -z "$stopped_instances" ]; then
        echo "No stopped instances found."
        return
    fi
    
    echo "Stopped Instances:"
    echo "=================="
    
    # Print header
    echo "Instance ID  |  Launch Time"
    echo "----------------------------------------"
    
    # Loop through stopped instances
    while read -r instance_info; do
        instance_id=$(echo "$instance_info" | awk '{print $1}')
        launch_time=$(echo "$instance_info" | awk '{$1=""; print $0}')
        printf "%-12s |  %s\n" "$instance_id" "$launch_time"
    done <<< "$stopped_instances" | sort -k3
}

# Check stopped instances and sort based on launch time
check_stopped_instances | column -t -s '|'
