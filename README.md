lambdabot
=====

This repo contains an express.js server that doesn't do much besides log
something to a Firehose stream when you hit the right endpoint. The main
takeaways are:

* You can use terraform to describe all your infrastructure (including
  S3 buckets, IAM roles and permissions, Lambda functions, Gateway resources,
  Cloudwatch configuration, and CI user and access keys).
* It's possible (if unreasonably difficult) to use API Gateway in AWS_PROXY
  mode to serve arbitrary HTTP requests with a Lambda function.
* You can run your express app locally or wrap it in a simple shim for Lambda.

To build it
-----

    cd lambdabot
    make install package

To prepare your AWS environment
-----

Pick an AWS $PROFILE and $REGION.  You should have credentials in your
`~/.aws/credentials` file.

You'll need terraform and terragrunt.  For OSX:

    make deps-terraform

Then create core resources:

    ./script/terraform.sh $PROFILE $REGION s3 apply

If you want to fork this and make CI work, first run

    ./script/terraform.sh $PROFILE $REGION ci apply

then put the CI credentials and $PROFILE into CircleCI and wait for a successful
build and deployment.

To upload the Lambda function
-----

If CI is set up, it should publish a zip of the function's code to S3.  You can
do that manually with

    cd lambdabot && ./script/upload.sh $PROFILE release

To create the Lambda and Gateway
-----

There might be some minor hiccups to sort out with resource dependencies,
but in theory this should work from nothing:

    ./script/all-terraform.sh $PROFILE $REGION apply

To update the Lambda
-----

If you make changes, you can publish using the step above, then "update" it with

    cd lambdabot && ./script/publish.sh $PROFILE $REGION
