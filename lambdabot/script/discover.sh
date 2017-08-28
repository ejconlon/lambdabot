#!/bin/bash

set -eux

PROFILE="$1"
REGION="$2"

API_ID=$(aws apigateway get-rest-apis --profile ${PROFILE} --region ${REGION} | \
         jq -r --arg name "lambdabot" '.items[] | select(.name == $name).id')

echo "https://${API_ID}.execute-api.${REGION}.amazonaws.com/api/"
