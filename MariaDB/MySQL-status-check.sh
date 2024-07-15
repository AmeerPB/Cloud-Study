#!/usr/bin/env bash
 
# Enable the MySQL service

echo "Enabling MySQL service..."
sudo systemctl enable mysql.service
 

# Start the MySQL service forcefully

echo "Starting MySQL service forcefully..."
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





 
# # Wait for MySQL to become active

# echo "Checking MySQL status until it becomes active (max 30 mins)..."

# START_TIME=$(date +%s)

# MAX_WAIT_TIME=$((30 * 60)) # 30 minutes in seconds
 
# while true; do

#     if check_mysql_status; then

#         echo "MySQL service is active."

#         exit 0

#     fi

#     CURRENT_TIME=$(date +%s)

#     ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
 
#     if [ "$ELAPSED_TIME" -ge "$MAX_WAIT_TIME" ]; then

#         echo "MySQL did not become active within 30 minutes."

#         echo "Killing MySQL service forcefully and starting it again..."
 
#         # Kill the MySQL service forcefully

#         sudo systemctl kill mysql.service
#         sleep 600
#         # Start the MySQL service forcefully

#         sudo systemctl start mysql.service
 
#         # Reset the start time

#         START_TIME=$(date +%s)

#     fi
 
#     # Wait for a few seconds before checking again

#     sleep 5

# done

 

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




