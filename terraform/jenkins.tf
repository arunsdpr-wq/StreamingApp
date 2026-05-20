# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  count                = var.enable_jenkins ? 1 : 0
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.jenkins_instance_type
  subnet_id            = aws_subnet.public[0].id
  iam_instance_profile = aws_iam_instance_profile.jenkins[0].name

  vpc_security_group_ids = [aws_security_group.jenkins[0].id]

  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.jenkins_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = base64encode(file("${path.module}/jenkins_bootstrap.sh"))

  tags = {
    Name = "${var.project_name}-jenkins"
  }

  depends_on = [aws_internet_gateway.main]
}

# Elastic IP for Jenkins (optional, for stable public IP)
resource "aws_eip" "jenkins" {
  count    = var.enable_jenkins ? 1 : 0
  instance = aws_instance.jenkins[0].id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-jenkins-eip"
  }

  depends_on = [aws_internet_gateway.main]
}
