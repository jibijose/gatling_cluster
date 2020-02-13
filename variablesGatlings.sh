#!/bin/bash

if [ "$#" -ne 2 ]
then
    echo "$0 Cloud SimulationClass"
    exit 1
fi

CLOUD=$1
if [ $CLOUD != 'aws' ] && [ $CLOUD != 'azure' ] && [ $CLOUD != 'local' ]
then
  echo "Cloud value must be 'aws' or 'azure'"
  exit
fi
SIMULATION_NAME=$2

########################################################################################################
GATLING_MEMORY=4G
GATLING_REQ_LOWER_BOUND=200
GATLING_REQ_HIGHER_BOUND=500
GATLING_ENABLE_GA=false
GATLING_MAX_RETRY=0
GATLING_REQ_TIMEOUT=60000
########################################################################################################

#Assuming same user name for all hosts
USER_NAME='ubuntu'
SIMULATION_NAME_ORIGINAL='$SIMULATION_NAME'_original
SIMULATION_NAME_EDITED='$SIMULATION_NAME'_edited
DOWNLOAD_TIME=10

echo "Getting hosts from $CLOUD"
if [ $CLOUD == 'aws' ]
then
  HOSTSLIST=`aws ec2 describe-instances --filters "Name=tag:Name,Values=gatling-cluster-$SIMULATION_NAME-*-vm" --query "Reservations[].Instances[].PublicIpAddress"  --output text`
elif [ $CLOUD == 'azure' ]
then
  azure_gatling_rg=`az resource list --tag "environment=gatling_test_$SIMULATION_NAME" --query "[0].resourceGroup" -o tsv`
  HOSTSLIST=`az vm list --resource-group "$azure_gatling_rg" --show-details --query "[].privateIps" --o tsv | xargs | sed -e 's/ / /g'`
else
  HOSTSLIST="127.0.0.1"
fi
HOSTS=($HOSTSLIST)
echo "### `date` Running gatling on [$HOSTSLIST]"
exit
#Assuming all Gatling installation in same path (with write permissions)
RUN_HOME=/home/$USER_NAME/gatling_run_dir
LOCAL_RUN_DIR=`pwd`
REMOTE_RUN_DIR=/home/$USER_NAME/gatling_result_dir

GATLING_ZIP=gatling-charts-highcharts-bundle-3.3.1-bundle.zip
GATLING_HOME_DIR_NAME=gatling-charts-highcharts-bundle-3.3.1
GATLING_HOME=$RUN_HOME/$GATLING_HOME_DIR_NAME
GATLING_SIMULATIONS_DIR=$GATLING_HOME/user-files/simulations
GATLING_RESOURCES_DIR=$GATLING_HOME/user-files/resources
GATLING_RUNNER=$GATLING_HOME/bin/gatling.sh
GATLING_CONF=$GATLING_HOME/conf/gatling.conf
GATLING_REPORT_DIR=$GATLING_HOME/results/
GATLING_DOWNLOAD_LINK=https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.3.1/gatling-charts-highcharts-bundle-3.3.1-bundle.zip

GATHER_REPORTS_DIR=$LOCAL_RUN_DIR/reports/

LOCAL_GATLING_HOME=$LOCAL_RUN_DIR/$GATLING_HOME_DIR_NAME
LOCAL_GATLING_ZIP=$LOCAL_RUN_DIR/$GATLING_ZIP
LOCAL_REPORT_DIR=$LOCAL_GATLING_HOME/results/
LOCAL_GATLING_RUNNER=$LOCAL_GATLING_HOME/bin/gatling.sh
LOCAL_GATLING_CONF=$LOCAL_GATLING_HOME/conf/gatling.conf
LOCAL_PRIVATE_KEY=$LOCAL_RUN_DIR/$CLOUD/ssh_keys/$SIMULATION_NAME/id_rsa
LOCAL_PUBLIC_KEY=$LOCAL_RUN_DIR/$CLOUD/ssh_keys/$SIMULATION_NAME/id_rsa.pub

REMOTE_GATLING_HOME=$REMOTE_RUN_DIR/$GATLING_HOME_DIR_NAME
REMOTE_RESULT_DIR=$REMOTE_GATLING_HOME/results/
REMOTE_GATLING_RUNNER=$REMOTE_GATLING_HOME/bin/gatling.sh
REMOTE_PRIVATE_KEY=$REMOTE_GATLING_HOME/$CLOUD/ssh_keys/id_rsa
REMOTE_GATHER_REPORTS_DIR=/home/$USER_NAME/reports/
REMOTE_GATLING_RUNNER=$REMOTE_GATLING_HOME/bin/gatling.sh
REMOTE_GATLING_CONF=$REMOTE_GATLING_HOME/conf/gatling.conf