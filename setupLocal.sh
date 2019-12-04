#!/bin/bash

rm -rf gatling-charts-highcharts-bundle-3.3.1-bundle.zip
rm -rf gatling-charts-highcharts-bundle-3.3.1

echo "Downloading gatling 3.3.1.zip"
wget -q -P . https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.3.1/gatling-charts-highcharts-bundle-3.3.1-bundle.zip
echo "Unzipping gatling 3.3.1.zip"
unzip -q gatling-charts-highcharts-bundle-3.3.1-bundle.zip
echo "Setup completed"