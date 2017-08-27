resource "aws_s3_bucket" "deploy_bucket" {
  bucket = "${var.profile}-${var.project}-deploy"
}

output "deploy_bucket_name" {
  value = "${aws_s3_bucket.deploy_bucket.id}"
}

output "deploy_bucket_arn" {
  value = "${aws_s3_bucket.deploy_bucket.arn}"
}

resource "aws_s3_bucket" "firehose_bucket" {
  bucket = "${var.profile}-${var.project}-firehose"
}

output "firehose_bucket_name" {
  value = "${aws_s3_bucket.firehose_bucket.id}"
}

output "firehose_bucket_arn" {
  value = "${aws_s3_bucket.firehose_bucket.arn}"
}
