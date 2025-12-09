/*
 * Create the AmazonSageMakerManageAccess and AmazonSageMakerProvisioning IAM Roles required to deploy Blueprints for the SageMaker Unified Studio Domain
 * Learn more about the AmazonSageMakerManageAccess role here: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/AmazonSageMakerManageAccess.html
 * Learn more about AmazonSageMakerProvisioning role here: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/AmazonSageMakerProvisioning.html
 */


# Data sources to get current region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "sagemaker_manage_access" {
  name = "AmazonSageMakerManageAccess-${data.aws_region.current.region}-${var.domain_id}"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "datazone.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          }
          ArnEquals = {
            "aws:SourceArn" = var.domain_arn
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "manage_access_attach_glue_policy" {
  role       = aws_iam_role.sagemaker_manage_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneGlueManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "manage_access_attach_redshift_policy" {
  role       = aws_iam_role.sagemaker_manage_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDataZoneRedshiftManageAccessRolePolicy"
}

resource "aws_iam_role_policy_attachment" "manage_access_attach_role_policy" {
  role       = aws_iam_role.sagemaker_manage_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDataZoneSageMakerManageAccessRolePolicy"
}

# Separate policy resource
resource "aws_iam_policy" "sagemaker_manage_access_policy" {
  name        = "AmazonSageMakerManageAccessPolicy-${var.domain_id}"
  path        = "/service-role/"
  description = "Policy for SageMaker management access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "RedshiftSecretStatement"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = ["*"]
        Condition = {
          StringEquals = {
            "secretsmanager:ResourceTag/AmazonDataZoneDomain" = var.domain_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_manage_policy_attachment" {
  role       = aws_iam_role.sagemaker_manage_access.name
  policy_arn = aws_iam_policy.sagemaker_manage_access_policy.arn
}


# Provisioning Role
resource "aws_iam_role" "sagemaker_provisioning" {
  name = "AmazonSageMakerProvisioning-${data.aws_caller_identity.current.account_id}-${var.domain_id}"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "datazone.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "sagemaker_provisioning_attach_policy" {
  role       = aws_iam_role.sagemaker_provisioning.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SageMakerStudioProjectProvisioningRolePolicy"
}

data "aws_iam_role" "roleAmazonSageMaker" {
  name = "AmazonSageMakerProvisioning-${data.aws_caller_identity.current.account_id}-${var.domain_id}"
}

# // Adicionar outros Admins caso existam 
# resource "aws_lakeformation_data_lake_settings" "adminslakeformation" {
#   admins = [
#     data.aws_iam_role.roleAmazonSageMaker.arn,
#     "arn:aws:iam::756791736285:user/terraform_cli",
#     "arn:aws:iam::756791736285:role/aws-reserved/sso.amazonaws.com/sa-east-1/AWSReservedSSO_CompassoAdmins_7fa74aafa946095a",
#     "arn:aws:iam::756791736285:role/aws-reserved/sso.amazonaws.com/sa-east-1/AWSReservedSSO_ac-data-analytics-datalabs_eafd515084cd5e67",
#     "arn:aws:iam::756791736285:role/service-role/AmazonSageMakerProvisioning-756791736285",
#     "arn:aws:iam::756791736285:role/aws-reserved/sso.amazonaws.com/sa-east-1/AWSReservedSSO_ac-DATA-ANALYTICS-DATALABS_7b80720dfaf08fab",
#     "arn:aws:iam::756791736285:role/GlueRole-DQ",
#     "arn:aws:iam::756791736285:role/service-role/AWSGlueServiceRole",
#     "arn:aws:iam::756791736285:user/terraform_user",
#     "arn:aws:iam::756791736285:role/service-role/AmazonSageMakerManageAccess-sa-east-1-dzd-3qbuce2skr578b"

#   ]
# }
