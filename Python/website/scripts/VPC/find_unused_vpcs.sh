#!/bin/bash

# Function to check if a list is empty
function is_empty {
    if [ -z "$1" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# Get all VPC IDs
vpc_ids=$(aws ec2 describe-vpcs --query 'Vpcs[*].VpcId' --output text)

# Iterate through each VPC ID
for vpc_id in $vpc_ids; do
    echo "Listing resources for VPC: $vpc_id"
    echo "========================================"

    # EC2 Instances
    echo "EC2 Instances:"
    aws ec2 describe-instances --filters Name=vpc-id,Values=$vpc_id --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PrivateIpAddress,PublicIpAddress]' --output table

    # RDS Instances
    echo "RDS Instances:"
    aws rds describe-db-instances --query "DBInstances[?DBSubnetGroup.VpcId=='$vpc_id'].[DBInstanceIdentifier,DBInstanceClass,Engine,DBInstanceStatus,Endpoint.Address]" --output table

    # Lambda Functions
    echo "Lambda Functions:"
    aws lambda list-functions --query "Functions[?VpcConfig.VpcId=='$vpc_id'].[FunctionName,Runtime,LastModified]" --output table

    # Load Balancers (Classic)
    echo "Classic Load Balancers:"
    aws elb describe-load-balancers --query "LoadBalancerDescriptions[?VPCId=='$vpc_id'].[LoadBalancerName, DNSName, Instances[*].InstanceId]" --output table

    # Load Balancers (Application and Network)
    echo "Application and Network Load Balancers:"
    aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$vpc_id'].[LoadBalancerName, DNSName, State.Code, Type]" --output table

    # Print a separator between VPCs
    echo "========================================"
    echo
done
