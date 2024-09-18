#!/bin/bash

# Function to get MFA status for a user
get_mfa_status() {
    user="$1"
    mfa_status=$(aws iam list-mfa-devices --user-name "$user" --query 'MFADevices' --output text)
    if [ -z "$mfa_status" ]; then
        mfa_status="Not Enabled"
    else
        mfa_status="Enabled"
    fi
    echo "$mfa_status"
}

# Get a list of IAM users
users=$(aws iam list-users --query 'Users[*].UserName' --output text)

# Print the table header
printf "%-20s %-20s\n" "Username" "MFA Status"
echo "--------------------------------------------"

# Loop through each user and get MFA status
for user in $users; do
    mfa_status=$(get_mfa_status "$user")
    printf "%-20s %-20s\n" "$user" "$mfa_status"
done
