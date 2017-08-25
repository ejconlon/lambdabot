data "terraform_remote_state" "s3" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "s3/terraform.tfstate"
  }
}

data "terraform_remote_state" "roles" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "roles/terraform.tfstate"
  }
}

resource "aws_lambda_function" "lambdabot_lambda" {
  s3_bucket        = "${data.terraform_remote_state.s3.lambda_bucket_name}"
  s3_key           = "lambdabot/release/lambdabot.zip"
  function_name    = "lambdabot"
  role             = "${data.terraform_remote_state.roles.iam_for_lambda_arn}"
  handler          = "lambda.handler"
  runtime          = "nodejs6.10"
}
