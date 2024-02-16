locals {
  APIGW_API_URL = format("https://%s:9200/oic/_search",oci_opensearch_opensearch_cluster.opensearch_cluster.opensearch_fqdn) 
}

output api {
   value=local.APIGW_API_URL
}

resource oci_apigateway_deployment opensearch_deployment {
  count          = var.fn_image == "" ? 0 : 1  
  compartment_id = local.lz_appdev_cmp_ocid
  display_name   = "${var.prefix}-apigw-deployment"
  gateway_id     = local.apigw_ocid
  path_prefix = "/oic"
  specification {
    logging_policies {
      access_log {
        is_enabled = true
      }
      execution_log {
        #Optional
        is_enabled = true
      }
    }
    routes {
      backend {
        connect_timeout_in_seconds = "60"
        is_ssl_verify_disabled  = "true"
        read_timeout_in_seconds = "10"
        send_timeout_in_seconds = "10"
        type = "HTTP_BACKEND"
        url  = local.APIGW_API_URL
        # https://xxxx.opensearch.eu-frankfurt-1.oci.oracleiaas.com:9200/oic/_search"
      }
      methods = [
        "ANY",
      ]
      path = "/search"
    }
  }
  freeform_tags = local.freeform_tags
}
