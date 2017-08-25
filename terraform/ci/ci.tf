data "terraform_remote_state" "s3" {
  backend = "s3"
  config {
    profile = "${var.profile}"
    region  = "${var.region}"
    bucket  = "${var.state_bucket}"
    key     = "s3/terraform.tfstate"
  }
}

resource "aws_iam_user" "ci_user" {
  name = "ci"
}

resource "aws_iam_access_key" "ci_access_key" {
  user    = "${aws_iam_user.ci_user.name}"
}

resource "aws_iam_user_policy" "ci_access_policy" {
  name = "ci_access_policy"
  user = "${aws_iam_user.ci_user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${data.terraform_remote_state.s3.lambda_bucket_name}/*"
      ]
    }
  ]
}
EOF
}

output "ci_key_id" {
  value = "${aws_iam_access_key.ci_access_key.id}"
}

output "ci_secret_key" {
  value = "${aws_iam_access_key.ci_access_key.secret}"
}
