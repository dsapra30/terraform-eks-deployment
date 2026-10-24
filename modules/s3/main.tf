resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "${var.cluster_name}-${var.env}-s3-tfstate"

  tags = {
    Name = "${var.cluster_name}-${var.env}-s3-tfstate"
    Environment = var.env
  }
}