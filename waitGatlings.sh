#!/bin/bash

. ./variablesGatlings.sh

echo "### `date` Waiting for gatling(s) to complete"
continuecheck=true
while [ $continuecheck = true ]
do
  hostinprogress=false
  pendinghosts=""
  for HOST in "${HOSTS[@]}"
  do
    numofps=`ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "ps -aef | grep java | grep -v grep | wc -l"`
    if [ $numofps != 0 ]
    then
      hostinprogress=true
      pendinghosts=$pendinghosts$HOST" "
    fi
  done
  if [ $hostinprogress = true ]
  then
    echo "`date` Hosts in progress $pendinghosts"
  else
    echo "All host runs completed"
    continuecheck=false
  fi
done