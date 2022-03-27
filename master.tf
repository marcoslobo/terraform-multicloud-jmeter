resource "aws_instance" "jmeter-master-instance" {

  ami           = lookup(var.aws_amis, var.aws_region)
  instance_type = var.master_instance_type

  security_groups      = ["${aws_security_group.jmeter-sg.name}"]
  key_name             = aws_key_pair.jmeter-master-keypair.key_name
  iam_instance_profile = aws_iam_instance_profile.jmeter_master_iam_profile.name

  provisioner "remote-exec" {
    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.master_ssh_private_key_file}")
    }

    inline = [      
      "sudo apt-get update -y",
      "sudo ufw disable",
      "sudo mkdir /jmeter-master",
      "sudo chown -R ubuntu /jmeter-master",
      "sudo mkdir ~/home/ubuntu/.aws",
      "sudo apt-get install software-properties-common",            
      "sudo apt-get install openjdk-8-jdk -y",      
      "sudo apt-get install python3-pip -y",
      "pip3 install boto3",
    ]
  }

  provisioner "file" {
    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.master_ssh_private_key_file}")
    }
    source      = "${path.module}/master_start.py"
    destination = "/jmeter-master/master_start.py"
  }

  provisioner "file" {
    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.master_ssh_private_key_file}")
    }
    source      = var.jmx_script_file
    destination = "/jmeter-master/script.jmx"
  }


#   provisioner "file" {
#  connection {
#       host        = coalesce(self.public_ip, self.private_ip)
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file("${var.master_ssh_private_key_file}")
#     }
#     content     = <<EOF
#   [default]
#   region=${var.aws_region}
#   EOF
#     destination = "~/home/ubuntu/.aws/config"
#   }

  provisioner "remote-exec" {
    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.master_ssh_private_key_file}")
    }
    inline = [
      "cd /jmeter-master/",
      "curl ${var.jmeter3_url} > jMeter.tgz",
      "tar zxvf jMeter.tgz"
    ]
  }
}

resource "aws_key_pair" "jmeter-master-keypair" {
  key_name   = "jmeter-master-keypair"
  public_key = file("${var.master_ssh_public_key_file}")
}

resource "aws_iam_instance_profile" "jmeter_master_iam_profile" {
  name = "jmeter_master_iam_profile"
  role = aws_iam_role.jmeter_master_iam_role.name
}

resource "aws_iam_role" "jmeter_master_iam_role" {
  name               = "jmeter_master_iam_role"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jmeter_master_iam_role_attachment" {
  role       = aws_iam_role.jmeter_master_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

output "master_public_ip" {
  value = aws_instance.jmeter-master-instance.public_ip
}
