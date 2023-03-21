locals {
  ports = jsondecode(file("../config/ports.json"))
}
