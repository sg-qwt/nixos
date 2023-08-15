resource "time_rotating" "rotate_monthly" {
  rotation_days = 30
}

# see https://github.com/hashicorp/terraform-provider-time/issues/118
resource "time_static" "rotate_monthly" {
  rfc3339 = time_rotating.rotate_monthly.rfc3339
}
