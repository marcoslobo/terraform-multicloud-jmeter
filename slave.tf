resource "aws_autoscaling_group" "jmeter-slave-ASG" {
  name                 = "jmeter-slave-ASG"
  max_size             = var.slave_asg_size
  min_size             = var.slave_asg_size
  force_delete         = true
  launch_configuration = aws_launch_configuration.jmeter-slave-lc.name
  availability_zones   = ["us-east-1a"]

  tag {
    key                 = "Name"
    value               = "jmeter-slave"
    propagate_at_launch = "true"
  }
}



resource "aws_launch_configuration" "jmeter-slave-lc" {
  name          = "jmeter-slave-lc"
  image_id      = lookup(var.aws_amis, var.aws_region)
  instance_type = var.slave_instance_type
  user_data     = <<EOF
#!/bin/sh
sudo apt-get update
sudo ufw disable
sudo apt-get install software-properties-common
sudo apt-add-repository universe
sudo apt install openjdk-8-jdk -y
curl ${var.jmeter3_url} > jMeter.tgz
tar zxvf jMeter.tgz
my_ip=$(ec2metadata --local-ipv4)
sudo apache-jmeter-3.3/bin/jmeter-server -Dserver.rmi.localport=50000 -Dserver_port=1099 -Djava.rmi.server.hostname=$my_ip -Jserver.rmi.ssl.disable=true 
EOF

  security_groups = ["${aws_security_group.jmeter-sg.id}"]
  key_name        = aws_key_pair.jmeter-slave-keypair.key_name
}

resource "aws_key_pair" "jmeter-slave-keypair" {
  key_name   = "jmeter-slave-keypair"
  public_key = file("${var.slave_ssh_public_key_file}")
}
