#!/bin/bash

# Define the region
region="us-east-1"

# Get a list of all AMIs owned by your account in the specified region
amis=$(aws ec2 describe-images --owners self --region $region --query 'Images[*].[ImageId,CreationDate,Name,Description]' --output text)

# Print the header
echo "AMI ID              Creation Date         Name                Description"
echo "-----------------------------------------------------------------------------------"

# Sort the AMIs by creation date and loop through each AMI
echo "$amis" | sort -k2 | while IFS=$'\t' read -r ami_id creation_date name description; do
    # Print the AMI ID, creation date, name, and description
    printf "%-20s %-20s %-20s %s\n" "$ami_id" "$creation_date" "$name" "$description"
done
