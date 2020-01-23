#!/bin/bash

. ./variablesGatlings.sh

REMOTEHOST=`echo $HOSTSLIST | awk -F '[ ]' '{print $1}'`

echo "### `date` Setting remote Gatling result cluster on host: $REMOTEHOST"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "rm -rf $REMOTE_RUN_DIR"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "mkdir $REMOTE_RUN_DIR"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "wget -q -P $REMOTE_RUN_DIR $GATLING_DOWNLOAD_LINK"
echo "Waiting $DOWNLOAD_TIME seconds for downloads to finish"
sleep $DOWNLOAD_TIME
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "unzip -q $REMOTE_RUN_DIR/$GATLING_ZIP -d $REMOTE_RUN_DIR"

echo "### `date` Setting up remote gatling host " $REMOTEHOST
scp -i $LOCAL_PRIVATE_KEY -r $LOCAL_PRIVATE_KEY $USER_NAME@$REMOTEHOST:/home/$USER_NAME/.ssh
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "chmod 600 /home/$USER_NAME/.ssh/id_rsa"
scp -i $LOCAL_PRIVATE_KEY -r $LOCAL_PUBLIC_KEY $USER_NAME@$REMOTEHOST:/home/$USER_NAME/.ssh
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "chmod 600 /home/$USER_NAME/.ssh/id_rsa.pub"

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
    ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "scp $USER_NAME@$HOST:${GATLING_REPORT_DIR}report/simulation.log ${REMOTE_GATHER_REPORTS_DIR}simulation-$HOST.log"
done

ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "mv $REMOTE_GATHER_REPORTS_DIR $REMOTE_RESULT_DIR"

echo "Generating combined reports from $HOSTSLIST"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "sed -i 's/-Xmx1G/-Xms$GATLING_MEMORY -Xmx$GATLING_MEMORY/g' $REMOTE_GATLING_RUNNER"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "sed -i 's/#lowerBound = 800/lowerBound = $GATLING_REQ_LOWER_BOUND/g' $REMOTE_GATLING_CONF"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "sed -i 's/#higherBound = 1200/higherBound = $GATLING_REQ_HIGHER_BOUND/g' $REMOTE_GATLING_CONF"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "sed -i 's/#enableGA = true/enableGA = $GATLING_ENABLE_GA/g' $REMOTE_GATLING_CONF"
#ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "sed -i 's/#maxRetry = 2/maxRetry = $GATLING_MAX_RETRY/g' $REMOTE_GATLING_CONF"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "sed -i 's/#requestTimeout = 60000/requestTimeout = $GATLING_REQ_TIMEOUT/g' $REMOTE_GATLING_CONF"

ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "$REMOTE_GATLING_RUNNER -ro reports"

./waitGatlings.sh $CLOUD $SIMULATION_NAME

echo "Copying combined reports from $REMOTEHOST"
ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$REMOTEHOST "rm -rf ${REMOTE_RESULT_DIR}reports/*.log"
rm -rf $GATHER_REPORTS_DIR
mkdir -p $GATHER_REPORTS_DIR
scp -i $LOCAL_PRIVATE_KEY -r $USER_NAME@$REMOTEHOST:${REMOTE_RESULT_DIR}reports/* $GATHER_REPORTS_DIR

#using macOSX
echo "### `date` Displaying report on browser"
open ${GATHER_REPORTS_DIR}index.html &

#using ubuntu
#google-chrome ${GATLING_REPORT_DIR}reports/index.html