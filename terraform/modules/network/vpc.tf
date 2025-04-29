resource "aws_default_vpc" "this" {
  tags = {
    Name = "default-vpc-recreated"
  }
}