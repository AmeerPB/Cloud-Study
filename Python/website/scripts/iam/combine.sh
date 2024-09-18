#!/bin/bash

# Function to get last sign-in date for a user
get_last_signin_date() {
    user="$1"
    last_signin=$(aws iam get-user --user-name "$user" --query 'User.PasswordLastUsed' --output text)
    if [ "$last_signin" == "None" ]; then
        last_signin="Never"
    else
        last_signin=$(date -d "$last_signin" "+%Y-%m-%d")
    fi
    echo "$last_signin"
}

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

# Get a list of IAM users
users=$(aws iam list-users --query 'Users[*].UserName' --output text)

# Print the table header
printf "%-20s %-15s %-15s %-15s\n" "Username" 		"Last Sign-in" 		"MFA Status" "			Admin Access"
echo "------------------------------------------------------------------------------------------------------------------------"

# Loop through each user and display details
for user in $users; do
    last_signin=$(get_last_signin_date "$user")
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
    
    printf "%-20s %-25s %-25s %-25s\n" "$user" 		"$last_signin" 		"$mfa_status" 			"$admin_access"
done
