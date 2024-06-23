import boto3
from datetime import datetime, timedelta, timezone

def process_snapshots(profile_name, owner_id):
    # Create an EC2 client
    client = boto3.client("ec2", profile_name=profile_name)

    # Describe snapshots with the specified owner ID
    response = client.describe_snapshots(OwnerIds=[owner_id])

    # Print the total number of snapshots
    print("==================== " + str(len(response["Snapshots"])) + f" Snapshots for {profile_name} taken today ===============================")

    # Get the current time in UTC and the time 24 hours ago
    now = datetime.now(timezone.utc)
    twenty_four_hours_ago = now - timedelta(days=1)

    # Iterate through the snapshots and filter by StartTime
    for snapshot in response["Snapshots"]:
        start_time = snapshot["StartTime"]

        # Filter snapshots created in the last 24 hours
        if start_time >= twenty_four_hours_ago:
            Name = "N/A"
            if "Tags" in snapshot:
                for tag in snapshot["Tags"]:
                    if tag["Key"] == "Name":
                        Name = tag["Value"]
            print(f"Name: {Name} SnapshotId: {snapshot['SnapshotId']} StartTime: {snapshot['StartTime']} VolumeSize: {snapshot['VolumeSize']}")

    print(" ")

# Dictionary containing profile names as keys and owner IDs as values
profiles = {
    "Profile1": "123",
    "Profile2": "456",
    # Add more profiles as needed
}

# Loop through the dictionary and process each profile
for profile_name, owner_id in profiles.items():
    process_snapshots(profile_name, owner_id)
