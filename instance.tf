resource "aws_launch_template" "web_server_lt" {
  name_prefix   = "web-server-"
  instance_type = var.instance_type
  image_id      = var.ami_servera

  # Use the key pair name for SSH access
  key_name = var.key_name  # Name of the key pair in AWS

  # Add the user data script to install httpd and create an HTML file
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Update the package repository
    yum update -y

    # Install Apache HTTPD
    yum install -y httpd

    # Start the HTTPD service
    systemctl start httpd
    systemctl enable httpd

    # Create the index.html file with the custom message
    echo "Welcome to tfd'82" > /var/www/html/index.html

    # Ensure proper permissions
    chown apache:apache /var/www/html/index.html
    chmod 644 /var/www/html/index.html
  EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_server_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
        Name = "web-server-instance"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 1
  vpc_zone_identifier  = [var.subnet_public_1, var.subnet_public_2]  # Public subnets for your ASG

  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-server-instance"
    propagate_at_launch = true
  }
}

