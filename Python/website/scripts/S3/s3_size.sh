#!/bin/bash

# Get a list of all S3 buckets
buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

echo "Bucket Name          Total Size (MB)"
echo "------------------------------------"

# Loop through each bucket
for bucket in $buckets; do
    # Get the total size of the bucket in bytes
    total_size_bytes=$(aws s3api list-objects --bucket $bucket --output json --query "[sum(Contents[].Size)]" | jq '.[0]')
    
    # Convert bytes to megabytes
    total_size_mb=$(echo "scale=2; $total_size_bytes / 1024 / 1024" | bc)
    
    # Print bucket name and total size in megabytes
    printf "%-20s %s\n" "$bucket" "$total_size_mb MB"
done
