locals {
  ports = jsondecode(file("../config/data.json")).ports
  fqdn = jsondecode(file("../config/data.json")).fqdn
}
