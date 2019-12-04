#!/bin/bash

. ./variablesGatlings.sh

echo "### `date` Starting Gatling cluster run for simulation: $SIMULATION_NAME"
for HOST in "${HOSTS[@]}"
do
  echo "Copying $SIMULATION_NAME.scala file to host: $HOST"
  cp -f $SIMULATION_NAME.scala $SIMULATION_NAME_ORIGINAL.scala
  sed "s/_namesuffix/_$HOST/g" $SIMULATION_NAME.scala > $SIMULATION_NAME_EDITED.scala
  mv -f $SIMULATION_NAME_EDITED.scala $SIMULATION_NAME.scala
  scp -i $LOCAL_PRIVATE_KEY -r $SIMULATION_NAME.scala $USER_NAME@$HOST:$GATLING_SIMULATIONS_DIR
  scp -i $LOCAL_PRIVATE_KEY -r *.json $USER_NAME@$HOST:~
  mv -f $SIMULATION_NAME_ORIGINAL.scala $SIMULATION_NAME.scala
  rm -rf $SIMULATION_NAME_EDITED.scala $SIMULATION_NAME_ORIGINAL.scala
  echo "Running simulation on host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sh -c 'nohup $GATLING_RUNNER -nr -s $SIMULATION_NAME > $RUN_HOME/run.log 2>&1 &'"
done