   
variable "openapi_spec" {
  default = "openapi: 3.0.0\ninfo:\n  version: 1.0.0\n  title: Test API\n  license:\n    name: MIT\npaths:\n  /ping:\n    get:\n      responses:\n        '200':\n          description: OK"
}

resource oci_apigateway_gateway starter_apigw {
  compartment_id = local.lz_appdev_cmp_ocid
  display_name  = "${var.prefix}-apigw"
  endpoint_type = "PUBLIC"
  subnet_id = data.oci_core_subnet.starter_public_subnet.id
  freeform_tags = local.freeform_tags       
}

resource "oci_apigateway_api" "starter_api" {
  compartment_id = local.lz_appdev_cmp_ocid
  content       = var.openapi_spec
  display_name  = "${var.prefix}-api"
  freeform_tags = local.freeform_tags   
}

locals {
  apigw_ocid = try(oci_apigateway_gateway.starter_apigw.id, "")
  apigw_ip   = try(oci_apigateway_gateway.starter_apigw.ip_addresses[0].ip_address,"")
}   

// API Management - Tags
variable git_url { default = "" }

locals {
  api_git_tags = {
      group = local.group_name
      app_prefix = var.prefix

      api_icon = var.language
      api_git_url = var.git_url 
      api_git_spec_path = "src/app/openapi_spec.yaml"
      api_git_spec_type = "OpenAPI"
      api_git_endpoint_path = "src/terraform/apigw_existing.tf"
      api_endpoint_url = "app/dept"
  }
  api_tags = var.git_url !=""? local.api_git_tags:local.freeform_tags
}



resource "oci_apigateway_deployment" "starter_apigw_deployment" {   
  count          = var.fn_image == "" ? 0 : 1   
  compartment_id = local.lz_appdev_cmp_ocid
  display_name   = "${var.prefix}-apigw-deployment"
  gateway_id     = local.apigw_ocid
  path_prefix    = "/${var.prefix}"
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
      path    = "/app/dept"
      methods = [ "ANY" ]
      backend {
        type = "ORACLE_FUNCTIONS_BACKEND"
        function_id   = oci_functions_function.starter_fn_function[0].id
      }
    }    
    routes {
      path    = "/app/info"
      methods = [ "ANY" ]
      backend {
        type = "STOCK_RESPONSE_BACKEND"
        body   = "Function ${var.language}"
        status = 200
      }
    }    
    routes {
      path    = "/"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "${local.bucket_url}/index.html"
        connect_timeout_in_seconds = 10
        read_timeout_in_seconds = 30
        send_timeout_in_seconds = 30
      }
    }    
    routes {
      path    = "/{pathname*}"
      methods = [ "ANY" ]
      backend {
        type = "HTTP_BACKEND"
        url    = "${local.bucket_url}/$${request.path[pathname]}"
      }
    }
  }
  freeform_tags = local.api_tags
}