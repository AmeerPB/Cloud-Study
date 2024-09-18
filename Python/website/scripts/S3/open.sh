#!/bin/bash

# Function to check if the bucket is public
check_bucket_public() {
    bucket="$1"
    is_public=$(aws s3api get-bucket-acl --bucket "$bucket" --query 'Grants[?Grantee.URI==`http://acs.amazonaws.com/groups/global/AllUsers` && Permission==`READ`]' --output text)
    if [[ -n "$is_public" ]]; then
        echo "Public"
    else
        echo "Private"
    fi
}

# Print the table header
printf "%-50s %-20s\n" "Bucket Name" "Public Status"
echo "----------------------------------------------------------------------------------------------------"

# Get a list of S3 buckets
buckets=$(aws s3api list-buckets --query 'Buckets[*].[Name]' --output text)

# Loop through each bucket and display its public status
while read -r bucket; do
    public_status=$(check_bucket_public "$bucket")
    printf "%-50s %-20s\n" "$bucket" "$public_status"
done <<< "$buckets"
