#!/bin/bash

. ./variablesGatlings.sh

echo "### `date` Setting ulimits on VMs"
for HOST in "${HOSTS[@]}"
do
  echo "Setting up ulimit on host: $HOST"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo ulimit -n 64000 >> ~/.profile"

  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sudo chmod 777 /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          soft    memlock         unlimited' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          hard    memlock         unlimited' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          soft    nofile          64000' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          hard    nofile          64000' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          soft    nproc           64000' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "echo 'ubuntu          hard    nproc           64000' >> /etc/security/limits.conf"
  ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sudo chmod 644 /etc/security/limits.conf"

  #ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sudo chmod 777 /etc/pam.d/common-session"
  #ssh -i $LOCAL_PRIVATE_KEY -n -f $USER_NAME@$HOST "sudo chmod 644 /etc/pam.d/common-session"
  
done
