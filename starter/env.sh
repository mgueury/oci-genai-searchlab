#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export OCI_STARTER_CREATION_DATE=2023-04-26-13-37-53-878068
export OCI_STARTER_VERSION=1.5

# Env Variables
export TF_VAR_prefix="search"

export TF_VAR_java_framework="springboot"
export TF_VAR_java_vm="jdk"
export TF_VAR_java_version="17"
export TF_VAR_ui_strategy="html"
export TF_VAR_db_strategy="none"
export TF_VAR_deploy_strategy="function"
export TF_VAR_language="java"
export TF_VAR_db_user=""

if [ -f $SCRIPT_DIR/../group_common_env.sh ]; then
  . $SCRIPT_DIR/../group_common_env.sh
elif [ -f $HOME/.oci_starter_profile ]; then
  . $HOME/.oci_starter_profile  
else
  export TF_VAR_oic_ocid="__TO_FILL__"
  export TF_VAR_oic_appid="__TO_FILL__"
  export TF_VAR_oic_client_id="__TO_FILL__"
  export TF_VAR_oic_client_secret="__TO_FILL__"
  export TF_VAR_oic_scope="__TO_FILL__"
  # export TF_VAR_compartment_ocid=ocid1.compartment.xxxxx
  # TF_VAR_license_model : BRING_YOUR_OWN_LICENSE or LICENSE_INCLUDED
  # export TF_VAR_license_model="LICENSE_INCLUDED"
  # TF_VAR_auth_token : See doc: https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm
  export TF_VAR_auth_token="__TO_FILL__"

  # Oracle Identity Domain typically "Default" or "OracleIdentityCloudService"
  # export TF_VAR_idcs_domain_name="Default"

  # Landing Zone
  # export TF_VAR_lz_appdev_cmp_ocid=$TF_VAR_compartment_ocid
  # export TF_VAR_lz_database_cmp_ocid=$TF_VAR_compartment_ocid
  # export TF_VAR_lz_network_cmp_ocid=$TF_VAR_compartment_ocid
  # export TF_VAR_lz_security_cmp_ocid=$TF_VAR_compartment_ocid
fi

# Get other env variables automatically (-silent flag can be passed)
. $SCRIPT_DIR/bin/auto_env.sh $1
