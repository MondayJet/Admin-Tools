#!/bin/bash

# Script to describe AWS EC2 snapshots for multiple profiles within the last 24 hours,
# parse the response to extract required fields, and save the output to a file with a timestamp.

# Output file with timestamp
time=$(date +"%d-%m-%Y %H-%M")
output_file="path/AWS-$time"
temp_file="temp_file_out.txt"

# Declare an associative array of AWS profiles and their corresponding owner IDs
declare -A profile_owner_ids=(
    ["profile1"]="Owners-id1"
    ["profile2"]="Owners-id2"
    ["profile3"]="Owners-id3"
    ["profile4"]="Owners-id4"
    ["profile5"]="Owners-id5"
) # Add more profiles and owner IDs as needed

# Get the current time in UTC and the time 24 hours ago in ISO 8601 format
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
twenty_four_hours_ago=$(date -u -d '-24 hours' +"%Y-%m-%dT%H:%M:%SZ")

# Loop through each profile and owner ID
for profile in "${!profile_owner_ids[@]}"; do
    owner_id="${profile_owner_ids[$profile]}"

    # Describe snapshots for the current profile and owner ID, and capture the output in a variable
    response=$(aws ec2 describe-snapshots --owner-ids "$owner_id" --profile "$profile")

    # Use jq to parse the JSON response and extract the required fields, including the snapshot name
    echo "$response" | jq -r --arg now "$now" --arg twenty_four_hours_ago "$twenty_four_hours_ago" '
        .Snapshots[] |
        select(.StartTime >= $twenty_four_hours_ago and .StartTime <= $now) |
        [
            .SnapshotId,
            .VolumeId,
            .StartTime,
            .State,
            .OwnerId,
            (.Tags[]? | select(.Key == "Name") | .Value // "N/A")
        ] | 
        @tsv' | column -t >> "$temp_file"

    # Append the processed output to the final output file
    cat "$temp_file" >> "$output_file"

    # Count the number of lines in the temporary file and append the count to the final output file
    line_count=$(wc -l < "$temp_file")
    date=$(date +"%d-%m-%Y %H:%M")
    echo "Number of AWS snapshots taken today $date for $profile (owner ID $owner_id) == $line_count" >> "$output_file"
    
    # Clear the temporary file for the next profile
    > "$temp_file"
    
    # Add a blank line to separate entries for different profiles in the final output file
    echo " " >> "$output_file"
done

# Remove the temporary file
rm "$temp_file"
