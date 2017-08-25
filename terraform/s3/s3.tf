resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.profile}-lambda"
}

output "lambda_bucket_name" {
  value = "${aws_s3_bucket.lambda_bucket.id}"
}
