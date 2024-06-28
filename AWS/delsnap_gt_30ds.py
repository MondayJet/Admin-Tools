import boto3
from datetime import datetime, timedelta
from botocore.exceptions import ClientError

# Define the profile name and region
profile_name = 'your_profile_name'
region_name = 'us-west-2'

# Initialize a session using the specified profile
session = boto3.Session(profile_name=profile_name)

# Initialize a client for Amazon EC2 using the session
ec2 = session.client('ec2', region_name=region_name)

# Calculate the date 30 days ago
old_date = datetime.now() - timedelta(days=30)

# Describe snapshots
snapshots = ec2.describe_snapshots(OwnerIds=['self'])['Snapshots']

# Loop through each snapshot and delete if older than 30 days
for snapshot in snapshots:
    snapshot_id = snapshot['SnapshotId']
    start_time = snapshot['StartTime'].replace(tzinfo=None)

    if start_time < old_date:
        try:
            print(f"Deleting snapshot {snapshot_id} created on {start_time}")
            ec2.delete_snapshot(SnapshotId=snapshot_id)
        except ClientError as e:
            if e.response['Error']['Code'] == 'InvalidParameterValue':
                print(f"Cannot delete snapshot {snapshot_id}: {e.response['Error']['Message']}")
            else:
                print(f"Unexpected error occurred when deleting snapshot {snapshot_id}: {e}")
    else:
        print(f"Keeping snapshot {snapshot_id} created on {start_time}")
