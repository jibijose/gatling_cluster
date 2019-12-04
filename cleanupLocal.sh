#!/bin/bash

echo "Removing local gatling installs"
rm -rf gatling-charts-highcharts-bundle-3.3.1-bundle.zip
rm -rf gatling-charts-highcharts-bundle-3.3.1

echo "Removing aws files"
rm -rf aws/.terraform
rm -rf aws/terraform.tfstate
rm -rf aws/terraform.tfstate.backup
rm -rf aws/ssh_keys

echo "Removing azure files"
rm -rf azure/.terraform
rm -rf azure/terraform.tfstate
rm -rf azure/terraform.tfstate.backup
rm -rf azure/ssh_keys

echo "undoing variables.tf changes"
git checkout aws/variables.tf
git checkout azure/variables.tf

echo "Cleanup successful"
