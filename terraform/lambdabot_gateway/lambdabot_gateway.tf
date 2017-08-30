variable "lambdabot_stage" {
  type = "string"
  description = "CONSTANT for API stage"
  default = "api"
}

variable "lambdabot_auth" {
  type = "string"
  description = "CONSTANT for lambda auth"
  default = "NONE"
}

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
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambdabot_gateway_policy" {
  name        = "lambdabot_gateway_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${data.terraform_remote_state.lambdabot_lambda.lambdabot_lambda_arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambdabot_gateway_attachment" {
  role       = "${aws_iam_role.lambdabot_gateway_role.name}"
  policy_arn = "${aws_iam_policy.lambdabot_gateway_policy.arn}"
}

resource "aws_api_gateway_rest_api" "lambdabot_api" {
  name = "lambdabot"
}

resource "aws_api_gateway_method" "lambdabot_method_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.lambdabot_api.root_resource_id}"
  http_method   = "ANY"
  authorization = "${var.lambdabot_auth}"
}

resource "aws_api_gateway_resource" "lambdabot_resource_proxy" {
  depends_on = ["aws_api_gateway_method.lambdabot_method_root"]
  rest_api_id = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.lambdabot_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "lambdabot_method_proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  resource_id   = "${aws_api_gateway_resource.lambdabot_resource_proxy.id}"
  http_method   = "ANY"
  authorization = "${var.lambdabot_auth}"
}

resource "aws_api_gateway_integration" "lambdabot_integration_root" {
  rest_api_id             = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  resource_id             = "${aws_api_gateway_rest_api.lambdabot_api.root_resource_id}"
  http_method             = "${aws_api_gateway_method.lambdabot_method_root.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.terraform_remote_state.lambdabot_lambda.lambdabot_lambda_arn}/invocations"
  credentials             = "${aws_iam_role.lambdabot_gateway_role.arn}"
}

resource "aws_api_gateway_integration" "lambdabot_integration_proxy" {
  rest_api_id             = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  resource_id             = "${aws_api_gateway_resource.lambdabot_resource_proxy.id}"
  http_method             = "${aws_api_gateway_method.lambdabot_method_proxy.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.terraform_remote_state.lambdabot_lambda.lambdabot_lambda_arn}/invocations"
  credentials             = "${aws_iam_role.lambdabot_gateway_role.arn}"
}

resource "aws_api_gateway_deployment" "lambdabot_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambdabot_integration_root",
    "aws_api_gateway_integration.lambdabot_integration_proxy"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  stage_name  = "${var.lambdabot_stage}"
}

resource "aws_api_gateway_method_settings" "lambdabot_method_settings" {
  depends_on = ["aws_api_gateway_deployment.lambdabot_deployment"]
  rest_api_id = "${aws_api_gateway_rest_api.lambdabot_api.id}"
  stage_name  = "${var.lambdabot_stage}"
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
}

# NOTE: Sadly, only has an effect when you are using API keys?
#
# resource "aws_api_gateway_usage_plan" "lambdabot_usage" {
#   name         = "lambdabot_usage"
#
#   api_stages {
#     api_id = "${aws_api_gateway_rest_api.lambdabot_api.id}"
#     stage  = "${var.lambdabot_stage}"
#   }
#
#   quota_settings {
#     limit  = 1000
#     period = "MONTH"
#   }
# }

output "lambdabot_id" {
  value = "${aws_api_gateway_rest_api.lambdabot_api.id}"
}

output "lambdabot_url" {
  value = "https://${aws_api_gateway_rest_api.lambdabot_api.id}.execute-api.${var.region}.amazonaws.com/${var.lambdabot_stage}"
}
