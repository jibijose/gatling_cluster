#!/bin/bash

. ./variablesGatlings.sh

echo "Deleting local gatling directory and zip"
rm -rf $LOCAL_GATLING_ZIP
rm -rf $LOCAL_GATLING_HOME

echo "Please set ulimit values if not done"
ulimit -a

echo "Downloading gatling 3.3.1.zip"
wget -q -P . $GATLING_DOWNLOAD_LINK
echo "Unzipping gatling 3.3.1.zip"
unzip -q $GATLING_ZIP
echo "Setup completed"

echo "Tuning gatling on host: $HOST"
sed -i 's/-Xms1G/-Xmx4G -Xmx4G/g' $GATLING_RUNNER
sed -i 's/#lowerBound = 800/lowerBound = 500/g' $GATLING_CONF
sed -i 's/#higherBound = 1200/higherBound = 1000/g' $GATLING_CONF
sed -i 's/#enableGA = true/enableGA = false/g' $GATLING_CONF
#sed -i 's/#maxRetry = 2/maxRetry = 1/g' $GATLING_CONF
sed -i 's/#requestTimeout = 60000/requestTimeout = 2000/g' $GATLING_CONF

echo "### `date` Collecting simulation logs"
for HOST in "${HOSTS[@]}"
do
  echo "Collecting logs from host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "ls -t $GATLING_REPORT_DIR | head -n 1 | xargs -I {} mv ${GATLING_REPORT_DIR}{} ${GATLING_REPORT_DIR}report"
  scp -i $LOCAL_PRIVATE_KEY $USER_NAME@$HOST:${GATLING_REPORT_DIR}report/simulation.log ${GATHER_REPORTS_DIR}simulation-$HOST.log
done

echo "### `date` Aggregating simulations"
mv $GATHER_REPORTS_DIR $LOCAL_REPORT_DIR
echo "Generating combined reports from $HOSTS"
$LOCAL_GATLING_RUNNER -ro reports

#using macOSX
echo "### `date` Displaying report on browser"
open ${LOCAL_REPORT_DIR}reports/index.html &

#using ubuntu
#google-chrome ${GATLING_REPORT_DIR}reports/index.html