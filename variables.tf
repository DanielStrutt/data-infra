variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type        = string
  default     = "data-infra"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be one of: dev, prod"
  }
}

variable "s3_buckets" {
  description = "List of S3 bucket name suffixes to create. Each becomes <project>-<env>-<suffix>."
  type        = list(string)
  default     = []
}

variable "ecr_repositories" {
  description = "List of ECR repository name suffixes to create. Each becomes <project>-<env>-<suffix>."
  type        = list(string)
  default     = []
}
