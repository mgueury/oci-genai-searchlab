/*
variable idcs_at {}

resource "oci_integration_integration_instance" "opensearch-oic" {
  #Required
  compartment_id            = var.compartment_ocid
  display_name              = "opensearch-oic"
  integration_instance_type = "STANDARD"
  is_byol                   = "true"
  message_packs             = "1"

  # is_file_server_enabled    = true
  is_visual_builder_enabled = true
  state                     = "ACTIVE"
  idcs_at                   = var.idcs_at 
}
*/