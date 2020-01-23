#!/bin/bash

if [ "$#" -ne 2 ]
then
    echo "$0 Cloud SimulationClass"
    exit 1
fi

#./setupVMs.sh $1 $2
./setupGatlings.sh $1 $2

./startGatlings.sh $1 $2
./waitGatlings.sh $1 $2
#./stopGatlings.sh $1 $2
./reportWithRemoteGatling.sh $1 $2

echo "Remote execution completed"
