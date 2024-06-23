#!/bin/bash

# List of AWS profiles to use
aws_profiles=("profile1" "profile2" "profile3") # Add more profiles as needed

# Loop through each profile in the list
for AWS_PROFILE in "${aws_profiles[@]}"; do
    echo "Describing instances for AWS Profile: $AWS_PROFILE"
    
    # Describe instances and capture the output in a variable
    response=$(aws ec2 describe-instances --profile $AWS_PROFILE)

    # Use jq to parse the JSON response and extract the required fields
    echo "$response" | jq -r '
        .Reservations[].Instances[] | 
        [
            (.Tags[]? | select(.Key == "Name") | .Value // "N/A"),
            .InstanceId,
            .InstanceType,
            .LaunchTime,
            (.Platform // "N/A"),
            (.PublicIpAddress // "N/A"),
            (.PrivateIpAddress // "N/A"),
            (.State.Name // "N/A")
        ] | @tsv' | column -t

    echo " " # Add a blank line to separate output for different profiles
done
