data "aws_caller_identity" "current" {}

data "aws_iam_instance_profile" "ec2_ec" {
  name = "EC2-ECR-Pull-Role"

}