
# Back up of Step 11 and 12 from the ssm-start-vm.sh script


# Variables
AUTOMATION_DOCUMENT_NAME="NewRunbook"



# Step 11: Start an automation execution
echo "Starting an automation execution..."
AUTOMATION_EXECUTION_ID=$(aws ssm start-automation-execution --document-name $AUTOMATION_DOCUMENT_NAME --output text --region $REGION --query 'AutomationExecutionId')

if [ -z "$AUTOMATION_EXECUTION_ID" ]; then
    echo "Failed to start automation execution."
    exit 1
fi

echo "Automation execution started successfully with execution ID: $AUTOMATION_EXECUTION_ID."


# Step 12: Wait for the automation execution to complete
echo "Waiting for automation execution $AUTOMATION_EXECUTION_ID to complete..."
aws ssm wait automation-execution-completed --automation-execution-id $AUTOMATION_EXECUTION_ID --region $REGION

if [ $? -ne 0 ]; then
    echo "Automation execution failed or timed out."
    exit 1
fi

echo "Automation execution $AUTOMATION_EXECUTION_ID completed successfully."

