locals {
  data_file_json = jsondecode(file("../resources/shared-data/data.json"))
  ports          = local.data_file_json.ports
  fqdn           = local.data_file_json.fqdn
}
