module "pcfg_v4_1_tf_012_no_export_aws_account_creds" {
  source      = "./modules/aws-account-entity-credentials"
  bucket_name = var.bucket_name
  test_name   = "v4_1_tf_012_no_export"
  creds_name  = "aws_account"
}

resource "scalr_provider_configuration" "v4_1_tf_012_no_export_aws_account" {
  name         = "v4_1_tf_012_no_export_aws_account"
  account_id   = var.account_id
  environments = ["*"]
  aws {
    account_type     = "regular"
    credentials_type = "access_keys"
    access_key       = module.pcfg_v4_1_tf_012_no_export_aws_account_creds.access_key_id
    secret_key       = module.pcfg_v4_1_tf_012_no_export_aws_account_creds.secret_access_key
  }
}

resource "aws_iam_role_policy" "v4_1_tf_012_no_export_aws_service" {
  name = "pcfg_test_v4_1_tf_012_no_export_object"
  role = aws_iam_role.instance_profile.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectAttributes",
          "s3:GetObjectTagging"
        ]
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.bucket_name}/v4_1_tf_012_no_export/aws_service",
        ]
      },
    ]
  })
}

resource "scalr_provider_configuration" "v4_1_tf_012_no_export_aws_service" {
  name         = "v4_tf012_instance_profile_no_export"
  account_id   = var.account_id
  environments = ["*"]
  aws {
    account_type        = "regular"
    credentials_type    = "role_delegation"
    role_arn            = aws_iam_role.instance_profile.arn
    trusted_entity_type = "aws_service"
  }
  depends_on = [
    aws_iam_role_policy.v4_1_tf_012_no_export_aws_service
  ]
}

module "workspace_v4_1_tf_012_no_export" {
  source            = "./modules/scalr-workspace"
  test_name         = "v4_1_tf_012_no_export"
  agent_pool_id     = scalr_agent_pool.agent_pool.id
  environment_id    = scalr_environment.test.id
  vcs_provider_id   = data.scalr_vcs_provider.test.id
  working_directory = "aws/workspace_sources/v4_1_tf012_no_export"
  terraform_version = "0.12.31"
  bucket_name       = var.bucket_name
  provider_configurations = [
    {
      id                   = scalr_provider_configuration.v4_1_tf_012_no_export_aws_account.id,
      alias                = "aws_account",
      variable_object_name = "object_aws_account",
      object_to_create     = module.pcfg_v4_1_tf_012_no_export_aws_account_creds.object_path,
    },
    {
      id                   = scalr_provider_configuration.v4_1_tf_012_no_export_aws_service.id,
      alias                = "aws_service",
      variable_object_name = "object_aws_service",
      object_to_create     = "v4_1_tf_012_no_export/aws_service",
    },
  ]
}
