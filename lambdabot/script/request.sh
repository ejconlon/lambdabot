#!/bin/bash

set -eux

PROFILE="$1"
REGION="$2"
ENDPOINT="$3"

API_URL=$(./script/discover.sh ${PROFILE} ${REGION})

CURL="curl -v -w '\n'"

if [[ ${ENDPOINT} == "index" ]]; then
  ${CURL} ${API_URL}
elif [[ ${ENDPOINT} == "hello" ]]; then
  ${CURL} -d '{"name":"script"}' -H 'Content-Type: application/json' ${API_URL}/hello
else
  echo "Unknown endpoint: ${ENDPOINT}"
  exit 1
fi
