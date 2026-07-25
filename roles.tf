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

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::953907014716:user/mohammad"]
    }
  }
}

resource "aws_iam_role" "roles" {
  for_each           = toset(keys(local.role_polices))
  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy" "managed_polices" {
  for_each = toset(local.role_polices_list[*].policy)
  arn      = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_iam_role_policy_attachment" "attachments" {
  count      = length(local.role_polices_list)
  role       = aws_iam_role.roles[local.role_polices_list[count.index].role].name
  policy_arn = data.aws_iam_policy.managed_polices[local.role_polices_list[count.index].policy].arn
}
