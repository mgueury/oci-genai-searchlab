#!/bin/bash
PROJECT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export BIN_DIR=$PROJECT_DIR/bin

# Env Variables
export TF_VAR_prefix="search"

export TF_VAR_java_framework="springboot"
export TF_VAR_java_vm="graalvm"
export TF_VAR_java_version="21"
export TF_VAR_ui_type="html"
export TF_VAR_db_type="opensearch"
# export TF_VAR_license_model="BRING_YOUR_OWN_LICENSE"
export TF_VAR_language="java"
export TF_VAR_deploy_type="function"

export TF_VAR_compartment_ocid="__TO_FILL__"

# TF_VAR_auth_token : See doc: https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm
# export TF_VAR_auth_token="__TO_FILL__"
export TF_VAR_oic_ocid="__TO_FILL__"
export TF_VAR_oic_appid="__TO_FILL__"

# Oracle Identity Domain typically "Default" or "OracleIdentityCloudService"
# export TF_VAR_idcs_domain_name="Default"

if [ -f $PROJECT_DIR/../group_common_env.sh ]; then
  . $PROJECT_DIR/../group_common_env.sh
elif [ -f $PROJECT_DIR/../../group_common_env.sh ]; then
  . $PROJECT_DIR/../../group_common_env.sh
elif [ -f $HOME/.oci_starter_profile ]; then
  . $HOME/.oci_starter_profile
fi

# Creation Details
export OCI_STARTER_CREATION_DATE=2024-02-15-19-37-45-112045
export OCI_STARTER_VERSION=2.0
export OCI_STARTER_PARAMS="prefix,java_framework,java_vm,java_version,ui_type,db_type,license_model,mode,infra_as_code,db_password,compartment_ocid,language,deploy_type"

# Get other env variables automatically (-silent flag can be passed)
. $BIN_DIR/auto_env.sh $1
