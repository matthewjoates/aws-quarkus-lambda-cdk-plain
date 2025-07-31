#!/bin/bash

read -p "Enter new groupId (e.g., com.example): " groupId
read -p "Enter new artifactId (e.g., my-project): " artifactId
read -p "Enter new base package (e.g., com.example.myproject): " basePackage

basePackagePath=${basePackage//./\/}

for module in cdk lambda lambda-st; do
  echo "Processing $module..."

  # Replace groupId and artifactId in pom.xml
  sed -i "" \
    -e "s|<groupId>matty</groupId>|<groupId>$groupId</groupId>|g" \
    -e "s|<artifactId>matty</artifactId>|<artifactId>$artifactId</artifactId>|g" \
    "$module/pom.xml"

  # Replace package in Java, XML, and properties files
  find "$module" -type f \( -name "*.java" -o -name "*.xml" -o -name "*.properties" \) \
    -exec sed -i "" \
    -e "s|matty|$basePackage|g" \
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

source build.sh