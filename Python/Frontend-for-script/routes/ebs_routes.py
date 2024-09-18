# routes/ebs_routes.py
from flask import Blueprint, render_template
import boto3

ebs_client = boto3.client('ec2')

ebs_bp = Blueprint('ebs', __name__)

@ebs_bp.route('/ebs')
def ebs():
    # Fetch EBS volume information with type gp2
    response = ebs_client.describe_volumes(Filters=[
        {'Name': 'volume-type', 'Values': ['gp2']}
    ])
    volumes = []
    for volume in response['Volumes']:
        volumes.append({
            'id': volume['VolumeId'],
            'availability_zone': volume['AvailabilityZone'],
            'size': volume['Size'],
            'type': volume['VolumeType']
        })

    # Fetch snapshots information
    snapshots_response = ebs_client.describe_snapshots(OwnerIds=['self'], Filters=[
        {'Name': 'status', 'Values': ['completed']}
    ])
    snapshots = []
    for snapshot in snapshots_response['Snapshots']:
        snapshots.append({
            'id': snapshot['SnapshotId'],
            'start_time': snapshot['StartTime'].strftime('%Y-%m-%d %H:%M:%S')
        })

    return render_template('ebs.html', volumes=volumes, snapshots=snapshots)
