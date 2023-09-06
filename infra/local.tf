locals {
  data_file_json = jsondecode(file("../modules/profiles/data/data.json"))
  ports          = local.data_file_json.ports
  fqdn           = local.data_file_json.fqdn
  openai         = local.data_file_json.openai
}
