#!/bin/bash
set -e
echo "building functions"
cd lambda && mvn clean package
echo "building lambda-st"
cd ../lambda-st && mvn clean package
echo "building CDK"
cd ../cdk && mvn clean package
