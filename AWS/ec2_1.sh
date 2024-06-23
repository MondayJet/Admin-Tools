#!/bin/bash
#This method uses declarative array, there's really no need. since same result can be achieved with list
# Declare an associative array of AWS profiles and their corresponding friendly names
declare -A aws_profiles=(
    ["Profile"]="profile1"
    ["OtherProfile"]="profile2"
    ["AnotherProfile"]="profile3"
    # Add more profiles as needed
)

# Loop through each profile in the dictionary
for profile_name in "${!aws_profiles[@]}"; do
    AWS_PROFILE="${aws_profiles[$profile_name]}"

    echo "Describing instances for profile: $profile_name (AWS Profile: $AWS_PROFILE)"
    
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
