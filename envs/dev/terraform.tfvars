aws_region   = "eu-west-2"
project_name = "data-infra"
environment  = "dev"

s3_buckets = [
  "raw",
  "staging",
  "new-s3-bucket"
]

ecr_repositories = [
  "data-pipeline"
]
