data "terraform_remote_state" "s3" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "${var.project}/s3/terraform.tfstate"
  }
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
      "Effect": "Allow",
      "Sid": ""
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
  }
}

output "lambdabot_firehose_arn" {
  value = "${aws_kinesis_firehose_delivery_stream.lambdabot_firehose.arn}"
}
