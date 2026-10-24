resource "aws_dynamodb_table" "terraform_state_dynamo_table" {
  name           = "${var.cluster_name}-${var.env}-dynamotb"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.cluster_name}-${var.env}-dynamotb"
    Environment = var.env
  }
}