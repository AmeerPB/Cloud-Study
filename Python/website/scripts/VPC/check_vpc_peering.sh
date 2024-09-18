#!/bin/bash

# Ensure AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found. Please install and configure AWS CLI."
    exit 1
fi

# List of AWS regions to check
REGIONS=("us-east-2" "us-east-1" "us-west-1" "us-west-2" "af-south-1" "ap-east-1" "ap-south-2" "ap-southeast-3" "ap-southeast-4" "ap-south-1" "ap-northeast-3" "ap-northeast-2" "ap-southeast-1" "ap-southeast-2" "ap-northeast-1" "ca-central-1" "ca-west-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-south-1" "eu-west-3" "eu-south-2" "eu-north-1" "eu-central-2" "il-central-1" "me-south-1" "me-central-1" "sa-east-1" "us-gov-east-1" "us-gov-west-1")

# Ensure jq is installed for JSON parsing
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install jq."
    exit 1
fi

# Print the header of the table
printf "%-15s %-25s %-15s\n" "Region" "VPC Peering Connection ID" "Status"
printf "%-15s %-25s %-15s\n" "------" "--------------------------" "------"

# Iterate through each region and list VPC peering connections
for region in "${REGIONS[@]}"
do
    peering_connections=$(aws ec2 describe-vpc-peering-connections --region "$region" --query 'VpcPeeringConnections[*].{ID:VpcPeeringConnectionId,Status:Status.Code}' --output json 2>/dev/null)

    # Check if the command succeeded
    if [ $? -ne 0 ]; then
        # Skip this region if there was an error
        continue
    fi

    # Parse the JSON output and check the status
    echo "$peering_connections" | jq -r '.[] | "\(.ID) \(.Status)"' | while IFS= read -r line
    do
        id=$(echo $line | awk '{print $1}')
        status=$(echo $line | awk '{print $2}')
        printf "%-15s %-25s %-15s\n" "$region" "$id" "$status"
    done
done
