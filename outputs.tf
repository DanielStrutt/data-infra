output "aws_account_id" {
  description = "The AWS account ID Terraform is deploying into"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "The AWS region being used"
  value       = data.aws_region.current.name
}

output "aws_caller_arn" {
  description = "ARN of the IAM identity running Terraform"
  value       = data.aws_caller_identity.current.arn
}

output "s3_bucket_ids" {
  description = "Map of suffix -> bucket name for all S3 buckets in this environment"
  value       = { for k, v in module.s3 : k => v.bucket_id }
}

output "s3_bucket_arns" {
  description = "Map of suffix -> bucket ARN for all S3 buckets in this environment"
  value       = { for k, v in module.s3 : k => v.bucket_arn }
}

output "ecr_repository_urls" {
  description = "Map of suffix -> ECR repository URL for all ECR repositories in this environment"
  value       = { for k, v in module.ecr : k => v.repository_url }
}

output "ecr_repository_arns" {
  description = "Map of suffix -> ECR repository ARN for all ECR repositories in this environment"
  value       = { for k, v in module.ecr : k => v.repository_arn }
}
