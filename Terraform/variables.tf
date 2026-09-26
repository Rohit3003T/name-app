variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}
variable "key_name" {
  type        = string
  description = "EC2 SSH key pair name"
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "my_ip" {
  type        = string
  description = "Public IP allowed to access EC2 through SSH"
}
