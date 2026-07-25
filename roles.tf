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
      # "AmazonS3FullAccess",          # storage access — almost always needed
      # "AWSCloudFormationFullAccess", # if they deploy infra via CFN/CDK
      # "AmazonECS_FullAccess",        # if using containers/ECS
      # "AWSLambda_FullAccess",        # if using serverless functions
      # "CloudWatchFullAccess",        # logs/metrics/alarms — devs need to debug
      # "AmazonSNSFullAccess",         # if app uses pub/sub
      # "AmazonSQSFullAccess",         # if app uses queues
      # "SecretsManagerReadWrite",     # app secrets, DB creds
      # "AmazonElastiCacheFullAccess", # if using Redis/Memcached
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

/*
 We must iterate over the existing roles and create differente assume role policy for each of them

 In each role policy under identifiers add only the users that have that spesific role listed to them
*/
output "toset" {
  value = (keys(local.role_polices))
}
data "aws_caller_identity" "current" {

}
data "aws_iam_policy_document" "assume_role_policy" {
  for_each = toset(keys(local.role_polices))

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        for username in keys(aws_iam_user.users) : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${username}"
        if contains(local.users_map[username], each.value)
      ]
    }
  }
}

resource "aws_iam_role" "roles" {
  for_each           = toset(keys(local.role_polices))
  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy[each.value].json
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
