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
      "AmazonRDSFullAccess"
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

