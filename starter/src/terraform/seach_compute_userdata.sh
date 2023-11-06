#!/bin/bash
export OIC_HOST=${OIC_HOST}
# export OIC_CLIENT_ID=${OIC_CLIENT_ID} 
# export OIC_CLIENT_SECRET=${OIC_CLIENT_SECRET}
export OPENSEARCH_HOST=${OPENSEARCH_HOST}

env > /home/opc/env2.log

cd /home/opc
while [ ! -f ./install_compute.sh ]; do 
  echo "." >> /home/opc/wait.log
  sleep 1; 
done

chmod +x ./search_compute_install.sh
sudo -Eu opc bash -c './search_compute_install.sh > /tmp/search_compute_install.log'
