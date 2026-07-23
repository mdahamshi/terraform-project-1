locals {
  users_from_yaml = yamldecode(file("${path.module}/users.yaml")).users
}

resource "aws_iam_user" "users" {
  for_each      = toset(local.users_from_yaml[*].username)
  name          = each.value
  force_destroy = true
}



output "users_from_yaml" {
  value = local.users_from_yaml
}
