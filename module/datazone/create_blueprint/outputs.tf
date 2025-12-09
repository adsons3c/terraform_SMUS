output "lakehouse_catalog_id" {
  value = aws_datazone_environment_blueprint_configuration.this["LakehouseCatalog"].environment_blueprint_id
}

output "amazon_bedrock_guardrail_id" {
  value = aws_datazone_environment_blueprint_configuration.this["AmazonBedrockGuardrail"].environment_blueprint_id
}

output "ml_experiments_id" {
  value = aws_datazone_environment_blueprint_configuration.this["MLExperiments"].environment_blueprint_id
}

output "tooling_id" {
  value = aws_datazone_environment_blueprint_configuration.this["Tooling"].environment_blueprint_id
}

output "redshift_serverless_id" {
  value = aws_datazone_environment_blueprint_configuration.this["RedshiftServerless"].environment_blueprint_id
}

output "emr_serverless_id" {
  value = aws_datazone_environment_blueprint_configuration.this["EmrServerless"].environment_blueprint_id
}

output "workflows_id" {
  value = aws_datazone_environment_blueprint_configuration.this["Workflows"].environment_blueprint_id
}

output "amazon_bedrock_prompt_id" {
  value = aws_datazone_environment_blueprint_configuration.this["AmazonBedrockPrompt"].environment_blueprint_id
}

output "data_lake_id" {
  value = aws_datazone_environment_blueprint_configuration.this["DataLake"].environment_blueprint_id
}

output "amazon_bedrock_evaluation_id" {
  value = aws_datazone_environment_blueprint_configuration.this["AmazonBedrockEvaluation"].environment_blueprint_id
}

output "amazon_bedrock_knowledge_base_id" {
  value = aws_datazone_environment_blueprint_configuration.this["AmazonBedrockKnowledgeBase"].environment_blueprint_id
}

output "partner_apps_id" {
  value = aws_datazone_environment_blueprint_configuration.this["PartnerApps"].environment_blueprint_id
}

output "amazon_bedrock_chat_agent_id" {
  value = aws_datazone_environment_blueprint_configuration.this["AmazonBedrockChatAgent"].environment_blueprint_id
}

output "amazon_bedrock_function_id" {
  value = aws_datazone_environment_blueprint_configuration.this["AmazonBedrockFunction"].environment_blueprint_id
}

output "amazon_bedrock_flow_id" {
  value = aws_datazone_environment_blueprint_configuration.this["AmazonBedrockFlow"].environment_blueprint_id
}

output "emr_on_ec2_id" {
  value = aws_datazone_environment_blueprint_configuration.this["EmrOnEc2"].environment_blueprint_id
}

output "quick_sight_id" {
  value = aws_datazone_environment_blueprint_configuration.this["QuickSight"].environment_blueprint_id
}