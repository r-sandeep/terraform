provider "aws" {
    region="us-east-1"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t2.micro"
}

variable "department" {
  description = "Department tag"
}


resource "aws_instance" "machine1" {
    ami           = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    tags = {
        department = var.department
    }

    connection {
      # The default username for our AMI
      user = "centos"
      private_key = <<-EOK
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDK8Rq/iiEQSsmCC1JQo9lN+F2aXKcOZzeZobl3JzBQgJpTuyLs
aCF8uU9HWYXRva9lqjC5gw0CY2veg84Fu3rHnKaGLGkKU5EpEmHYPvKZs6RiAQFh
tPQJWkICeWpx+VVZFLECyTIHF978P0oXCzafxcaml6BldDzYsV0BQW+PlwIDAQAB
AoGAZIWUqDd1NSq2MXIGLeda5eIWCzXFkb7SrYiL41dH+TgaOUtCezMBE1R+zmqr
fD6muIbaZ6lgMkSo06kZzYEVyRP4X6iOYL6YuqSOqGHzjvqz0jc3DS9NqzktJRD+
tAjukih0GGmCAMuGVh2GbgeuEpB44F7Y4BgDlBHzHRWxcTECQQDs4ARRvWgkH47g
8/37uY6j7dbK1Xct6WM5tDl9XFe9CFld/wXNcTpDe283hsCMcq65Ex5m10rF5xGR
CTUSlZHrAkEA21O4LrBrBZ6rdB6vHt5AJhp4QsuPYGyfSoVgZb87oNwv17RlATkL
r5lWVUePesYx8sKinIAeUT/mqKdV0keiBQJBAKFIusgpLhKChld26nWOV6gYlkqP
ZFGXet9cblSEHp1wZOESdpH2yZQPJJ/rGYnHwF31vZqKdrgfaB+X5FIeEzcCQBzC
w7pLpB0ei3k0tN4lYuAcRHzt2KVaWSEakGOHSjhz50ov+7bHVkL2pp2UPrpo1w/w
egZvvooFCShAmT5z6kkCQH9JnfCcYpNwYjZZQmzn4XyKTH2Lo7CeDches1af/vXT
iRoQS7CYqeNssONQZ+I7JcBadvvlNRYKTFQ/UBCo5/I=
-----END RSA PRIVATE KEY-----
EOK
      host = self.public_ip
      # The connection will use the local SSH agent for authentication.
    }

    provisioner "remote-exec" {
      inline = [
        "sudo yum update -y",
        "sudo yum install epel-release -y",
        "sudo yum install httpd -y",
        "sudo yum install ansible -y",
        "sudo /usr/sbin/service httpd start",
        "sudo yum install php -y",
        "sudo yum install php-mysql -y",
        "sudo /usr/sbin/chkconfig httpd on",
        "sudo yum install firewalld -y",
  #      "sudo service firewalld start && sudo firewall-cmd --zone=public --add-port=80/tcp --permanent && sudo firewall-cmd --zone=public --add-port=22/tcp --permanent && sudo firewall-cmd --reload",
        "cd /tmp/",
        "sudo curl -O https://raw.githubusercontent.com/vmeoc/Tito/master/asset/Deployment/Ansible/tito-fe-git.yml",
        "sudo ansible-playbook tito-fe-git.yml -e git_url=https://github.com/vmeoc/Tito/ -e tito_release=V1.9",
      ]
    }
}

resource "aws_instance" "machine2" {
    ami           = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    tags = {
        department = var.department
    }
}

output "instance_ip_addr" {
  value = aws_instance.machine1.*.public_ip
}

output "instance_ip_addr_private" {
  value = aws_instance.machine1.*.private_ip
}

output "instance_state" {
  value = aws_instance.machine1.instance_state
}
