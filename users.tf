locals {
  users_from_yaml = yamldecode(file("${path.module}/users.yaml")).users
}

resource "aws_iam_user" "users" {
  for_each      = toset(local.users_from_yaml[*].username)
  name          = each.value
  force_destroy = true
}

resource "aws_iam_user_login_profile" "login_profiles" {
  for_each        = aws_iam_user.users
  user            = each.value.name
  password_length = 8

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key
    ]
  }
}

output "passwords" {
  value     = { for user, user_login in aws_iam_user_login_profile.login_profiles : user => user_login.password }
  sensitive = true
}

output "users_from_yaml" {
  value = local.users_from_yaml
}
