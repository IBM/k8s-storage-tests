#!/usr/bin/env bash
set -x

curl -LJO ${WS_JAR_URL}
WS_JAR_PATH="wss-unified-agent.jar"

if [ -e "$WS_JAR_PATH" ]; then
    echo "Whitesource jar file for scanning repos downloaded successfully"
else
    echo "ERROR: Whitesource jar file for scanning repos failed to download"
    exit 0
fi

echo "INFO: Executing Mend scan against repository for ${WS_PROJECTNAME} classified under ${WS_PRODUCTNAME}"
java -jar wss-unified-agent.jar -d . 

