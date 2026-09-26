resource "aws_launch_template" "app" {

  name = "name-app-launch-template"

  image_id      = "ami-01a00762f46d584a1"
  instance_type = var.instance_type

  key_name = var.key_name

  iam_instance_profile {
    name = data.aws_iam_instance_profile.ec2_ec.name
  }

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]
  user_data = base64encode(<<-EOF
#!/bin/bash

set -e


apt-get update -y

apt-get install -y docker.io awscli jq

systemctl enable docker
systemctl start docker


SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id name-app/rds \
  --region ${var.aws_region} \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.DB_HOST')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.DB_NAME')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.DB_USER')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.DB_PASSWORD')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.DB_PORT')

aws ecr get-login-password \
  --region ${var.aws_region} | \
  docker login \
  --username AWS \
  --password-stdin \
  "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
docker pull \
  "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"/name-app:latest

docker run -d \
  --name name-app \
  -p 5000:5000 \
  -e DB_HOST="$DB_HOST" \
  -e DB_NAME="$DB_NAME" \
  -e DB_USER="$DB_USER" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e DB_PORT="$DB_PORT" \
  "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"/name-app:latest
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "name-app-server"
    }
  }
}


resource "aws_autoscaling_group" "app" {

  name = "name-app-asg"

  min_size         = 1
  max_size         = 3
  desired_capacity = 3

  vpc_zone_identifier = [
    aws_subnet.subnet_az1_private.id,
    aws_subnet.subnet_az2_private.id,
    aws_subnet.subnet_az3_private.id
  ]

  target_group_arns = [
    aws_lb_target_group.app_tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "name-app-server"
    propagate_at_launch = true
  }
}

