#!/bin/bash


# Your account User API Key
USER_API_KEY="NRAK-XXX"

# Your account ID
ACCOUNT_ID="123456"

# Your account region US or EU
REGION="US"

# Javascript file
SCRIPT_FILE="script.js" # Location of the file with your javascript source

# Name of your synthitic monitor
MONITOR_NAME="Example Uploaded Script"

# Period
PERIOD="EVERY_HOUR"

# Monitor location(s)
LOCATION="AWS_US_WEST_1"


# -------------------------


# Test that the script file exists (does not validate content)
if [ -e "$SCRIPT_FILE" ]
then
    ENDPOINT="https://api.newrelic.com/graphql"
    
    if [[ "$REGION" == "EU" ]] 
    then
        ENDPOINT="https://api.eu.newrelic.com/graphql"
    fi

    # Escape once for graphQL
    gqlencode=`jq -R -s '.' < $SCRIPT_FILE | sed -e 's/^"//' -e 's/"$//'`
    # Escape once more for JSON payload
    jsonencode=`echo -n $gqlencode | jq -R -s '.'| sed -e 's/^"//' -e 's/"$//'`

    script=$jsonencode

    curl $ENDPOINT \
    -H 'Content-Type: application/json' \
    -H "API-Key: ${USER_API_KEY}" \
    --data-binary "{\"query\":\"mutation {\n  syntheticsCreateScriptBrowserMonitor(accountId: ${ACCOUNT_ID}, monitor: {locations: {public: \\\"${LOCATION}\\\"}, name: \\\"${MONITOR_NAME}\\\", period: ${PERIOD}, script: \\\"$script\\\", status: ENABLED, runtime: {runtimeType: \\\"CHROME_BROWSER\\\", runtimeTypeVersion: \\\"100\\\", scriptLanguage: \\\"JAVASCRIPT\\\"}}) {\n    errors {\n      description\n      type\n    }\n  }\n}\n\", \"variables\":\"\"}"
fi