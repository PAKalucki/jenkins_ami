packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.1.1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "jenkins_ami"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] ### cannonical
    most_recent = true
  }
  ssh_username = "ubuntu"
}

build {
  name = "ebs_backed_ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "/usr/bin/cloud-init status --wait", # workaround for race condition
      "sudo apt-get update -y && sudo apt-get upgrade -y",
      "sudo apt-get install python3-pip git curl wget apt-transport-https ca-certificates gnupg build-essential python3-dev python3-wheel -y"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./playbook.yaml"
  }
}