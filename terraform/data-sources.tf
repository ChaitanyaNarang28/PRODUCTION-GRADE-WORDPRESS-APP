# Data sources to discover caller identity and region (modern, minimal)
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
