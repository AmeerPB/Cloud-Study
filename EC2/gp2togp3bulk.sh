PROFILE_NAME="indus"

for volume in $(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query "Volumes[?State=='available'].[VolumeId]" --output text --profile $PROFILE_NAME); do
  aws ec2 modify-volume --volume-id $volume --volume-type gp3 --profile $PROFILE_NAME
done

 