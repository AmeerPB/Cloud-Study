#!/bin/bash

# Function to get last sign-in time for a user
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

# Get a list of IAM users
users=$(aws iam list-users --query 'Users[*].UserName' --output text)

# Create an array to store user and last sign-in date
declare -A users_last_signin

# Loop through each user and get last sign-in date
for user in $users; do
    last_signin=$(get_last_signin_date "$user")
    users_last_signin["$user"]=$last_signin
done

# Print the table header
printf "%-20s %-20s\n" "Username" "Last Sign-in"
echo "--------------------------------------------"

# Print the table content
for user in "${!users_last_signin[@]}"; do
    printf "%-20s %-20s\n" "$user" "${users_last_signin[$user]}"
done | sort -k2,2
