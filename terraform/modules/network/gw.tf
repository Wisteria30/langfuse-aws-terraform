resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway を AZ a のパブリックサブネットに配置
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_default_subnet.az_a.id
  tags          = { Name = "single-nat-gw" }
}

# プライベート用ルートテーブル
resource "aws_route_table" "private" {
  vpc_id = aws_default_vpc.this.id
  route  {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

# 各プライベートサブネットにアソシエイト
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}