#!/bin/bash

# Get a list of all S3 buckets
buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

echo "Bucket Name          Lifecycle Policy"
echo "-------------------------------------"

# Loop through each bucket
for bucket in $buckets; do
    # Get the lifecycle policy of the bucket
    lifecycle_policy=$(aws s3api get-bucket-lifecycle-configuration --bucket $bucket 2>/dev/null)
    
    # Check if the bucket has a lifecycle policy
    if [[ -n "$lifecycle_policy" ]]; then
        echo "$bucket          $lifecycle_policy"
    else
        echo "$bucket          No lifecycle policy"
    fi
done
