locals {
  users_from_yaml = yamldecode(file("${path.module}/users.yaml"))
}

output "users_from_yaml" {
  value = local.users_from_yaml
}
