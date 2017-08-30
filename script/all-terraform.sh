#!/bin/bash

set -eux

PROFILE="$1"
REGION="$2"
shift
shift

./script/terraform.sh ${PROFILE} ${REGION} gateway_logging $@
./script/terraform.sh ${PROFILE} ${REGION} lambdabot_firehose $@
./script/terraform.sh ${PROFILE} ${REGION} lambdabot_lambda $@
./script/terraform.sh ${PROFILE} ${REGION} lambdabot_gateway $@
