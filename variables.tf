variable "aws_region" { }
variable "aws_amis" {
  default = {
    "us-east-1" = "ami-000722651477bd39b"
    "us-west-2" = "ami-060412fa7c5879f4c"
  }
}

variable "availability_zones" {
  default = "us-east-1b,us-east-1a"
}

variable "slave_instance_type" {
  description = "Instance type for slave nodes"
  default = "t2.micro"
}

variable "master_instance_type" {
  description = "Instance type for master node"
  default = "t2.micro"
}

variable "slave_ssh_public_key_file" {
  description = "SSH public key filename for slave nodes"
  default = "ssh/slave.pub"
}

variable "master_ssh_public_key_file" {
  description = "SSH public key filename for master node"
  default = "ssh/master.pub"
}

variable "master_ssh_private_key_file" {
  description = "SSH private key filename for master node"
  default = "ssh/master"
}

variable "slave_asg_size" {
  description = "Amount of working nodes in ASG"
  default = "2"
}

variable "jmx_script_file" {
  description = "JMX Script to run on master"
}

variable "jmeter3_url" {
  description = "URL with jmeter archive"
  default = "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-3.3.tgz" 
}
