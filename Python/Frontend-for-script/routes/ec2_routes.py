# routes/ec2_routes.py
from flask import Blueprint, render_template
import boto3

ec2_client = boto3.client('ec2')
compute_optimizer_client = boto3.client('compute-optimizer')

ec2_bp = Blueprint('ec2', __name__)

@ec2_bp.route('/ec2')
def ec2():
    return render_template('ec2_index.html')

@ec2_bp.route('/ec2/all')
def ec2_all():
    response = ec2_client.describe_instances()
    instances = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instances.append({
                'id': instance['InstanceId'],
                'name': next((tag['Value'] for tag in instance.get('Tags', []) if tag['Key'] == 'Name'), 'N/A'),
                'type': instance['InstanceType']
            })
    instances_sorted = sorted(instances, key=lambda x: x['type'])
    return render_template('ec2_all.html', instances=instances_sorted)

@ec2_bp.route('/ec2/overprovisioned')
def ec2_overprovisioned():
    recommendations_response = compute_optimizer_client.get_ec2_instance_recommendations(
        filters=[
            {'name': 'Finding', 'values': ['Overprovisioned']}
        ]
    )
    recommendations = []
    for recommendation in recommendations_response['instanceRecommendations']:
        arn = recommendation['instanceArn']
        instance_id = arn.split('/')[-1]
        recommendations.append({
            'id': instance_id,
            'name': recommendation.get('instanceName', 'N/A'),
            'finding': recommendation.get('finding', 'N/A'),
            'reasons': ', '.join(recommendation.get('findingReasonCodes', []))
        })
    return render_template('ec2_overprovisioned.html', recommendations=recommendations)

@ec2_bp.route('/ec2/stopped')
def ec2_stopped():
    stopped_instances_response = ec2_client.describe_instances(Filters=[
        {'Name': 'instance-state-name', 'Values': ['stopped']}
    ])
    stopped_instances = []
    for reservation in stopped_instances_response['Reservations']:
        for instance in reservation['Instances']:
            stopped_instances.append({
                'id': instance['InstanceId'],
                'launch_time': instance['LaunchTime'].strftime('%Y-%m-%d %H:%M:%S')
            })
    return render_template('ec2_stopped.html', stopped_instances=stopped_instances)
