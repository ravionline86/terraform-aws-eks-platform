variable "aws_region" {
  type    = string
  default = "ca-west-1"
}

variable "cluster_name" {
  type    = string
  default = "eks-platform-staging"
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to reach the EKS public API endpoint. Set to your IP."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict in production: ["YOUR_IP/32"]
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
  default     = ""
}
