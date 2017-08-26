data "aws_caller_identity" "current" {}

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

resource "aws_api_gateway_rest_api" "lambdabot_api" {
  name = "lambdabot"
}

resource "aws_api_gateway_method" "lambdabot_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.lambdabot_api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambdabot_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  resource_id             = "${aws_api_gateway_rest_api.lambdabot_api.root_resource_id}"
  http_method             = "${aws_api_gateway_method.lambdabot_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambdabot_lambda.arn}/invocations"
  credentials             = "${data.terraform_remote_state.roles.iam_for_gateway_arn}"
}
