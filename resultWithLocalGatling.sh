#!/bin/bash

. ./variablesGatlings.sh

echo "### `date` Collecting simulation logs"
for HOST in "${HOSTS[@]}"
do
  echo "Collecting logs from host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "ls -t $GATLING_REPORT_DIR | head -n 1 | xargs -I {} mv ${GATLING_REPORT_DIR}{} ${GATLING_REPORT_DIR}report"
  scp -i $LOCAL_PRIVATE_KEY $USER_NAME@$HOST:${GATLING_REPORT_DIR}report/simulation.log ${GATHER_REPORTS_DIR}simulation-$HOST.log
done

echo "### `date` Aggregating simulations"
rm -rf $LOCAL_GATLING_HOME
unzip -q $GATLING_ZIP
mv $GATHER_REPORTS_DIR $LOCAL_REPORT_DIR
echo "Generating combined reports from $HOSTS"
$LOCAL_GATLING_RUNNER -ro reports

#using macOSX
echo "### `date` Displaying report on browser"
open ${LOCAL_REPORT_DIR}reports/index.html &

#using ubuntu
#google-chrome ${GATLING_REPORT_DIR}reports/index.html