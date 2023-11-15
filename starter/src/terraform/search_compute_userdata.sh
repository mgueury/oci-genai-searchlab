#!/bin/bash
export OIC_HOST=${OIC_HOST}
export OPENSEARCH_HOST=${OPENSEARCH_HOST}

env > /home/opc/env2.log

cd /home/opc
while [ ! -f ./install_compute.sh ]; do 
  echo "." >> /home/opc/wait.log
  sleep 1; 
done

chmod +x ./search_compute_install.sh
sudo -Eu opc bash -c './search_compute_install.sh > /tmp/search_compute_install.log'
