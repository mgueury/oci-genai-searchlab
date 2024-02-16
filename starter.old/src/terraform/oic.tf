variable oic_ocid {}

data "oci_integration_integration_instance" "oic" {
    #Required
    integration_instance_id = var.oic_ocid
}