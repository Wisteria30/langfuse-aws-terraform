resource "aws_s3_bucket" "langfuse_blob" {
  bucket        = "${var.identity_name}-langfuse-blob-${var.env}"
  force_destroy = var.force_delete
}

resource "aws_s3_bucket" "langfuse_event" {
  bucket        = "${var.identity_name}-langfuse-event-${var.env}"
  force_destroy = var.force_delete
}

resource "aws_s3_bucket" "langfuse_clickhouse" {
  bucket = "${var.identity_name}-langfuse-clickhouse-${var.env}"
  force_destroy = var.force_delete
}