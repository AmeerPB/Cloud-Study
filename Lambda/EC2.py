import boto3

region = "<region>"

def lambda_handler(event, context):
    ec2_details = boto3.client('ec2', region_name=region)
    
    # Define the tag and name filters
    tag_filter = {"Name": "tag:Project", "Values": ["Plan C Systems:dev"]}
    name_filter = {"Name": "tag:Name", "Values": ["test-database-all-service", "test-database-report-service"]}
    name_filter = {"Name": "tag:Name", "Values": ["test-database-all-service", "test-database-report-service"]}
    status_stopped_filter = {"Name": "tag:Stop_value", "Values" : ["6PM Stopper"]}
    
    # Describe instances with the specified filters
    all_instances = ec2_details.describe_instances(Filters=[tag_filter, name_filter, status_stopped_filter])
    
    for reservation in all_instances['Reservations']:
        for instance in reservation['Instances']:
            stopping_instance_id = instance['InstanceId']
            print("Stopping Instance: {} ".format(stopping_instance_id))
            ec2_details.stop_instances(InstanceIds=[stopping_instance_id])