#!/bin/bash

read -p "Enter new groupId (e.g., com.example): " groupId

while true; do
  read -p "Enter new artifactId (e.g., my-project): " artifactId
  if [[ "$artifactId" =~ ^[a-zA-Z0-9-]+$ ]]; then
    break
  else
    echo "❌ Error: artifactId must contain only letters, numbers, and hyphens (-). Please try again."
  fi
done

read -p "Enter new base package (e.g., com.example.myproject): " basePackage

basePackagePath=${basePackage//./\/}

for module in cdk lambda lambda-st; do
  echo "Processing $module..."

  # Replace groupId and artifactId in pom.xml
  sed -i "" \
    -e "s|<groupId>matty</groupId>|<groupId>$groupId</groupId>|g" \
    -e "s|<artifactId>matty</artifactId>|<artifactId>$artifactId</artifactId>|g" \
    "$module/pom.xml"
  
  # Replace package in test files# Only replace package/import statements
  find "$module" -type f -name "*.java" \
    -exec sed -i "" \
    -e "s|package matty|package $basePackage|g" \
    -e "s|import matty|import $basePackage|g" \
    -e "s|\"matty-|\"$artifactId-|g" \
    {} +

  # Move Java source files to new package directory
  srcDir="$module/src/main/java"
  oldPackageDir="$srcDir/matty"
  newPackageDir="$srcDir/$basePackagePath"
  if [ -d "$oldPackageDir" ]; then
    mkdir -p "$newPackageDir"
    mv "$oldPackageDir/"* "$newPackageDir/"
    rm -r "$oldPackageDir"
  fi
done

echo "✅ All modules updated."

sleep 5
source scripts/build.sh