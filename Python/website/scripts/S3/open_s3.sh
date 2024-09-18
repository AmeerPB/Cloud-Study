#!/bin/bash

# Get a list of all S3 buckets
buckets=$(aws s3api list-buckets --query "Buckets[*].Name" --output text)

# Print table header
printf "%-40s %-20s\n" "Bucket Name" "Block All Public Access"

# Loop through each bucket
for bucket in $buckets; do
    # Get block public access configuration
    block_all_public_access=$(aws s3api get-public-access-block --bucket "$bucket" --query "BlockPublicAcls" --output text)
    
    # Print bucket name and block all public access status
    printf "%-40s %-20s\n" "$bucket" "$block_all_public_access"
done
