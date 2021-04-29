variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

source "amazon-ebs" "windows_server" {
  ami_description             = "A custom Windows Server AMI"
  ami_name                    = "windows-example"
  associate_public_ip_address = true
  communicator                = "winrm"
  instance_type               = "${var.instance_type}"
  region                      = "${var.aws_region}"
  force_deregister            = true
  force_delete_snapshot       = true
  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "Windows_Server-2019-English-Full-ContainersLatest-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["801119661308"]
  }
  user_data_file = "./bootstrap_win.txt"
  winrm_insecure = true
  winrm_port     = 5986
  winrm_use_ssl  = true
  winrm_username = "Administrator"
}

build {
  sources = ["source.amazon-ebs.windows_server"]

  # Extra configuration
  provisioner "file" {
    destination = "C:\\ProgramData\\someconfig.txt"
    source      = "./myconfig.txt"
  }

  provisioner "powershell" {
    # Reinitialize the server to generate a random password on first boot
    inline = [
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SendWindowsIsReady.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1 -NoShutdown"
    ]
  }
}