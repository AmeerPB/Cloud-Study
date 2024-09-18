#!/bin/bash

# Function to get last sign-in date for a user
get_last_signin_date() {
    user="$1"
    last_signin=$(aws iam get-user --user-name "$user" --query 'User.PasswordLastUsed' --output text)
    if [ "$last_signin" == "None" ]; then
        last_signin="Never"
        last_signin_timestamp=0
    else
        last_signin_timestamp=$(date -d "$last_signin" "+%s")
        last_signin=$(date -d "$last_signin" "+%Y-%m-%d")
    fi
    echo "$last_signin" "$last_signin_timestamp"
}

# Function to get MFA status for a user
get_mfa_status() {
    user="$1"
    mfa_status=$(aws iam list-mfa-devices --user-name "$user" --query 'MFADevices' --output text)
    if [ -z "$mfa_status" ]; then
        mfa_status="No"
    else
        mfa_status="Yes"
    fi
    echo "$mfa_status"
}

# Function to check if AdministratorAccess policy is attached
check_admin_access() {
    user="$1"
    admin_policy_arn="arn:aws:iam::aws:policy/AdministratorAccess"
    policies=$(aws iam list-attached-user-policies --user-name "$user" --query 'AttachedPolicies[].PolicyArn' --output text)
    if [[ "$policies" == *"$admin_policy_arn"* ]]; then
        admin_access="Yes"
    else
        admin_access="No"
    fi
    echo "$admin_access"
}

# Function to check if group has AdministratorAccess policy attached
check_group_admin_access() {
    group="$1"
    admin_policy_arn="arn:aws:iam::aws:policy/AdministratorAccess"
    attached_policies=$(aws iam list-attached-group-policies --group-name "$group" --query 'AttachedPolicies[].PolicyArn' --output text)
    if [[ "$attached_policies" == *"$admin_policy_arn"* ]]; then
        admin_access="Yes"
    else
        admin_access="No"
    fi
    echo "$admin_access"
}

# Function to display ongoing message with dots
display_ongoing_message() {
    while true; do
        printf "IAM audit is ongoing"
        for i in {1..3}; do
            printf "."
            sleep 0.5
        done
        printf "\r"
        printf "                   \r"  # Clear the line
    done
}

# Start the ongoing message in the background
display_ongoing_message &
ongoing_message_pid=$!

# Get a list of IAM users
users=$(aws iam list-users --query 'Users[*].UserName' --output text)

# Create an array to store user details
user_details=()

# Loop through each user and collect details
for user in $users; do
    last_signin_date_and_timestamp=$(get_last_signin_date "$user")
    last_signin_date=$(echo "$last_signin_date_and_timestamp" | awk '{print $1}')
    last_signin_timestamp=$(echo "$last_signin_date_and_timestamp" | awk '{print $2}')
    mfa_status=$(get_mfa_status "$user")
    admin_access=$(check_admin_access "$user")
    group_admin_access="No"
    
    # Get groups for the user
    groups=$(aws iam list-groups-for-user --user-name "$user" --query 'Groups[*].GroupName' --output text)
    for group in $groups; do
        group_admin_access=$(check_group_admin_access "$group")
        if [ "$group_admin_access" == "Yes" ]; then
            admin_access="Yes"
            break
        fi
    done
    
    # Append user details to the array
    user_details+=("$last_signin_timestamp $user $last_signin_date $mfa_status $admin_access")
done

# Sort the array based on the last sign-in timestamp
IFS=$'\n' sorted_user_details=($(sort -n <<<"${user_details[*]}"))
unset IFS

# Kill the ongoing message background process
kill $ongoing_message_pid

# Clear the ongoing message
printf "                   \r"

# Print the table header
printf "%-20s %-15s %-15s %-15s\n" "Username" "Last Sign-in" "MFA Status" "Admin Access"
echo "------------------------------------------------------------------------------------------------------------------------"

# Print the sorted user details
for user_detail in "${sorted_user_details[@]}"; do
    # Extract the user details from the sorted array
    last_signin_timestamp=$(echo "$user_detail" | awk '{print $1}')
    user=$(echo "$user_detail" | awk '{print $2}')
    last_signin_date=$(echo "$user_detail" | awk '{print $3}')
    mfa_status=$(echo "$user_detail" | awk '{print $4}')
    admin_access=$(echo "$user_detail" | awk '{print $5}')
    
    printf "%-20s %-25s %-25s %-25s\n" "$user" "$last_signin_date" "$mfa_status" "$admin_access"
done
