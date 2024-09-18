#!/bin/bash

# Run AWS CLI command and format output to table
aws_output=$(aws ec2 describe-security-groups \
    --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp == `0.0.0.0/0`]]]' \
    --output json)

# Print table header with adjusted headers
echo -e "GroupName\t\tSource\t\tPort"

# Extract relevant information and print
echo "$aws_output" | jq -r '.[] | {GroupName: .GroupName, Permissions: .IpPermissions[]} | select(.Permissions.IpRanges[].CidrIp == "0.0.0.0/0") | [.GroupName, .Permissions.IpRanges[0].CidrIp, .Permissions.FromPort, .Permissions.ToPort] | @tsv' | awk -F '\t' '{ if ($3 == $4) print $1 "\t" $2 "\t" $3; else print $0 }'
