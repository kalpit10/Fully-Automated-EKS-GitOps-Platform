######### VPC BLOCK ##########
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.name_prefix}-${var.env}-vpc"
    Project = "Capstone"
    Env     = var.env
    Owner   = "Team4"
  }
}

########## SUBNETS ##########
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  # Only public subnets get public IPs on launch
  map_public_ip_on_launch = each.value.tier == "public" ? true : false

  tags = {
    Name = "${var.name_prefix}-${var.env}-${each.key}"
    Tier = each.value.tier
    Env  = var.env
  }
}


########## INTERNET GATEWAY ##########
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.name_prefix}-${var.env}-igw"
    Project = "Capstone"
    Env     = var.env
    Owner   = "Team4"
  }
}

########## ROUTE TABLES ##########
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  # Attach internet gateway to public route table
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}-${var.env}-public-rt"
    Tier = "public"
    Env  = var.env
  }
}

# Attach the public route table to all "public" subnets
resource "aws_route_table_association" "public" {
  # Loop through all subnets in var.subnets
  # k = the subnet key (example: "public-a")
  # v = the subnet object (with cidr, az, tier fields)
  # The "if v.tier == public" filter means:
  #   -> only pick the entries where tier = "public"
  for_each = { for k, v in var.subnets : k => v if v.tier == "public" }

  # Link the actual subnet resource (aws_subnet.this) 
  # using the key (each.key)
  subnet_id = aws_subnet.this[each.key].id

  # Point those subnets to the public route table
  route_table_id = aws_route_table.public.id
}

########## NAT GATEWAYS ##########
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc" # must be set for VPC NAT

  tags = {
    Name = "${var.name_prefix}-${var.env}-nat-eip"
  }
}

# NAT Gateway in Public Subnet A
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.this["public-a"].id

  tags = {
    Name = "${var.name_prefix}-${var.env}-nat"
  }
}

# Private Route Table (for all private subnets)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  # Route from private subnets to NAT Gateway for internet access
  route {
    # This tells traffic to go to internet via NAT
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}-${var.env}-private-rt"
    Tier = "private"
    Env  = var.env
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  # Filter var.subnets: keep only "private-frontend" and "private-backend"
  for_each = { for k, v in var.subnets : k => v if v.tier != "public" }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.private.id
}


########## SECURITY GROUPS ##########
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-${var.env}-alb-sg"
  description = "Allow HTTP from internet to ALB"
  vpc_id      = aws_vpc.this.id

  # Inbound rules
  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound (to nodes)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-${var.env}-alb-sg"
    Env  = var.env
  }
}

# Node Security Group
resource "aws_security_group" "nodes" {
  name        = "${var.name_prefix}-${var.env}-nodes-sg"
  description = "Allow traffic from ALB and outbound internet"
  vpc_id      = aws_vpc.this.id

  # Inbound: allow ALB → nodes (K8s will map Service to NodePort range)
  # We allowed from port 0 to 65535 to cover all NodePort possibilities
  ingress {
    description     = "Traffic from ALB SG"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow control plane (or self) to communicate with kubelet on port 10250
  ingress {
    description = "Allow EKS control plane to reach kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    # Allow any instances associated with this same security group to talk to each other.
    # This is needed for EKS worker nodes to communicate with the control plane.
    self = true
  }


  # Outbound: allow internet (for Atlas, PayPal, npm, etc.)
  egress {
    description = "Allow outbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-${var.env}-nodes-sg"
    Env  = var.env
  }
}
