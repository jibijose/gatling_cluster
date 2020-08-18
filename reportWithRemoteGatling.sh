#!/bin/bash

. ./variablesGatlings.sh

REMOTEHOST=`echo $HOSTSLIST | awk -F '[ ]' '{print $1}'`

cd ansible
echo $REMOTEHOST > hosts
ansible-playbook -i hosts report-pre-step.yml --extra-vars "CLOUD=$CLOUD SIMULATION_NAME=$SIMULATION_NAME" --private-key "../$CLOUD/ssh_keys/$SIMULATION_NAME/id_rsa"
cd ..

echo "### `date` Getting private IPs of each hosts"
hostips=""
for HOST in "${HOSTS[@]}"
do
    hostpvtip=$(ssh -i $LOCAL_PRIVATE_KEY $USER_NAME@$HOST "hostname -I")
    hostips=$hostips" "$hostpvtip
    echo "IP $HOST mapped to $hostpvtip"
done
HOSTSLIST=$hostips
HOSTS=($HOSTSLIST)
echo "Mapped new ips [$HOSTSLIST]"

echo "### `date` Collecting simulation logs"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "rm -rf ${REMOTE_GATHER_REPORTS_DIR}"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "mkdir -p ${REMOTE_GATHER_REPORTS_DIR}"
for HOST in "${HOSTS[@]}"
do
    echo "Collecting logs from host: $HOST"
    ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "ssh -o 'StrictHostKeyChecking no' -n -f $USER_NAME@$HOST 'ls -t $GATLING_REPORT_DIR | head -n 1 | xargs -I {} mv ${GATLING_REPORT_DIR}{} ${GATLING_REPORT_DIR}report'"
    ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "scp $USER_NAME@$HOST:${GATLING_REPORT_DIR}report/simulation.log ${REMOTE_GATHER_REPORTS_DIR}/simulation-$HOST.log"
done


cd ansible
echo $REMOTEHOST > hosts
ansible-playbook -i hosts report-mid-step.yml --extra-vars "CLOUD=$CLOUD SIMULATION_NAME=$SIMULATION_NAME" --private-key "../$CLOUD/ssh_keys/$SIMULATION_NAME/id_rsa"
cd ..

./waitGatlings.sh $CLOUD $SIMULATION_NAME

cd ansible
echo $REMOTEHOST > hosts
ansible-playbook -i hosts report-post-step.yml --extra-vars "CLOUD=$CLOUD SIMULATION_NAME=$SIMULATION_NAME" --private-key "../$CLOUD/ssh_keys/$SIMULATION_NAME/id_rsa"
cd ..

#using ubuntu
#google-chrome ${GATLING_REPORT_DIR}reports/index.html