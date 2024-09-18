#!/bin/bash

# List of AWS regions to check
REGIONS=("us-east-2" "us-east-1" "us-west-1" "us-west-2" "af-south-1" "ap-east-1" "ap-south-2" "ap-southeast-3" "ap-southeast-4" "ap-south-1" "ap-northeast-3" "ap-northeast-2" "ap-southeast-1" "ap-southeast-2" "ap-northeast-1" "ca-central-1" "ca-west-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-south-1" "eu-west-3" "eu-south-2" "eu-north-1" "eu-central-2" "il-central-1" "me-south-1" "me-central-1" "sa-east-1" "us-gov-east-1" "us-gov-west-1")

# Calculate the start and end time for the last 30 days
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
START_TIME=$(date -u -d "30 days ago" +"%Y-%m-%dT%H:%M:%SZ")
PERIOD=3600  # Granularity in seconds (5 minutes = 300, 1 hour = 3600, 1 day = 86400)

# Function to check NAT Gateway usage in a specific region
check_nat_gateway_usage() {
    REGION=$1
    NAT_GATEWAY_ID=$2
    
    echo "Checking NAT Gateway $NAT_GATEWAY_ID in region $REGION..."

    # Fetch BytesOutToDestination metric
    METRIC_OUTPUT=$(aws cloudwatch get-metric-statistics \
        --region $REGION \
        --metric-name BytesOutToDestination \
        --start-time $START_TIME \
        --end-time $END_TIME \
        --period $PERIOD \
        --namespace AWS/NATGateway \
        --statistics Average \
        --dimensions Name=NatGatewayId,Value=$NAT_GATEWAY_ID)

    # Check if there are no Datapoints
    if [[ $(echo $METRIC_OUTPUT | jq '.Datapoints | length') -eq 0 ]]; then
        echo "NAT Gateway $NAT_GATEWAY_ID in region $REGION is unused and can be safely deleted."
    else
        echo "NAT Gateway $NAT_GATEWAY_ID in region $REGION has usage data and should not be deleted."
    fi
}

# Iterate over each region
for REGION in "${REGIONS[@]}"; do
    echo "Scanning region: $REGION"
    
    # List all NAT Gateway IDs in the specified region
    NAT_GATEWAY_IDS=$(aws ec2 describe-nat-gateways \
        --region $REGION \
        --query 'NatGateways[*].NatGatewayId' \
        --output text)

    # Iterate over each NAT Gateway ID and check its usage
    for NAT_GATEWAY_ID in $NAT_GATEWAY_IDS; do
        check_nat_gateway_usage $REGION $NAT_GATEWAY_ID
    done
done
