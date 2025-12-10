variable "project_name" {
  type    = string
  default = "Syfe_Chaitanya"
}

variable "aws_account_id" {
  type    = string
  default = "025066248529"
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "domain_name" {
  type    = string
  default = "example.com"
}

variable "mysql_mode" {
  type    = string
  default = "rds" # rds or containerized
}

variable "github_repo" {
  type    = string
  default = "syfe-chaitanya/production-grade-wordpress-app"
}

variable "admin_aws_role_arn" {
  type    = string
  default = ""
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_workers" {
  type    = number
  default = 2
}
