#!/bin/bash

CLOUD=$1
SIMULATION_NAME=$2
GATLING_HOME_DIR_NAME=gatling-charts-highcharts-bundle-3.3.1

cp -rf $SIMULATION_NAME/AzureCosBlue.scala $GATLING_HOME_DIR_NAME/user-files/simulations/
cp -rf $SIMULATION_NAME/*.json $GATLING_HOME_DIR_NAME/user-files/resources/
rm -rf $GATLING_HOME_DIR_NAME/results/*
JAVA_OPTS="-Xms4096m -Xmx4096m"  $GATLING_HOME_DIR_NAME/bin/gatling.sh -s AzureCosBlue

echo "Local execution completed"