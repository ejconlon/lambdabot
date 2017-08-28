#!/bin/bash

set -eux

COMPONENT="lambdabot"

PROFILE="$1"
REGION="$2"

aws lambda update-function-code \
  --function-name lambdabot \
  --s3-bucket ${PROFILE}-${COMPONENT}-deploy \
  --s3-key lambdabot/release/lambdabot.zip \
  --profile ${PROFILE} \
  --region ${REGION}
