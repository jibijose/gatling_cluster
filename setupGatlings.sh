#!/bin/bash

. ./variablesGatlings.sh

echo "### `date` Cleaning previous runs from localhost"
rm -rf $GATHER_REPORTS_DIR
mkdir $GATHER_REPORTS_DIR

echo "### `date` Cleanup and setup on hosts"
for HOST in "${HOSTS[@]}"
do
  echo "Setting up ssh known hosts for host: $HOST"
  ssh-keygen -R $HOST
  ssh-keyscan -H $HOST >> ~/.ssh/known_hosts

  echo "Cleaning previous run directory  $RUN_HOME on host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "rm -rf $RUN_HOME"

  echo "Setup on host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "mkdir $RUN_HOME"
  echo "Downloading gatling on host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "wget -q -P $RUN_HOME $GATLING_DOWNLOAD_LINK"
done

echo "Waiting $DOWNLOAD_TIME seconds for downloads to finish"
sleep $DOWNLOAD_TIME
for HOST in "${HOSTS[@]}"
do
  echo "Unzipping gatling on host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "unzip -q $RUN_HOME/$GATLING_ZIP -d $RUN_HOME"
done