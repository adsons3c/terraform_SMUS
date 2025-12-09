data "aws_region" "current" {}

// deploy in primary account
module "domain_service_roles" {
  source = "../../../modules/datazone/create_service_roles"
}

data "external" "user_exists" {
  for_each   = toset(var.sso_users)
  depends_on = [module.domains]

  program = [
    "bash", "-c",
    <<EOT
    set -e
    output=$(aws datazone get-user-profile \
      --domain-identifier ${module.domains.domain_id} \
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

# data "aws_ssoadmin_instances" "sso" {}

# data "aws_identitystore_user" "this" {
#   for_each = toset(var.sso_users)

#   identity_store_id = data.aws_ssoadmin_instances.sso.identity_store_ids[0]

#   alternate_identifier {
#     unique_attribute {
#       attribute_path  = "Emails[0].Value"
#       attribute_value = each.value
#     }
#   }
# }



#------------------------------------------datazone-domain-------------------------------------

module "domains" {
  source   = "../../../modules/datazone/base"
  # for_each = { for d in var.domain_names : d => d }

  domain_name         = "datax-dataplatform-prd"
  sso_users           = ["igor.santilli-lee@cogna.parceirosedu.com.br"]
  sagemaker_subnets   = ["subnet-06bad7ccf574fd6e1", "subnet-01cd3060e1eea1993"]
  sagemaker_vpc_id    = "vpc-022d8bcd0d7ec91ab"
  root_domain_owners  = ["igor.santilli-lee@cogna.parceirosedu.com.br"]
  domain_units        = ["alianca", "plataforma", "estrutura_corporativa"]
  parent_units        = {
    Aliancas    = "alianca"
    Plataformas = "plataforma"
  }
  child_units         = {
    Aliancas    = ["alianca_2_jovem_e_adulto"]
    Plataformas = ["revenue_office"]
  }
  child_units_level_2 = {
    alianca_2_jovem_e_adulto = [
      "kroton_graduacao",
      "kroton_gradmed",
      "kroton_tecprof_e_eja",
      "kroton_pos"
    ]
    revenue_office = [
      "brand_management",
      "commercial_excellence",
      "cx_experiencie",
      "emprego_e_renda",
      "inteligencia_expansao_e_pricing",
      "marketing_platforma",
      "relacionamento_e_rematricula"
    ]
 }
}


resource "aws_datazone_user_profile" "sso_users" {
  for_each = {
    for user, info in data.external.user_exists :
    user => info if info.result.exists == false
  }
  domain_identifier = module.domains.domain_id
  user_identifier   = each.key
  user_type         = "SSO_USER"
}


// Add users ao Datazone
# resource "awscc_datazone_user_profile" "profiles" {
#   for_each          = data.aws_identitystore_user.this
#   domain_identifier = module.domains.domain_id
#   user_identifier   = each.value.user_id
# }


#------------------------------------------modules/datazone/create-blueprint-roles-------------------------------------

// create roles in associated account
// when doing cross-account deployment, the account id will be set to the source account to allow for the domain to call in
module "blueprint_roles" {
  source    = "../../../modules/datazone/create_blueprint_roles"
  domain_arn = module.domains.domain_arn
  domain_id  = module.domains.domain_id
  account_id = data.aws_caller_identity.current.account_id
  # depends_on = [
  #   aws_ram_resource_share_accepter.receiver_accept
  # ]
}

#------------------------------------------modules/datazone/create-blueprint-------------------------------------

module "dzs3_bucket"{
  source = "../../../modules/cogna_s3"
  bucket_name = "amazon-sagemaker-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-${replace(module.domains.domain_id, "dzd_", "")}"
  s3_versioning = "Disabled"
}

// enable blueprints for the domain
// If a cross-account association is used, these blueprints will be created in the associated account by specifying the provider
module "blueprints" {
  source                               = "../../../modules/datazone/create_blueprint"
  domain_id                            = module.domains.domain_id
  amazon_sage_maker_manage_access_role = module.blueprint_roles.sagemaker_manage_access_role_arn
  amazon_sage_maker_provisioning_role  = module.blueprint_roles.sagemaker_provisioning_role_arn
  dzs3_bucket                          = "s3://${module.dzs3_bucket.bucket-id}/"
  sage_maker_subnets                   = join(",", var.sagemaker_subnets)
  amazon_sage_maker_vpc_id             = var.sagemaker_vpc_id
  blueprints = [ 
    "AmazonBedrockChatAgent",
    "AmazonBedrockEvaluation",
    "AmazonBedrockFlow",
    "AmazonBedrockFunction",
    "AmazonBedrockGuardrail",
    "AmazonBedrockKnowledgeBase",
    "AmazonBedrockPrompt",
    "DataLake",
    "EmrOnEc2",
    "EmrServerless",
    "LakehouseCatalog",
    "MLExperiments",
    "PartnerApps",
    "QuickSight",
    "RedshiftServerless",
    "Tooling",
    "Workflows",
  ]
  depends_on = [module.domains]
}

#------------------------------------------modules/datazone/create-blueprint-policy-grant-------------------------------------

module "blueprint_policy_grants" {
  source         = "../../../modules/datazone/create_blueprint_policy_grant"
  domain_id      = module.domains.domain_id
  domain_unit_id = module.domains.root_domain_unit_id

  blueprint_ids = tomap({
    lakehouse_catalog_id             = module.blueprints.lakehouse_catalog_id,
    amazon_bedrock_guardrail_id      = module.blueprints.amazon_bedrock_guardrail_id,
    ml_experiments_id                = module.blueprints.ml_experiments_id,
    tooling_id                       = module.blueprints.tooling_id,
    redshift_serverless_id           = module.blueprints.redshift_serverless_id,
    emr_serverless_id                = module.blueprints.emr_serverless_id,
    workflows_id                     = module.blueprints.workflows_id,
    amazon_bedrock_prompt_id         = module.blueprints.amazon_bedrock_prompt_id,
    data_lake_id                     = module.blueprints.data_lake_id,
    amazon_bedrock_evaluation_id     = module.blueprints.amazon_bedrock_evaluation_id,
    amazon_bedrock_knowledge_base_id = module.blueprints.amazon_bedrock_knowledge_base_id,
    partner_apps_id                  = module.blueprints.partner_apps_id,
    amazon_bedrock_chat_agent_id     = module.blueprints.amazon_bedrock_chat_agent_id,
    amazon_bedrock_function_id       = module.blueprints.amazon_bedrock_function_id,
    amazon_bedrock_flow_id           = module.blueprints.amazon_bedrock_flow_id,
    emr_on_ec2_id                    = module.blueprints.emr_on_ec2_id,
    quick_sight_id                   = module.blueprints.quick_sight_id,
  })
}

#------------------------------------------modules/datazone/create-project-profiles-------------------------------------

// project profiles are created in primary account and reference the account where blueprints are located
// in a multi-account configuration, the project profiles are created in the primary account and reference blueprints created in the associated account
module "project_profiles" {
  source = "../../../modules/datazone/create_project_profiles"
  // domain to enable project profiles
  domain_id      = module.domains.domain_id
  domain_unit_id = module.domains.root_domain_unit_id
  // account where blueprints are deployed
  account_id = data.aws_caller_identity.current.account_id
  region     = var.region
  // blueprint identifiers
  lakehouse_catalog_id             = module.blueprints.lakehouse_catalog_id
  amazon_bedrock_guardrail_id      = module.blueprints.amazon_bedrock_guardrail_id
  ml_experiments_id                = module.blueprints.ml_experiments_id
  tooling_id                       = module.blueprints.tooling_id
  redshift_serverless_id           = module.blueprints.redshift_serverless_id
  emr_serverless_id                = module.blueprints.emr_serverless_id
  workflows_id                     = module.blueprints.workflows_id
  amazon_bedrock_prompt_id         = module.blueprints.amazon_bedrock_prompt_id
  data_lake_id                     = module.blueprints.data_lake_id
  amazon_bedrock_evaluation_id     = module.blueprints.amazon_bedrock_evaluation_id
  amazon_bedrock_knowledge_base_id = module.blueprints.amazon_bedrock_knowledge_base_id
  partner_apps_id                  = module.blueprints.partner_apps_id
  amazon_bedrock_chat_agent_id     = module.blueprints.amazon_bedrock_chat_agent_id
  amazon_bedrock_function_id       = module.blueprints.amazon_bedrock_function_id
  amazon_bedrock_flow_id           = module.blueprints.amazon_bedrock_flow_id
  emr_on_ec2_id                    = module.blueprints.emr_on_ec2_id
  quick_sight_id                   = module.blueprints.quick_sight_id
}

#------------------------------------------modules/datazone/create-project-profiles-------------------------------------

module "project_profile_policy_grant" {
  source         = "../../../modules/datazone/create_project_profile_policy_grant"
  domain_id      = module.domains.domain_id
  domain_unit_id = module.domains.root_domain_unit_id
  project_profile_ids = [
    module.project_profiles.sql_analytics_profile_id,
    # module.project_profiles.all_capabilities_project_profile_id
  ]
}

#------------------------------------------------------------------------------------
// Create Domains Units Root
resource "awscc_datazone_domain_unit" "cogna_root" {
  for_each                      = toset(var.domain_units)

  name                          = each.value
  description                   = "Unidade Filha do Domain Root"
  domain_identifier             = module.domains.domain_id
  parent_domain_unit_identifier = module.domains.root_domain_unit_id
}



// 
locals {
  domain_units_flat = {
    for item in flatten([
      for group, list in var.child_units : [
        for du in list : {
          name   = du
          group  = group
          parent = var.parent_units[group]
        }
      ]
    ]) :
    item.name => item
  }
}

// Create Childs Domains 
resource "awscc_datazone_domain_unit" "child_units" {
  for_each = local.domain_units_flat

  name        = each.value.name
  description = "Unidade child do dominio ${each.value.group}"
  domain_identifier             = module.domains.domain_id
  parent_domain_unit_identifier = awscc_datazone_domain_unit.cogna_root[each.value.parent].domain_unit_id
}

locals {
  domain_units_level_2 = {
    for item in flatten([
      for parent, list in var.child_units_level_2 : [
        for du in list : {
          name   = du
          parent = parent
        }
      ]
    ]) :
    item.name => item
  }
}

// Create Child domains Level 2 
resource "awscc_datazone_domain_unit" "child_units_level_2" {
  for_each = local.domain_units_level_2

  name        = each.value.name
  description = "Unidade de nível 3 de ${each.value.parent}"
  domain_identifier = module.domains.domain_id
  parent_domain_unit_identifier = awscc_datazone_domain_unit.child_units[each.value.parent].domain_unit_id
}

locals {
  all_domain_units = merge(
    { for k, v in awscc_datazone_domain_unit.cogna_root : k => v },
    { for k, v in awscc_datazone_domain_unit.child_units : k => v },
    { for k, v in awscc_datazone_domain_unit.child_units_level_2 : k => v },
  )
}

// Add de usuários Owners nos dominios
resource "awscc_datazone_owner" "child_domain_owner" {
  for_each = local.all_domain_units

  domain_identifier = module.domains.domain_id
  entity_identifier = each.value.domain_unit_id
  entity_type       = "DOMAIN_UNIT"

  owner = {
    user = {
      user_identifier = "adson.emanuel@compasso.com.br"
    }
  }
}

locals {
  all_user_profiles = merge(
    {
      for user, info in data.external.user_exists :
      user => {
        exists          = info.result.exists
        user_identifier = info.result.user_identifier
      }
    },
    {
      for user, resource in aws_datazone_user_profile.sso_users :
      user => {
        exists          = true
        user_identifier = resource.user_identifier
      }
    }
  )
}


# locals {
#   dz_users = {
#     for email, profile in awscc_datazone_user_profile.profiles :
#     email => profile.user_profile_id
#   }
# }


//--------------------------------------modules/datazone/create-project----------------------------

module "projects" {
  for_each = local.domain_units_level_2

  source             = "../../../modules/datazone/create_project"
  domain_id          = module.domains.domain_id
  domain_unit_id     = awscc_datazone_domain_unit.child_units_level_2[each.key].domain_unit_id
  project_profile_id = module.project_profiles.sql_analytics_profile_id
  name               = each.value.name

  users = [
    for profile in local.all_user_profiles :
    profile.user_identifier
  ]
  # users = local.dz_users
  depends_on = [
    module.domains,
    module.project_profiles,
    awscc_datazone_domain_unit.child_units_level_2
  ]
}