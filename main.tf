resource "aws_vpc" "main_vpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "pub_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pub_subnet"
  }
}

resource "aws_subnet" "prv_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "prv_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "IGW-main"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_subnet.id

  tags = {
    Name = "Primary-NAT-GW"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Primary_Pub_RT"
  }
}

resource "aws_route_table" "prv_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Primary-Prv_RT"
  }
}

resource "aws_route_table_association" "prv_rt_association" {
  subnet_id      = aws_subnet.prv_subnet.id
  route_table_id = aws_route_table.prv_rt.id
}

resource "aws_route_table_association" "pub_rt_association" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.pub_rt.id
}

############resources############


resource "aws_security_group" "Wazuh_sg" {
  name   = "sg"
  vpc_id = aws_vpc.main_vpc.id

  # ✅ Allow inbound SSH (port 22)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Wazuh Agent communication"
    from_port   = 1514
    to_port     = 1514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Wazuh API"
    from_port   = 1515
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Wazuh registration service"
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow syslog UDP"
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Elasticsearch API"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Elasticsearch communication"
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Kibana UI"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SaltStack communication"
    from_port   = 4505
    to_port     = 4506
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "wazuh_ec2_profile" {
  name = "wazuh_ec2_profile"
  role = aws_iam_role.ssm_service_role_for_ec2.name
}

resource "aws_instance" "Wazuh_instance" {
  ami                  = var.ami
  instance_type        = "t3.xlarge"
  subnet_id            = aws_subnet.prv_subnet.id
  iam_instance_profile = aws_iam_instance_profile.wazuh_ec2_profile.name
  user_data            = file("./docker_and_compose_install.sh")

  #user_data_base64 = base64encode(file("./docker_and_compose_install.sh"))

  root_block_device {
    volume_size = 30   # Increase from default 8GB to 30GB
    volume_type = "gp3"  # Optional: Use GP3 for better performance
  }

  tags = {
    Name = "Wazuh_instance"
  }
}

##########

# resource "aws_s3_bucket" "terraform_remotestate_bucket_4356465" {
#   bucket = "terraformremotestatebucket4356fdsf465"

#   tags = {
#     Name = "terraform_remotestate_bucket_4356465"
#   }
# }
