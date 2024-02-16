
variable oic_appid {}
variable idcs_domain_name { default = "Default" }
variable idcs_url { default = "" }

data "oci_identity_domains" "starter_domains" {
    #Required
    compartment_id = var.tenancy_ocid
    display_name = var.idcs_domain_name
}

locals {
  idcs_url = (var.idcs_url!="")?var.idcs_url:data.oci_identity_domains.starter_domains.domains[0].url
}

resource "oci_identity_domains_dynamic_resource_group" "search-fn-dyngroup" {
    #Required
    display_name = "${var.prefix}-fn-dyngroup"
    idcs_endpoint = local.idcs_url
    matching_rule = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${var.compartment_ocid}'}"
    schemas = ["urn:ietf:params:scim:schemas:oracle:idcs:DynamicResourceGroup"]
}

resource "oci_identity_domains_dynamic_resource_group" "search-oic-dyngroup" {
    #Required
    display_name = "${var.prefix}-oic-dyngroup"
    idcs_endpoint = local.idcs_url
    matching_rule = "ALL {resource.id = '${var.oic_appid}'}"
    schemas = ["urn:ietf:params:scim:schemas:oracle:idcs:DynamicResourceGroup"]
}

resource "oci_identity_policy" "starter_opensearch_policy" {
  name           = "${var.prefix}-policy"
  description    = "${var.prefix} policy"
  compartment_id = local.lz_appdev_cmp_ocid

  statements = [
    "Allow service opensearch to manage vnics in compartment id ${local.lz_appdev_cmp_ocid}",
    "Allow service opensearch to use subnets in compartment id ${local.lz_appdev_cmp_ocid}",
    "Allow service opensearch to use network-security-groups in compartment id ${local.lz_appdev_cmp_ocid}",
    "Allow service opensearch to manage vcns in compartment id ${local.lz_appdev_cmp_ocid}",
    "Allow dynamic-group ${var.idcs_domain_name}/${var.prefix}-fn-dyngroup to manage objects in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${var.idcs_domain_name}/${var.prefix}-oic-dyngroup to manage all-resources in compartment id ${var.compartment_ocid}"
  ]
}

/*
## Issue to fix:
# - if the policy is defined at the compartment level -> Error when creating Opensearch  
# - if the user is not an Admin, he can not create the policy in the root compartment
resource "oci_identity_policy" "search-policy" {
  name           = "${var.prefix}-policy"
  description    = "${var.prefix} policy"
  compartment_id = var.tenancy_ocid
  statements = [
    "Allow service opensearch to manage vnics in compartment id ${var.compartment_ocid}",
    "Allow service opensearch to use subnets in compartment id ${var.compartment_ocid}",
    "Allow service opensearch to use network-security-groups in compartment id ${var.compartment_ocid}",
    "Allow service opensearch to manage vcns in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${var.prefix}-fn-dyngroup to manage objects in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${var.prefix}-oic-dyngroup to manage all-resources in tenancy"
  ]
}

Error: 403-Forbidden, Permission denied: Cluster creation failed. Ensure required policies are created for your tenancy. If the error persists, contact support.
Suggestion: Please retry or contact support for help with service: Opensearch Cluster
Documentation: https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/opensearch_opensearch_cluster
API Reference: https://docs.oracle.com/iaas/api/#/en/opensearch/20180828/OpensearchCluster/CreateOpensearchCluster
Request Target: POST https://search-indexing.eu-frankfurt-1.oci.oraclecloud.com/20180828/opensearchClusters
Provider version: 5.11.0, released on 2023-08-30. This provider is 2 Update(s) behind to current.
Service: Opensearch Cluster
Operation Name: CreateOpensearchCluster
OPC request ID: f5e05112e4ee082f706bcad039042335/338336F868BCB1569D120415661E46DA/B62C85B3BB1C066DB360CB0DA04B9F08
*/
