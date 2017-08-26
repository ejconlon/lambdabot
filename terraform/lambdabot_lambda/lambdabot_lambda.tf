data "terraform_remote_state" "s3" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "${var.project}/s3/terraform.tfstate"
  }
}

resource "aws_iam_role" "lambdabot_role" {
  name = "lambdabot_role"

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

resource "aws_lambda_function" "lambdabot_lambda" {
  s3_bucket        = "${data.terraform_remote_state.s3.deploy_bucket_name}"
  s3_key           = "lambdabot/release/lambdabot.zip"
  function_name    = "lambdabot"
  role             = "${aws_iam_role.lambdabot_role.arn}"
  handler          = "lambda.handler"
  runtime          = "nodejs6.10"
}

output "lambdabot_lambda_arn" {
  value = "${aws_lambda_function.lambdabot_lambda.arn}"
}
