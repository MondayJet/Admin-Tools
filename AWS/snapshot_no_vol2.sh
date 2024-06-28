#!/bin/bash

# This will loop through multiple  profiles and return snapshots without volumes that are older than 3 days

# Dictionary of AWS profiles and their corresponding owner IDs
declare -A PROFILES
PROFILES=( ["profile1"]="owner-id1" ["profile2"]="owner-id2" ["profile3"]="owner-id3" )

# Function to check snapshots for a given profile and owner ID
check_snapshots() {
    local PROFILE=$1
    local OWNER_ID=$2

    echo "Checking snapshots for profile: $PROFILE with owner ID: $OWNER_ID"

    # Get all snapshots for the profile and owner ID
    SNAPSHOTS=$(aws ec2 describe-snapshots --profile "$PROFILE" --owner-ids "$OWNER_ID" --query 'Snapshots[*].{ID:SnapshotId,VolumeId:VolumeId,StartTime:StartTime}' --output json)

    # Current date in seconds since the epoch
    CURRENT_DATE=$(date -u +%s)
    # Time threshold for 3 days ago in seconds since the epoch
    TIME_THRESHOLD=$((CURRENT_DATE - 3*24*60*60))

    # Iterate over each snapshot
    echo "$SNAPSHOTS" | jq -c '.[]' | while read -r SNAPSHOT; do
        SNAPSHOT_ID=$(echo "$SNAPSHOT" | jq -r '.ID')
        VOLUME_ID=$(echo "$SNAPSHOT" | jq -r '.VolumeId')
        SNAPSHOT_TIME=$(echo "$SNAPSHOT" | jq -r '.StartTime')

        # Convert snapshot time to seconds since the epoch
        SNAPSHOT_DATE=$(date -u -d "$SNAPSHOT_TIME" +%s)

        # Check if the VolumeId is null and if the snapshot is older than 3 days
        if [[ "$VOLUME_ID" == "vol-ffffffff" && $SNAPSHOT_DATE -lt $TIME_THRESHOLD ]]; then
            echo "Snapshot without volume found: $SNAPSHOT_ID (Older than 3 days)"
        fi
    done
}

# Iterate over each profile and owner ID
for PROFILE in "${!PROFILES[@]}"; do
    OWNER_ID=${PROFILES[$PROFILE]}
    check_snapshots "$PROFILE" "$OWNER_ID"
done
