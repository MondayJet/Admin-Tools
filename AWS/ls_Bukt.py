import boto3

def list_buckets(profile_name=<'profile_name'>, region_name=<'Region_name'>):
    # Initialize a session using the specified profile
    session = boto3.Session(profile_name=profile_name, region_name=region_name)
    
    # Initialize a client for S3 using the session
    s3 = session.client('s3')
    
    # List all buckets
    response = s3.list_buckets()
    buckets = response['Buckets']

    # Print the buckets
    for bucket in buckets:
        bucket_name = bucket['Name']
        print(f"Bucket: {bucket_name}")

if __name__ == "__main__":
    list_buckets(profile_name=<'Profile_name'>)
