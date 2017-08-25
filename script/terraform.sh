#!/bin/bash

set -eux

PROFILE="$1"
REGION="$2"
COMPONENT="$3"
shift
shift
shift

cd terraform/$COMPONENT
sed -e "s/_PROFILE_/$PROFILE/" -e "s/_REGION_/$REGION/" -e "s/_COMPONENT_/$COMPONENT/" ../provider.tf.tpl > provider.tf
terraform init
terraform $@
rm -f provider.tf
