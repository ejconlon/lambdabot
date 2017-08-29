data "aws_caller_identity" "current" {}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "${var.project}/s3/terraform.tfstate"
  }
}

resource "aws_cloudwatch_log_group" "lambdabot_firehose_log_group" {
  name = "lambdabot_firehose_log_group"
}

resource "aws_cloudwatch_log_stream" "lambdabot_firehose_log_stream" {
  name           = "lambdabot_firehose_log_stream"
  log_group_name = "${aws_cloudwatch_log_group.lambdabot_firehose_log_group.name}"
}

resource "aws_iam_role" "lambdabot_firehose_role" {
  name = "lambdabot_firehose_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambdabot_firehose_policy" {
  name        = "lambdabot_firehose_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "${data.terraform_remote_state.s3.firehose_bucket_arn}",
        "${data.terraform_remote_state.s3.firehose_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.lambdabot_firehose_log_group.name}:log-stream:${aws_cloudwatch_log_stream.lambdabot_firehose_log_stream.name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambdabot_firehose_attachment" {
  role       = "${aws_iam_role.lambdabot_firehose_role.name}"
  policy_arn = "${aws_iam_policy.lambdabot_firehose_policy.arn}"
}

resource "aws_kinesis_firehose_delivery_stream" "lambdabot_firehose" {
  name        = "lambdabot_firehose"
  destination = "s3"

  s3_configuration {
    role_arn   = "${aws_iam_role.lambdabot_firehose_role.arn}"
    bucket_arn = "${data.terraform_remote_state.s3.firehose_bucket_arn}"
    prefix     = "v1/"
    buffer_interval = 60

    cloudwatch_logging_options {
      enabled = true
      log_group_name = "${aws_cloudwatch_log_group.lambdabot_firehose_log_group.name}"
      log_stream_name = "${aws_cloudwatch_log_stream.lambdabot_firehose_log_stream.name}"
    }
  }
}

output "lambdabot_firehose_arn" {
  value = "${aws_kinesis_firehose_delivery_stream.lambdabot_firehose.arn}"
}
