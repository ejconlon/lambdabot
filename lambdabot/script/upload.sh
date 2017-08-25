#!/bin/bash

set -eux

PROFILE="$1"
TAG="$2"

if test -f ~/.aws/credentials && grep -q "\[${PROFILE}\]" ~/.aws/credentials
then
  AUTH="--profile ${PROFILE}"
else
  AUTH=""
fi

aws s3 cp release/lambdabot.zip s3://${PROFILE}-lambda/lambdabot/${TAG}/lambdabot.zip ${AUTH}
