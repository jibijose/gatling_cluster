#!/bin/bash

. ./variablesGatlings.sh

echo "### `date` Cleaning previous runs from localhost"
rm -rf $GATHER_REPORTS_DIR
mkdir $GATHER_REPORTS_DIR

echo "### `date` Cleanup and setup on hosts"
for HOST in "${HOSTS[@]}"
do
  echo "Cleaning previous run directory  $RUN_HOME on host: $HOST"
  ssh -o 'StrictHostKeyChecking no' -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "rm -rf $RUN_HOME"

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

for HOST in "${HOSTS[@]}"
do
  echo "Tuning gatling on host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/-Xms1G/-Xmx4G -Xmx4G/g' $GATLING_RUNNER"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#lowerBound = 800/lowerBound = 500/g' $GATLING_CONF"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#higherBound = 1200/higherBound = 1000/g' $GATLING_CONF"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#enableGA = true/enableGA = false/g' $GATLING_CONF"
  #ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#maxRetry = 2/maxRetry = 1/g' $GATLING_CONF"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sed -i 's/#requestTimeout = 60000/requestTimeout = 2000/g' $GATLING_CONF"
done