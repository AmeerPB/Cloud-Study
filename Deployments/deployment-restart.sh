#!/bin/bash
# This script scales the EKS node group from 0 to 2 and restarts the deployment when the nodes are ready.

# Scale the node group
eksctl scale nodegroup --cluster <cluster-name> --name <node-group-name> --nodes 2 --nodes-min 2 --nodes-max 2 --region <region-name>

# Sleep to allow for scaling actions to take effect
sleep 300

# Function to check if all nodes are ready
check_nodes_ready() {
    # Get the list of nodes in the node group
    nodes=$(kubectl get nodes -o json | jq -r '.items[] | select(.metadata.labels["eks.amazonaws.com/nodegroup"] == "node-group-IST-1") | .status.conditions[] | select(.type == "Ready") | .status')

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

# Restart the deployment
kubectl rollout restart deployment -n <namespace>

echo "Deployment in the '<namespace>' namespace has been restarted."
