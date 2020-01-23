#!/bin/bash

#./setupVMs.sh $1 $2
./setupGatlings.sh $1 $2

./startGatlings.sh $1 $2
./waitGatlings.sh $1 $2
#./stopGatlings.sh $1 $2
./reportWithLocalGatling.sh $1 $2

echo "Remote execution completed"
