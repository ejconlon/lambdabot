lambdabot
=====

You will need to setup core resources in the AWS account first:

    ./script/terraform.sh $PROFILE $REGION s3 apply
    ./script/terraform.sh $PROFILE $REGION ci apply

Put the CI credentials and $PROFILE into CircleCI and wait for a successful
build and deployment. Then create the Lambda and Gateway:

    ./script/all-terraform.sh $PROFILE $REGION apply
