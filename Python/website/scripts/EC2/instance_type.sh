#!/bin/bash

# Function to print EC2 instance ID, name, and instance type
print_ec2_info() {
    # Get the list of EC2 instances
    ec2_instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],InstanceType]' --output text)

    if [ -z "$ec2_instances" ]; then
        echo "No EC2 instances found."
        return
    fi

    echo "EC2 Instance Information:"
    echo "========================"

    # Print header
    echo -e "\nInstance ID\tName\tInstance Type"
    echo -e "-----------\t----\t-------------"

    # Loop through EC2 instances, sort by instance type, and print information
    while IFS=$'\t' read -r instance_id name instance_type; do
        echo -e "$instance_id\t$name\t$instance_type"
    done <<< "$ec2_instances" | sort -k3,3 | column -t -s $'\t'
}

# Print EC2 instance information
print_ec2_info
