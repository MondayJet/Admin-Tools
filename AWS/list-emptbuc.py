import boto3

# Define the profile name and region
profile_name = 'your_profile_name'
region_name = 'us-west-2'

# Initialize a session using the specified profile
session = boto3.Session(profile_name=profile_name, region_name=region_name)

# Initialize a client for Amazon S3 using the session
s3 = session.client('s3')

# List all buckets
buckets = s3.list_buckets()['Buckets']

# Loop through each bucket to check if it is empty
empty_buckets = []
for bucket in buckets:
    bucket_name = bucket['Name']
    # Get the list of objects in the bucket
    objects = s3.list_objects_v2(Bucket=bucket_name)
    # Check if the bucket is empty
    if 'Contents' not in objects:
        empty_buckets.append(bucket_name)

# Print the list of empty buckets
if empty_buckets:
    print("Empty S3 buckets:")
    for empty_bucket in empty_buckets:
        print(empty_bucket)
else:
    print("No empty S3 buckets found.")

