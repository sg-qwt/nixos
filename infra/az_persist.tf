data "azurerm_resource_group" "persistent" {
  name = "persistent"
}

data "azurerm_storage_account" "persist" {
  name                = "sa25542"
  resource_group_name = data.azurerm_resource_group.persistent.name
}

data "azurerm_storage_container" "vhds" {
  name               = "vhds"
  storage_account_id = data.azurerm_storage_account.persist.id
}

data "azurerm_storage_blob" "image_vhd" {
  name                 = "nixosbase-2023-05-28.vhd"
  storage_container_id = data.azurerm_storage_container.vhds.id
}

data "azurerm_storage_blob" "image_vhd_20251012" {
  name                 = "nixos-image-azure-25.11.20251012.cf3f5c4-x86_64-linux.vhd"
  storage_container_id = data.azurerm_storage_container.vhds.id
}

data "azurerm_shared_image_gallery" "gallery" {
  name                = "images"
  resource_group_name = data.azurerm_resource_group.persistent.name
}

resource "azurerm_shared_image" "nixos" {
  name                = "nixos-image-shared"
  gallery_name        = data.azurerm_shared_image_gallery.gallery.name
  resource_group_name = data.azurerm_resource_group.persistent.name
  location            = local.az_shared_image_location
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "dev"
    offer     = "dev"
    sku       = "dev"
  }
}

resource "azurerm_shared_image_version" "nixos20251012" {
  name                                     = "0.0.2"
  gallery_name                             = azurerm_shared_image.nixos.gallery_name
  image_name                               = azurerm_shared_image.nixos.name
  resource_group_name                      = azurerm_shared_image.nixos.resource_group_name
  location                                 = azurerm_shared_image.nixos.location
  blob_uri                                 = data.azurerm_storage_blob.image_vhd_20251012.id
  storage_account_id                       = data.azurerm_storage_account.persist.id
  deletion_of_replicated_locations_enabled = true

  dynamic "target_region" {
    for_each = local.az_image_target_regions

    content {
      name                   = target_region.value
      regional_replica_count = 1
      storage_account_type   = "Standard_LRS"
    }
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "sharedrive" {
  name                     = "sdrive${random_string.suffix.result}"
  resource_group_name      = data.azurerm_resource_group.persistent.name
  location                 = data.azurerm_resource_group.persistent.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "drivedata" {
  name                  = "data"
  storage_account_id  = azurerm_storage_account.sharedrive.id
  container_access_type = "private"
}

output "az_drive_account_name" {
  value = azurerm_storage_account.sharedrive.name
}

output "az_drive_container_name" {
  value = azurerm_storage_container.drivedata.name
}

output "az_drive_account_key" {
  value     = azurerm_storage_account.sharedrive.primary_access_key
  sensitive = true
}
