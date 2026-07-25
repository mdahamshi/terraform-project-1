locals {
  role_polices = {
    readonly = [
      "ReadOnlyAccess"
    ]
    admin = [
      "AdministratorAccess"
    ]
    developer = [
      "AmazonVPCFullAccess",
      "AmazonEC2FullAccess",
      "AmazonRDSFullAccess",
      "AmazonS3FullAccess",          # storage access — almost always needed
      "AWSCloudFormationFullAccess", # if they deploy infra via CFN/CDK
      "AmazonECS_FullAccess",        # if using containers/ECS
      "AWSLambda_FullAccess",        # if using serverless functions
      "CloudWatchFullAccess",        # logs/metrics/alarms — devs need to debug
      "AmazonSNSFullAccess",         # if app uses pub/sub
      "AmazonSQSFullAccess",         # if app uses queues
      "SecretsManagerReadWrite",     # app secrets, DB creds
      "AmazonElastiCacheFullAccess", # if using Redis/Memcached
    ]
    auditor = [
      "SecurityAudit"
    ]
  }
  role_polices_list = flatten([
    for role, polices in local.role_polices : [
      for policy in polices : {
        role   = role
        policy = policy
      }
    ]
  ])
}

