#!/bin/bash

. ./variablesGatlings.sh

ULIMITFILES=64000

echo "### `date` Setting ulimits on VMs"
for HOST in "${HOSTS[@]}"
do
  echo "Setting up ulimit on host: $HOST"
  ssh -o 'StrictHostKeyChecking no' -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo ulimit -n $ULIMITFILES >> ~/.profile"

  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sudo chmod 777 /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          soft    memlock         unlimited' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          hard    memlock         unlimited' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          soft    nofile          $ULIMITFILES' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          hard    nofile          $ULIMITFILES' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          soft    nproc           $ULIMITFILES' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          hard    nproc           $ULIMITFILES' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sudo chmod 644 /etc/security/limits.conf"

  #ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sudo chmod 777 /etc/pam.d/common-session"
  #ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sudo chmod 644 /etc/pam.d/common-session"
  
done