#!/bin/bash

# List of AWS regions to check
REGIONS=("us-east-2" "us-east-1" "us-west-1" "us-west-2" "af-south-1" "ap-east-1" "ap-south-2" "ap-southeast-3" "ap-southeast-4" "ap-south-1" "ap-northeast-3" "ap-northeast-2" "ap-southeast-1" "ap-southeast-2" "ap-northeast-1" "ca-central-1" "ca-west-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-south-1" "eu-west-3" "eu-south-2" "eu-north-1" "eu-central-2" "il-central-1" "me-south-1" "me-central-1" "sa-east-1" "us-gov-east-1" "us-gov-west-1")

# Function to check if AWS CLI is installed
check_aws_cli_installed() {
  if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Please install it before running this script."
    exit 1
  fi
}

# Function to list all EFS file systems in a region
list_efs_filesystems() {
  local region=$1
  aws efs describe-file-systems --region "$region" --query 'FileSystems[*].FileSystemId' --output text 2>/dev/null
}

# Function to check if an EFS file system has mount targets in a region
check_mount_targets() {
  local filesystem_id=$1
  local region=$2
  mount_targets=$(aws efs describe-mount-targets --region "$region" --file-system-id "$filesystem_id" --query 'MountTargets' --output text 2>/dev/null)

  if [ -z "$mount_targets" ]; then
    echo -e "$region\t$filesystem_id\tUnused"
  else
    echo -e "$region\t$filesystem_id\tIn Use"
  fi
}

# Main script execution
main() {
  check_aws_cli_installed

  # Print header for the table
  echo -e "Region\tFileSystemId\tStatus"

  # Loop through each region
  for region in "${REGIONS[@]}"; do
    # Get list of all EFS file systems in the region
    efs_filesystems=$(list_efs_filesystems "$region")

    # Check if the describe-file-systems command was successful
    if [ $? -eq 0 ]; then
      # Loop through each EFS file system and check for mount targets
      for filesystem_id in $efs_filesystems; do
        check_mount_targets "$filesystem_id" "$region"
      done
    else
      echo "Error accessing region $region or invalid credentials."
    fi
  done | column -t
}

# Run the main function
main
