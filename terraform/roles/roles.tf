resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

resource "aws_iam_role" "iam_for_gateway" {
  name = "iam_for_gateway"

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

resource "aws_iam_role_policy_attachment" "gateway_attachment" {
  role       = "${aws_iam_role.iam_for_gateway.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

output "iam_for_lambda_arn" {
  value = "${aws_iam_role.iam_for_lambda.arn}"
}

output "iam_for_gateway_arn" {
  value = "${aws_iam_role.iam_for_gateway.arn}"
}
