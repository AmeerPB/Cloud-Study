#!/bin/bash

# Get a list of all security groups
echo "Security Group Not using"
echo "------------------------"

security_groups=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupName, GroupId]' --output text)

# Print the table header for all security groups
printf "%-30s %-20s\n" "Security Group Name" "Security Group ID"
echo "-------------------------------------------------------------------------------------------------------------------------------"

# Loop through each security group and display name and ID
while read -r group_name group_id; do
    printf "%-30s %-20s\n" "$group_name" "$group_id"
done <<< "$security_groups"

echo ""
echo ""
echo "Security Group Rule that are open to Public "

# Run AWS CLI command to get security groups with open ports
open_ports=$(aws ec2 describe-security-groups \
    --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp == `0.0.0.0/0`]]]' \
    --output json)

# Print table header with adjusted headers for open ports
echo -e "GroupName\t\tGroupId\t\tSource\t\tPort"

# Extract relevant information, sort by port, and print for open ports
echo "$open_ports" | jq -r '.[] | {GroupName: .GroupName, GroupId: .GroupId, Permissions: .IpPermissions[]} | select(.Permissions.IpRanges[].CidrIp == "0.0.0.0/0") | [.GroupName, .GroupId, .Permissions.IpRanges[0].CidrIp, .Permissions.FromPort, .Permissions.ToPort] | @tsv' | awk -F '\t' '{ if ($4 == $5) print $1 "\t" $2 "\t" $3 "\t" $4; else print $0 }' | sort -t$'\t' -k4n
