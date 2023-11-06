resource "oci_opensearch_opensearch_cluster" "opensearch_cluster" {
  depends_on = [oci_identity_policy.search-policy]

  #Required
  compartment_id                     = local.lz_appdev_cmp_ocid
  data_node_count                    = 1
  data_node_host_memory_gb           = 32
  data_node_host_ocpu_count          = 1
  data_node_host_type                = "FLEX"
  data_node_storage_gb               = 50
  display_name                       = "opensearch-cluster"
  master_node_count                  = 1
  master_node_host_memory_gb         = 24
  master_node_host_ocpu_count        = 1
  master_node_host_type              = "FLEX"
  opendashboard_node_count           = 1
  opendashboard_node_host_memory_gb  = 16
  opendashboard_node_host_ocpu_count = 1
  software_version                   = "2.8.0"
  subnet_compartment_id              = local.lz_network_cmp_ocid
  subnet_id                          = data.oci_core_subnet.starter_public_subnet.id
  vcn_compartment_id                 = local.lz_network_cmp_ocid
  vcn_id                             = oci_core_vcn.starter_vcn.id

  // security_mode                     = "ENFORCING"
  // security_master_user_name         = var.security_master_user_name
  // security_master_user_password_hash = var.security_master_user_password_hash  
}

data "oci_opensearch_opensearch_clusters" "opensearch_clusters" {
  #Required
  compartment_id = local.lz_appdev_cmp_ocid
}
