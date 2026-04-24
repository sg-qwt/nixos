data "azurerm_storage_account" "persist" {
  name                = "sa25542"
  resource_group_name = "persistent"
}

data "azurerm_storage_blob" "image_vhd" {
  name                   = "nixosbase-2023-05-28.vhd"
  storage_account_name   = data.azurerm_storage_account.persist.name
  storage_container_name = "vhds"
}

data "azurerm_storage_blob" "image_vhd_20251012" {
  name                   = "nixos-image-azure-25.11.20251012.cf3f5c4-x86_64-linux.vhd"
  storage_account_name   = data.azurerm_storage_account.persist.name
  storage_container_name = "vhds"
}

data "azurerm_shared_image_gallery" "gallery" {
  name                = "images"
  resource_group_name = "persistent"
}

resource "azurerm_shared_image" "nixos" {
  name                = "nixos-image-shared"
  gallery_name        = data.azurerm_shared_image_gallery.gallery.name
  resource_group_name = "persistent"
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
