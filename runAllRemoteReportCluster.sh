#!/bin/bash

if [ "$#" -ne 2 ]
then
    echo "$0 Cloud SimulationClass"
    exit 1
fi

cd ansible
ansible-playbook -i ec2.py gatling.yml --extra-vars "CLOUD=$1 SIMULATION_NAME=$2" --private-key "../$1/ssh_keys/$2/id_rsa"
cd ..

./reportWithRemoteGatling.sh $1 $2
#./cleanupLocal.sh

echo "Remote execution completed"
