data "terraform_remote_state" "lambdabot_lambda" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "${var.project}/lambdabot_lambda/terraform.tfstate"
  }
}

resource "aws_iam_role" "lambdabot_gateway_role" {
  name = "lambdabot_gateway_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambdabot_gateway_attachment" {
  role       = "${aws_iam_role.lambdabot_gateway_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
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
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.terraform_remote_state.lambdabot_lambda.lambdabot_lambda_arn}/invocations"
  credentials             = "${aws_iam_role.lambdabot_gateway_role.arn}"
}
