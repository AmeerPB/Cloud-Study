import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    
    # Filter instances based on the tag
    filters = [
        {
            'Name': 'tag:lambda-shutdown',
            'Values': ['6PM']
        }
    ]
    
    instances = ec2.describe_instances(Filters=filters)
    
    instance_ids = []
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])
    
    if instance_ids:
        ec2.stop_instances(InstanceIds=instance_ids)
        print('Stopped your instances: ' + str(instance_ids))
    else:
        print('No instances to stop')
