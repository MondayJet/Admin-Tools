#!/bin/bash

# Declare an associative array with profile names as keys and owner IDs as values
declare -A profiles
profiles=(
    ["profile1"]="owner_id1"
    ["profile2"]="owner_id2"
    # Add more profiles as needed
)

# Loop through each profile in the associative array
for profile_name in "${!profiles[@]}"; do
    AWS_PROFILE="$profile_name"
    OWNER_ID="${profiles[$profile_name]}"

    # Describe snapshots and capture the output in a variable
    response=$(aws ec2 describe-snapshots --owner-ids "$OWNER_ID" --profile "$AWS_PROFILE")

    # Print header for each profile
    echo "==================== $profile_name Snapshots ==============================="

    # Use jq to parse the JSON response and extract the required fields including the snapshot name
    echo "$response" | jq -r '
        .Snapshots[] | 
        [
            .SnapshotId,
            .VolumeId,
            .StartTime,
            .State,
            .OwnerId,
            (.Tags[]? | select(.Key == "Name") | .Value // "N/A")
        ] | 
        @tsv' | column -t

    echo " "
done
