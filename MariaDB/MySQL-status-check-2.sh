#!/usr/bin/env bash
 
# Enable the MySQL service

echo "Enabling MySQL service..."

sudo systemctl enable mysql.service
 
# Start the MySQL service

echo "Starting MySQL service..."

sudo systemctl start mysql.service
 
# Function to check MySQL status

check_mysql_status() {

    status=$(sudo systemctl is-active mysql.service)

    echo "Current MySQL status: $status"

    if [ "$status" == "active" ]; then

        return 0

    else

        return 1

    fi

}



# # Check MySQL status immediately

# if check_mysql_status; then

#     echo "MySQL service is active."

#     exit 0

# fi
 
# # MySQL not active, wait for up to 30 minutes

# echo "Waiting for MySQL service to become active (up to 30 minutes)..."

# MAX_WAIT_TIME=$((30 * 60))  # 30 minutes in seconds

# START_TIME=$(date +%s)
 
# CURRENT_TIME=$(date +%s)

# ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
 
# if [ "$ELAPSED_TIME" -lt "$MAX_WAIT_TIME" ]; then

#     sleep $((MAX_WAIT_TIME - ELAPSED_TIME))
 
#     if check_mysql_status; then

#         echo "MySQL service is active."

#         exit 0

#     fi

# fi
 
# echo "MySQL did not become active within 30 minutes."
 
# # If MySQL is not active after 30 minutes, kill and restart the service

# echo "Killing MySQL service forcefully and starting it again..."

# sudo systemctl kill mysql.service
 
# # Start the MySQL service again

# sudo systemctl start mysql.service
 
# # Final status check

# if check_mysql_status; then

#     echo "MySQL service has been restarted and is now active."

#     exit 0

# else

#     echo "MySQL service is still not active after restart."

#     exit 1

# fi




# #  This script runs once


# MAX_WAIT_TIME=$((30 * 60))  # 30 minutes in seconds

# START_TIME=$(date +%s)

# # Wait for the maximum wait time
# sleep $MAX_WAIT_TIME

# # Check the MySQL status after waiting
# if check_mysql_status; then
#     echo "MySQL service is active."
#     exit 0
# else
#     echo "MySQL service is not active. Attempting to restart..."
#     sudo systemctl kill mysql.service
#     sudo systemctl start mysql.service
    
#     # Recheck the status after restarting
#     if check_mysql_status; then
#         echo "MySQL service successfully restarted and is active."
#         exit 0
#     else
#         echo "Failed to restart MySQL service."
#         exit 1
#     fi
# fi











MAX_WAIT_TIME=$((30 * 60))  # 30 minutes in seconds

# Wait for the maximum wait time
sleep $MAX_WAIT_TIME

# Check the MySQL status after waiting
if check_mysql_status; then
    echo "MySQL service is active."
    exit 0
else
    echo "MySQL service is not active. Attempting to restart..."
    sudo systemctl stop mysql
    sudo killall -9 mysqld
    sudo systemctl start mysql
    
    # Recheck the status after restarting
    if check_mysql_status; then
        echo "MySQL service successfully restarted and is active."
        exit 0
    else
        echo "Failed to restart MySQL service."
        exit 1
    fi
fi


