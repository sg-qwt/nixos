locals {
  data-file = file("../modules/profiles/data/data.json")
  ports     = jsondecode(local.data-file).ports
  fqdn      = jsondecode(local.data-file).fqdn
}
