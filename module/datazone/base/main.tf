/*
 * Create Projects for SMUS Domain
 */

data "aws_caller_identity" "current" {}

module "domain_service_roles" {
  source = "../../../modules/datazone/create_service_roles"
}

data "external" "user_exists" {
  for_each   = toset(var.sso_users)
  depends_on = [awscc_datazone_domain.domain]

  program = [
    "bash", "-c",
    <<EOT
    set -e
    output=$(aws datazone get-user-profile \
      --domain-identifier ${awscc_datazone_domain.domain.domain_id} \
      --user-identifier ${each.value} 2>/dev/null || true)

    if [ -n "$output" ]; then
      user_id=$(echo "$output" | jq -r '.id')
      echo "{\"exists\": \"true\", \"user_identifier\": \"$user_id\"}"
    else
      echo "{\"exists\": \"false\", \"user_identifier\": \"${each.value}\"}"
    fi
    EOT
  ]
}

// avoid race condition by forcing domain to be created in series
resource "time_sleep" "wait_after_role_creation" {
  depends_on      = [module.domain_service_roles]
  create_duration = "10s"
}

// create domain in primary account
resource "awscc_datazone_domain" "domain" {
  provider              = awscc
  name                  = var.domain_name
  description           = "Domain Root"
  domain_execution_role = module.domain_service_roles.sagemaker_domain_execution_role_arn
  service_role          = module.domain_service_roles.sagemaker_service_role_arn
  domain_version        = "V2"
  single_sign_on = {
    type            = "IAM_IDC"
    user_assignment = "AUTOMATIC"
  }


  depends_on = [
    time_sleep.wait_after_role_creation
  ]
}

// add SSO users to domain
resource "aws_datazone_user_profile" "sso_users" {
  for_each = {
    for user, info in data.external.user_exists :
    user => info if info.result.exists == false
  }
  domain_identifier = awscc_datazone_domain.domain.domain_id
  user_identifier   = each.key
  user_type         = "SSO_USER"
}

// create RAM share from primary account
resource "awscc_ram_resource_share" "domain_share" {
  provider                  = awscc
  name                      = "DataZone-${awscc_datazone_domain.domain.name}-${awscc_datazone_domain.domain.domain_id}"
  resource_arns             = [awscc_datazone_domain.domain.arn]
  allow_external_principals = true
  permission_arns = [
    "arn:aws:ram::aws:permission/AWSRAMPermissionsAmazonDatazoneDomainExtendedServiceAccess"
  ]
  principals = [
    data.aws_caller_identity.current.account_id
  ]
}