data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "s3" {
  for_each = toset(var.s3_buckets)

  source      = "./modules/s3"
  bucket_name = "${local.name_prefix}-${each.key}"
  tags        = local.common_tags
}
