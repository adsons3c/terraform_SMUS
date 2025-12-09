/*
 * Create Project profile for SMUS Domain
 */

resource "awscc_datazone_project_profile" "this" {
  name              = "SQL analytics"
  description       = "Analyze your data in SageMaker Lakehouse using SQL"
  domain_identifier = var.domain_id
  status            = "ENABLED"

  environment_configurations = local.sql_analytics_configurations
}