#!/bin/bash

# Fetch all Elastic IPs
elastic_ips=$(aws ec2 describe-addresses --query 'Addresses[*].[PublicIp,InstanceId,NetworkInterfaceId,AssociationId]' --output json)

# Initialize counters
unused_ips=0
used_ips=0

# Initialize arrays for used and unused IPs
unused_ips_list=()
used_ips_list=()

# Check for unused Elastic IPs
for ip in $(echo "$elastic_ips" | jq -c '.[]'); do
    public_ip=$(echo "$ip" | jq -r '.[0]')
    instance_id=$(echo "$ip" | jq -r '.[1]')
    network_interface_id=$(echo "$ip" | jq -r '.[2]')
    association_id=$(echo "$ip" | jq -r '.[3]')

    if [ "$instance_id" == "null" ] && [ "$network_interface_id" == "null" ] && [ "$association_id" == "null" ]; then
        ((unused_ips++))
        unused_ips_list+=("$public_ip")
    else
        ((used_ips++))
        used_ips_list+=("$public_ip")
    fi
done

# Print unused Elastic IPs table
echo "Unused Elastic IPs:"
printf "%-20s\n" "Elastic IP"
printf "%-20s\n" "----------"
for ip in "${unused_ips_list[@]}"; do
    printf "%-20s\n" "$ip"
done
echo "---------------------------------"
printf "%-20s %d\n" "Total Unused Elastic IPs:" "$unused_ips"
echo "---------------------------------"
echo

# Print used Elastic IPs table
echo "Used Elastic IPs:"
printf "%-20s\n" "Elastic IP"
printf "%-20s\n" "----------"
for ip in "${used_ips_list[@]}"; do
    printf "%-20s\n" "$ip"
done
echo "---------------------------------"
printf "%-20s %d\n" "Total Used Elastic IPs:" "$used_ips"
echo "---------------------------------"
