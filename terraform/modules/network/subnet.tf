# デフォルトサブネット（パブリック）
resource "aws_default_subnet" "az_a" {
  availability_zone = "${var.region}a"
}

resource "aws_default_subnet" "az_c" {
  availability_zone = "${var.region}c"
}

# プライベートサブネット
resource "aws_subnet" "private_a" {
  vpc_id            = aws_default_vpc.this.id
  cidr_block        = "172.31.48.0/20"
  availability_zone = "${var.region}a"
  
  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_default_vpc.this.id
  cidr_block        = "172.31.64.0/20"
  availability_zone = "${var.region}c"
  
  tags = {
    Name = "private-subnet-c"
  }
}
