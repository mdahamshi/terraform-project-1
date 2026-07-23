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

}


output "role_polices" {
  value = local.role_polices
}
