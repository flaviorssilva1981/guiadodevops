### Create EC2 - JENKINS

resource "aws_instance" "jenkins" {
  ami           = var.ami-jenkins
  instance_type = var.instance-type
  key_name = aws_key_pair.jenkins.key_name
  subnet_id = var.sub-public-01
  vpc_security_group_ids = [var.sg-public-01]

  tags = {
    Name = var.instance-name
  }

}

## Elastic Public IP Association
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = var.eip_allocation_id
}

## Create Key Pair
resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins"               # The name of your key pair
  public_key = file("/mnt/c/guga/projetos/eks/eks02/jenkins.pub")   # Path to your public key file
}