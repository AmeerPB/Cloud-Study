#!/bin/bash

# Print a few blank lines for spacing
printf "\n\n\n"

# Header for the first section
echo "					Security Groups Not Using				 "
echo "-------------------------------------------------------------------------------------------"

# Get a list of all security groups
security_groups=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupName, GroupId]' --output text)

# Print the table header for all security groups
printf "%-50s %-50s\n" "Security Group Name" "Security Group ID"
echo "-------------------------------------------------------------------------------------------------------------------------------"

# Loop through each security group and display name and ID
while read -r group_name group_id; do
    printf "%-50s %-50s\n" "$group_name" "$group_id"
done <<< "$security_groups"

# Print a few blank lines for spacing
printf "\n\n\n\n\n"

# Header for the second section
echo "					Security Group Rules Open to Public 				     "
echo "-------------------------------------------------------------------------------------------------------------------------------"

# Run AWS CLI command to get security groups with open ports
open_ports=$(aws ec2 describe-security-groups \
    --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp == `0.0.0.0/0`]]]' \
    --output json)

# Print table header with adjusted headers for open ports
echo -e "Security Group Name\t\tSecurity Group ID\t\t\tSource\t\t\tPort"

# Extract relevant information, sort by port, and print for open ports
echo "$open_ports" | jq -r '.[] | {GroupName: .GroupName, GroupId: .GroupId, Permissions: .IpPermissions[]} | select(.Permissions.IpRanges[].CidrIp == "0.0.0.0/0") | [.GroupName, .GroupId, .Permissions.IpRanges[0].CidrIp, .Permissions.FromPort, .Permissions.ToPort] | @tsv' | awk -F '\t' '{ if ($4 == $5) printf "%-50s %-50s %-50s %-10s\n", $1, $2, $3, $4; else printf "%-50s %-50s %-50s %-10s-%s\n", $1, $2, $3, $4, $5 }' | sort -t$'\t' -k4n

# Print a few blank lines for spacing at the end
printf "\n\n\n\n\n"
