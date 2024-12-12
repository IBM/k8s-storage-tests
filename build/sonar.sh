#!/usr/bin/env bash
set -x

echo "Downloading sonar-scanner version ${SONAR_SCANNER_VERSION}"
wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip
unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip -d . 

# Scanning repo based on change being a pull request or branch scan
./sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner -Dsonar.projectKey=${IMAGE_NAME} -Dsonar.sources=. -Dsonar.exclusions=**/*test* -Dsonar.host.url=http://cp4d-sonarqube.svl.ibm.com:9000/sonar -Dsonar.branch.name=${BRANCH} -Dsonar.login=${SONAR_KEY} 
