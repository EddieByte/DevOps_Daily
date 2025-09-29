# Copy this file to terraform.tfvars and customize the values

# AWS Configuration
region        = "us-west-2"
key_name      = "my-keypair"
instance_type = "t2.micro"
ssh_user      = "ubuntu"

# Key Pair Management
create_keypair = true # true = create new keypair, false = use existing

# AMI Configuration (Ubuntu 22.04 by default)
ami_owner       = "099720109477"
ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"

# Security Group Configuration
ssh_cidr_blocks     = ["0.0.0.0/0"] # Restrict to your IP: ["203.0.113.0/24"]
ssh_port            = 22            # Custom SSH port if needed
security_group_name = "Instance-Access"
additional_ports    = [] # Add [80, 443] for web servers

# Instance Configuration
instances = {
  web = {
    name       = "WebServer"
    private_ip = null # Auto-assign or specify: "172.31.32.10"
  }
  api = {
    name       = "APIServer"
    private_ip = "172.31.32.11" # Fixed IP example
  }
  db = {
    name       = "DatabaseServer"
    private_ip = null # Auto-assign
  }
}

# Instructions:
# 1. cp "terraform copy.tfvars" terraform.tfvars
# 2. Edit terraform.tfvars with your values
# 3. terraform init && terraform apply