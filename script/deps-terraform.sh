#!/bin/bash

set -eux

TF_VER="0.10.2"
TG_VER="0.13.0"

rm -rf .bin
mkdir -p .bin

pushd .bin
  wget https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_darwin_amd64.zip
  unzip terraform_${TF_VER}_darwin_amd64.zip
  rm terraform_${TF_VER}_darwin_amd64.zip
  chmod +x terraform
	wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VER}/terragrunt_darwin_amd64
  mv terragrunt_darwin_amd64 terragrunt
  chmod +x terragrunt
popd
