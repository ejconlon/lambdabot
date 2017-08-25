#!/bin/bash

set -eux

rm -rf release
mkdir -p release/lambdabot

cd release/lambdabot

cp ../../lambda.js .
cp ../../lambdabot.js .
cp -r ../../node_modules .

zip -r ../lambdabot.zip .

cd ..

rm -rf lambdabot

unzip -l lambdabot.zip
