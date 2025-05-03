resource "aws_subnet" "emr_subnet" {
  vpc_id            = aws_vpc.emr_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = local.common_tags
}
