data "terraform_remote_state" "s3" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "${var.project}/s3/terraform.tfstate"
  }
}

data "terraform_remote_state" "lambdabot_firehose" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "${var.project}/lambdabot_firehose/terraform.tfstate"
  }
}

resource "aws_iam_role" "lambdabot_lambda_role" {
  name = "lambdabot_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambdabot_lambda_policy" {
  name        = "lambdabot_lambda_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ],
      "Resource": [
        "${data.terraform_remote_state.lambdabot_firehose.lambdabot_firehose_arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambdabot_lambda_attachment" {
  role       = "${aws_iam_role.lambdabot_lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambdabot_lambda_policy.arn}"
}

resource "aws_lambda_function" "lambdabot_lambda" {
  s3_bucket        = "${data.terraform_remote_state.s3.deploy_bucket_name}"
  s3_key           = "lambdabot/release/lambdabot.zip"
  function_name    = "lambdabot"
  role             = "${aws_iam_role.lambdabot_lambda_role.arn}"
  handler          = "lambda.handler"
  runtime          = "nodejs6.10"
}

output "lambdabot_lambda_arn" {
  value = "${aws_lambda_function.lambdabot_lambda.arn}"
}
