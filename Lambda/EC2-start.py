import boto3

region = "ap-south-1"

def lambda_handler(event, context):
    ec2_details = boto3.client('ec2', region_name=region)
    
    # Define the tag and name filters
    tag_filter = {"Name": "tag:Project", "Values": ["Plan C Systems:dev"]}
    name_filter = {"Name": "tag:Name", "Values": ["database-all-service", "database-report-service"]}
    
    # Describe instances with the specified filters
    all_instances = ec2_details.describe_instances(Filters=[tag_filter, name_filter])
    
    for reservation in all_instances['Reservations']:
        for instance in reservation['Instances']:
            starting_instance_id = instance['InstanceId']
            print("Starting Instance: {} ".format(starting_instance_id))
            ec2_details.start_instances(InstanceIds=[starting_instance_id])