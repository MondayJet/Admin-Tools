#!/bin/bash

# List of AWS profiles to check
PROFILES=("profile1" "profile2" "profile3")

# Function to check snapshots for a given profile and delete if necessary
check_snapshots() {
    local PROFILE=$1

    echo "Checking snapshots for profile: $PROFILE"

    # Get the current date and time in ISO 8601 format
    CURRENT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Get all snapshots for the profile
    SNAPSHOTS=$(aws ec2 describe-snapshots --profile "$PROFILE" --query 'Snapshots[*].{ID:SnapshotId,VolumeId:VolumeId,Name:Description,StartTime:StartTime}' --output json)

    # Iterate over each snapshot
    echo "$SNAPSHOTS" | jq -c '.[]' | while read -r SNAPSHOT; do
        SNAPSHOT_ID=$(echo "$SNAPSHOT" | jq -r '.ID')
        VOLUME_ID=$(echo "$SNAPSHOT" | jq -r '.VolumeId')
        SNAPSHOT_NAME=$(echo "$SNAPSHOT" | jq -r '.Name')
        START_TIME=$(echo "$SNAPSHOT" | jq -r '.StartTime')

        # Check if the VolumeId is null and the snapshot is older than 3 days
        if [[ "$VOLUME_ID" == "vol-ffffffff" ]]; then
            if [[ "$SNAPSHOT_NAME" == "null" ]]; then
                echo "Snapshot without volume found: $SNAPSHOT_ID"
            else
                echo "Snapshot without volume found: $SNAPSHOT_ID (Name: $SNAPSHOT_NAME)"
            fi

            # Calculate the age of the snapshot in seconds
            SNAPSHOT_AGE=$(( $(date -d "$CURRENT_DATE" +%s) - $(date -d "$START_TIME" +%s) ))

            # Check if the snapshot is older than 3 days (259200 seconds)
            if [[ "$SNAPSHOT_AGE" -gt 259200 ]]; then
                # Force delete the snapshot
                aws ec2 delete-snapshot --profile "$PROFILE" --snapshot-id "$SNAPSHOT_ID" --force
                if [[ $? -eq 0 ]]; then
                    echo "Successfully deleted snapshot: $SNAPSHOT_ID"
                else
                    echo "Failed to delete snapshot: $SNAPSHOT_ID"
                fi
            else
                echo "Snapshot $SNAPSHOT_ID is not older than 3 days, skipping deletion."
            fi
        fi
    done
}

# Iterate over each profile
for PROFILE in "${PROFILES[@]}"; do
    check_snapshots "$PROFILE"
done

