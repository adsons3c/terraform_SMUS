locals {
  sql_analytics_configurations = [
    {
      name                     = "Tooling"
      environment_blueprint_id = var.tooling_id
      description              = "Configuration for the Tooling"
      deployment_mode          = "ON_CREATE"
      deployment_order         = 0
      aws_account = {
        aws_account_id = var.account_id
      }
      aws_region = {
        region_name = var.region
      }
      configuration_parameters = {
        parameter_overrides = [
          {
            name        = "enableSpaces"
            value       = "false"
            is_editable = false
          },
          {
            name        = "maxEbsVolumeSize"
            is_editable = false
          },
          {
            name        = "idleTimeoutInMinutes"
            is_editable = false
          },
          {
            name        = "lifecycleManagement"
            is_editable = false
          },
          {
            name        = "enableNetworkIsolation"
            is_editable = false
          },
          {
            name = "gitConnectionArn"
          }
        ]
      }
    },
    {
      name                     = "Lakehouse Database"
      environment_blueprint_id = var.data_lake_id
      description              = "Creates databases in SageMaker Lakehouse for S3 tables and Athena"
      deployment_mode          = "ON_CREATE"
      deployment_order         = 1
      aws_account = {
        aws_account_id = var.account_id
      }
      aws_region = {
        region_name = var.region
      }
      configuration_parameters = {
        parameter_overrides = [
          {
            name        = "glueDbName"
            value       = "glue_db"
            is_editable = true
          }
        ]
      }
    },
    # {
    #   name                     = "Redshift Serverless"
    #   environment_blueprint_id = var.redshift_serverless_id
    #   description              = "Creates an Amazon Redshift Serverless workgroup"
    #   deployment_mode          = "ON_CREATE"
    #   deployment_order         = 1
    #   aws_account = {
    #     aws_account_id = var.account_id
    #   }
    #   aws_region = {
    #     region_name = var.region
    #   }
    #   configuration_parameters = {
    #     parameter_overrides = [
    #       {
    #         name        = "redshiftDbName"
    #         value       = "dev"
    #         is_editable = true
    #       },
    #       {
    #         name        = "connectToRMSCatalog"
    #         value       = "true"
    #         is_editable = false
    #       },
    #       {
    #         name        = "redshiftMaxCapacity"
    #         value       = "512"
    #         is_editable = false
    #       }
    #     ]
    #   }
    # },
    {
      name                     = "OnDemand Redshift Serverless"
      environment_blueprint_id = var.redshift_serverless_id
      description              = "Additional Redshift Serverless workgroup"
      deployment_mode          = "ON_DEMAND"
      aws_account = {
        aws_account_id = var.account_id
      }
      aws_region = {
        region_name = var.region
      }
      configuration_parameters = {
        parameter_overrides = [
          {
            name        = "redshiftDbName"
            value       = "dev"
            is_editable = true
          },
          {
            name        = "redshiftMaxCapacity"
            value       = "512"
            is_editable = true
          },
          {
            name        = "redshiftWorkgroupName"
            value       = "redshift-serverless-workgroup"
            is_editable = true
          },
          {
            name        = "redshiftBaseCapacity"
            value       = "128"
            is_editable = true
          },
          {
            name        = "connectionName"
            value       = "redshift.serverless"
            is_editable = true
          },
          {
            name        = "connectToRMSCatalog"
            value       = "false"
            is_editable = false
          }
        ]
      }
    },
    {
      name                     = "OnDemand Catalog for RMS"
      environment_blueprint_id = var.lakehouse_catalog_id
      description              = "Catalog for Redshift Managed Storage"
      deployment_mode          = "ON_DEMAND"
      aws_account = {
        aws_account_id = var.account_id
      }
      aws_region = {
        region_name = var.region
      }
      configuration_parameters = {
        parameter_overrides = [
          {
            name        = "catalogName"
            is_editable = true
          },
          {
            name        = "catalogDescription"
            value       = "RMS catalog"
            is_editable = true
          }
        ]
      }
    },
    # {
    #   name                     = "OnDemand QuickSight"
    #   environment_blueprint_id = var.quick_sight_id
    #   description              = "Amazon QuickSight for data visualization"
    #   deployment_mode          = "ON_DEMAND"
    #   aws_account = {
    #     aws_account_id = var.account_id
    #   }
    #   aws_region = {
    #     region_name = var.region
    #   }
    # }
  ]
}