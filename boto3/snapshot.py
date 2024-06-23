import boto3

# Dictionary of AWS profiles and their corresponding owner IDs
aws_profiles = {
    "profile1": "Owners-id1",
    "profile2": "Owners-id2",
    "profile3": "Owners-id3"
} # Add more profiles and owner IDs as needed

def describe_snapshots_for_profile(profile_name, owner_id):
    # Create a session using the specified profile
    session = boto3.Session(profile_name=profile_name)
    client = session.client("ec2")

    # Describe snapshots for the specified owner ID
    response = client.describe_snapshots(OwnerIds=[owner_id])

    print(f"\nProfile: {profile_name}")
    print(f"Total Snapshots: {len(response['Snapshots'])}\n")
    
    for snapshot in response["Snapshots"]:
        Name = "N/A"
        if "Tags" in snapshot:
            for tag in snapshot["Tags"]:
                if tag["Key"] == "Name":
                    Name = tag["Value"]

        print(f"Name: {Name}, SnapshotId: {snapshot['SnapshotId']}, StartTime: {snapshot['StartTime']}, VolumeSize: {snapshot['VolumeSize']}")

# Loop through each profile in the dictionary and describe snapshots
for profile_name, owner_id in aws_profiles.items():
    describe_snapshots_for_profile(profile_name, owner_id)
