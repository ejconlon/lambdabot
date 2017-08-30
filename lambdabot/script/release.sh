#!/bin/bash

set -eux

PROFILE="$1"
REGION="$2"

./script/package.sh

./script/upload.sh ${PROFILE} release

./script/publish.sh ${PROFILE} ${REGION}
