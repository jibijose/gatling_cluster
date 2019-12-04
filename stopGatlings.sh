#!/bin/bash

. ./variablesGatlings.sh


echo "### `date` Killing Gatling java's"
for HOST in "${HOSTS[@]}"
do
  echo "Killing java on host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sh -c 'killall java'"
done

echo "### `date` killed on all hosts"