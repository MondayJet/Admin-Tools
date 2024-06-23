#!/bin/bash

# Declare an associative array with subscription names as keys and subscription IDs as values
declare -A subscriptions=(
    ["SubscriptionName1"]="SubscriptionId1"
    ["SubscriptionName2"]="SubscriptionId2"
    ["SubscriptionName3"]="SubscriptionId3"
    # Add more subscriptions as needed
)

# Loop through each subscription in the associative array
for subscription_name in "${!subscriptions[@]}"; do
    subscription_id="${subscriptions[$subscription_name]}"

    # Set the context to the current subscription
    az account set --subscription "$subscription_id"

    # Get the count of running VMs
    running_vms=$(az vm list -d --query "[?powerState=='VM running'] | length(@)" -o tsv)

    # Get the count of snapshots taken in the last day
    snapshots=$(az snapshot list --query "[?timeCreated >= '$(date -d '-1 day' --utc +%Y-%m-%dT%H:%M:%SZ)'] | length(@)" -o tsv)

    # Output the results for the current subscription
    echo "$subscription_name running Azure VMs as at $(date) = $running_vms"
    echo "$subscription_name Snapshots taken on $(date) = $snapshots"
    echo " "
done
