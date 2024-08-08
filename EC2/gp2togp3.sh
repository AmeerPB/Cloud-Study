# Convert gp2 volume to gp3 volume for better cost optimisation
aws ec2 describe-volumes --filters "Name=volume-type,Values=gp2" "Name=status,Values=in-use" --query "Volumes[*].{ID:VolumeId,Size:Size,State:State,AZ:AvailabilityZone}" --output table --profile <PROFLE-NAME>

