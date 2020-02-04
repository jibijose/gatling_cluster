#!/bin/bash

if [ "$#" -ne 2 ]
then
    echo "Usage: $0 local SimulationClass"
    exit 1
fi

CLOUD=$1
SIMULATION_NAME=$2
GATLING_HOME_DIR_NAME=gatling-charts-highcharts-bundle-3.3.1

echo "******************************************************************************************************************"
echo "*********************************************** Ulimit values ****************************************************"
ulimit -a

echo "Local setup "
cp -rf $SIMULATION_NAME/$SIMULATION_NAME*.scala $GATLING_HOME_DIR_NAME/user-files/simulations/
cp -rf $SIMULATION_NAME/$SIMULATION_NAME*.json $GATLING_HOME_DIR_NAME/user-files/resources/
rm -rf $GATLING_HOME_DIR_NAME/results/*

echo "******************************************************************************************************************"
echo "*********************************************** Gatling execution ************************************************"
JAVA_OPTS="-Xms4096m -Xmx4096m"  $GATLING_HOME_DIR_NAME/bin/gatling.sh -s $SIMULATION_NAME

echo "Local execution completed"