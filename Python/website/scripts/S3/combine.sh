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

# Function to get the lifecycle policy of a bucket
get_bucket_lifecycle_policy() {
    bucket="$1"
    lifecycle_policy=$(aws s3api get-bucket-lifecycle-configuration --bucket "$bucket" --output text 2>/dev/null)
    if [[ -n "$lifecycle_policy" ]]; then
        echo "$lifecycle_policy"
    else
        echo "No lifecycle policy"
    fi
}

printf "\n\n\n"

# Print the table headers
printf "%-50s %-20s %-20s\n" "Bucket Name" "Public Status" "Lifecycle Policy"
echo "----------------------------------------------------------------------------------------------------"

# Get a list of S3 buckets
buckets=$(aws s3api list-buckets --query 'Buckets[*].[Name]' --output text)

# Loop through each bucket and display its public status and lifecycle policy
while read -r bucket; do
    public_status=$(check_bucket_public "$bucket")
    lifecycle_policy=$(get_bucket_lifecycle_policy "$bucket")
    printf "%-50s %-20s %-20s\n" "$bucket" "$public_status" "$lifecycle_policy"
done <<< "$buckets"
