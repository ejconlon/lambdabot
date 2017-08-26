resource "aws_s3_bucket" "deploy_bucket" {
  bucket = "${var.profile}-${var.project}-deploy"
}

resource "aws_s3_bucket" "firehose_bucket" {
  bucket = "${var.profile}-${var.project}-firehose"
}

output "deploy_bucket_name" {
  value = "${aws_s3_bucket.deploy_bucket.id}"
}

output "firehose_bucket_name" {
  value = "${aws_s3_bucket.firehose_bucket.id}"
}
