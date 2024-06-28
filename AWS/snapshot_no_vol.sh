#!/bin/bash

# List of AWS profiles to check
PROFILES=("profile1" "profile2" "profile3")

# Function to check snapshots for a given profile
check_snapshots() {
    local PROFILE=$1

    echo "Checking snapshots for profile: $PROFILE"

    # Get all snapshots for the profile
    SNAPSHOTS=$(aws ec2 describe-snapshots --profile "$PROFILE" --query 'Snapshots[*].{ID:SnapshotId,VolumeId:VolumeId}' --output json)

    # Iterate over each snapshot
    echo "$SNAPSHOTS" | jq -c '.[]' | while read -r SNAPSHOT; do
        SNAPSHOT_ID=$(echo "$SNAPSHOT" | jq -r '.ID')
        VOLUME_ID=$(echo "$SNAPSHOT" | jq -r '.VolumeId')

        # Check if the VolumeId is null
        if [[ "$VOLUME_ID" == "vol-ffffffff" ]]; then
            echo "Snapshot without volume found: $SNAPSHOT_ID"
        fi
    done
}

# Iterate over each profile
for PROFILE in "${PROFILES[@]}"; do
    check_snapshots "$PROFILE"
done
