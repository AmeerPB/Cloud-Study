#!/bin/bash

# This script scales the node group from 0 to 2 and restarts the specified deployments when the nodes are ready.

# Scale the node group
eksctl scale nodegroup --cluster <cluster name> --name <NodeGroup name> --nodes 2 --nodes-min 2 --nodes-max 2 --region ap-south-1

# Sleep to allow for scaling actions to take effect
sleep 300

# Function to check if all nodes are ready
check_nodes_ready() {
    # Get the list of nodes in the node group
    nodes=$(kubectl get nodes -o json | jq -r '.items[] | select(.metadata.labels["eks.amazonaws.com/nodegroup"] == "<NodeGroup name>") | .status.conditions[] | select(.type == "Ready") | .status')

    # Check if all nodes have the status "True"
    for node in $nodes; do
        if [ "$node" != "True" ]; then
            return 1
        fi
    done
    return 0
}

# Loop until all nodes are ready
while true; do
    if check_nodes_ready; then
        echo "All nodes are ready."
        break
    else
        echo "Waiting for nodes to be ready..."
        sleep 180  # Wait for 180 seconds before checking again
    fi
done

# List of deployments to restart
deployments=(
    "1-service"
    "2-service"
    "3-service"
    "4-service"
    "5-service"
    "6-service"
)

# Restart the specified deployments
for deployment in "${deployments[@]}"; do
    kubectl rollout restart deployment "$deployment" -n api
    echo "Deployment $deployment in the 'api' namespace has been restarted."
done

echo "All specified deployments have been restarted."
 