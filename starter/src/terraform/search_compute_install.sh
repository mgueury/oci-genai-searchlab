echo OIC_HOST=${OIC_HOST}
echo OIC_CLIENT_ID=${OIC_CLIENT_ID} 
echo OIC_CLIENT_SECRET=${OIC_CLIENT_SECRET}
echo OIC_SCOPE=${OIC_SCOPE}
echo AGENT_GROUP=${AGENT_GROUP}
echo OPENSEARCH_HOST=${OPENSEARCH_HOST}
echo IDCS_URL=${IDCS_URL}

export OIC_NAME=`echo $OIC_HOST | sed 's#https://##' | sed 's/\..*//'`
export IDCS_HOST=`echo $IDCS_URL | sed 's#https://##' | sed 's/:.*//'`
export OIC_DOMAIN=`echo $OIC_HOST | sed 's/.*integration\.//'`

echo OIC_NAME=$OIC_NAME
echo OIC_DOMAIN=$OIC_DOMAIN
echo IDCS_HOST=$IDCS_HOST

# Download the OIC_agent
# OIC Gen 2
# curl -X GET  $OIC_HOST/ic/api/integration/v1/agents/binaries/connectivity -u $OCI_USER:$OCI_PASSWORD -o $HOME/oic_connectivity_agent.zip
# curl -X GET https://design.integration.$OIC_DOMAIN/ic/api/integration/v1/agents/binaries/connectivity?integrationInstance=$OIC_NAME -u $OCI_USER:$OCI_PASSWORD -o $HOME/oic_connectivity_agent.zip
# ls -a

# OIC3
# export OIC_SCOPE=https://xxxxxxx.integration.eu-frankfurt-1.ocp.oraclecloud.com:443/ic/api/
# export OIC_CLIENT_ID=xxxx
# export OIC_CLIENT_SECRET=xxxx
export ACCESS_TOKEN=`curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials&scope=$OIC_SCOPE" -u "$OIC_CLIENT_ID:$OIC_CLIENT_SECRET" "https://$IDCS_HOST/oauth2/v1/token" | jq -r ".access_token"`
curl -X GET "https://design.integration.$OIC_DOMAIN/ic/api/integration/v1/agents/binaries/connectivity?integrationInstance=$OIC_NAME" -H "Authorization: Bearer $ACCESS_TOKEN" -o oic_connectivity_agent.zip
curl -X GET "https://design.integration.$OIC_DOMAIN/ic/api/integration/v1/agentgroups/OPENSEARCH_AGENT_GROUP/configuration?integrationInstance=$OIC_NAME" -H "Authorization: Bearer $ACCESS_TOKEN" -o InstallerProfile.cfg

# Unzip it
mkdir oic_agent
cd oic_agent
unzip ../oic_connectivity_agent.zip
cp ../InstallerProfile.cfg .

# Install JDK 17
sudo yum install java-17-openjdk-devel -y

# Get the SSL certificate of OpenSearch since it is invalid
echo -n | openssl s_client -connect $OPENSEARCH_HOST:9200 -servername $OPENSEARCH_HOST | openssl x509 > /tmp/opensearch.cert
cat /tmp/opensearch.cert 
cd agenthome/agent/cert/ 
ls keystore.jks
keytool -importcert -keystore keystore.jks -storepass changeit -alias opensearch -noprompt -file /tmp/opensearch.cert
cd ../../..

# Create a start command
echo 'java -jar connectivityagent.jar > agent.log 2>&1 &' > start.sh
chmod +x start.sh

./start.sh

## XX ideally there should something to start the start command on reboot of the server
