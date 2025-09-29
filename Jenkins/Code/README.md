# Instance Config:

This is a flexible and reusable Terraform configuration for creating AWS EC2 instances with automatic key pair generation and SSH access. 

I mainly created this because i did not want to be logging in and out of the console all the time to provision temporary resources. This will help anyone looking to quickly test out a few things or work temporarily with instances.

## Features

- **Dynamic instance creation** - Create any number of instances
- **Automatic key pair generation** - No console access needed
- **Flexible AMI selection** - Support for Ubuntu, Amazon Linux, CentOS
- **Configurable regions** - Deploy to any AWS region
- **SSH-ready outputs** - Get connection commands automatically

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- AWS account with EC2 permissions

## Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd Jenkins\ IaC
```

### 2. Configure Variables
```bash
cp terraform.tfvars.template terraform.tfvars
```

Edit `terraform.tfvars` with your settings:
```hcl
# AWS Configuration
region             = "us-west-2"
key_name           = "my-keypair"
instance_type      = "t2.micro"
ssh_user           = "ubuntu"

# Key Pair Management
create_keypair     = true    # Set to true for new key pair

# AMI Configuration
ami_owner          = "099720109477"
ami_name_filter    = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"

# Instance Configuration
instances = {
  dev = {
    name = "Development"
  }
  qa = {
    name = "QualityAssurance"
  }
  prod = {
    name = "Production"
  }
}
```

### 3. Deploy
```bash
terraform init
terraform plan
terraform apply
```

### 4. Connect to Instances
After deployment, use the SSH commands from the output:
```bash
# Example output
ssh -i my-keypair.pem ubuntu@<public-ip>
```

## Configuration Options

### Instance Configuration
Add or remove instances by modifying the `instances` map:

**Single instance:**
```hcl
instances = {
  web = { name = "WebServer" }
}
```

**Multiple instances:**
```hcl
instances = {
  web1    = { name = "WebServer1" }
  web2    = { name = "WebServer2" }
  db      = { name = "Database" }
  cache   = { name = "RedisCache" }
  monitor = { name = "Monitoring" }
}
```

### Key Pair Options

**Create new key pair (recommended for new users):**
```hcl
create_keypair = true
key_name       = "my-new-keypair"
```

**Use existing key pair:**
```hcl
create_keypair = false
key_name       = "existing-keypair"
```

### AMI Options

**Ubuntu 22.04 (default):**
```hcl
ami_owner       = "099720109477"
ami_name_filter = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
ssh_user        = "ubuntu"
```

**Amazon Linux 2:**
```hcl
ami_owner       = "137112412989"
ami_name_filter = "amzn2-ami-hvm-*-x86_64-gp2"
ssh_user        = "ec2-user"
```

**CentOS 7:**
```hcl
ami_owner       = "125523088429"
ami_name_filter = "CentOS 7*"
ssh_user        = "centos"
```

## Outputs

The configuration provides:
- **Instance IDs** - For AWS console reference
- **Public IPs** - For network configuration
- **SSH Commands** - Ready-to-use connection strings
- **Key Pair Info** - Details about created/used key pairs

## File Structure

```
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.template  # Configuration template
├── terraform.tfvars.example   # Example configuration
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## Security Notes

- Private key files (`.pem`) are automatically excluded from git
- `terraform.tfvars` is excluded from git to protect sensitive values
- Key files are created with secure permissions (0400)
- Use the template files to share configurations safely

## CRITICAL PRODUCTION SECURITY WARNING

**This configuration is designed for DEVELOPMENT and TESTING only. DO NOT use in production without proper security hardening.**

### Default Security Risks:
- SSH access from anywhere (`0.0.0.0/0`) - **DANGEROUS in production**
- Public IP addresses on all instances
- Broad network access permissions

### Production Security Best Practices:

**SSH Access - Restrict to known networks:**
```hcl
ssh_cidr_blocks = ["203.0.113.0/24"]  # Office/VPN IP range only
```

**Web Servers - Only necessary ports:**
```hcl
additional_ports = [80, 443]  # HTTP/HTTPS only
```

**Database/Internal Servers - No public access:**
```hcl
ssh_cidr_blocks = ["10.0.1.0/24"]     # Admin subnet only
additional_ports = [3306]              # Database port, internal only
```

### Recommended Production Architecture:
- **Load Balancer** - Public-facing with SSL termination
- **Private Subnets** - Instances without public IPs
- **Bastion Host** - Single, hardened SSH entry point
- **VPN Access** - SSH through secure tunnel only
- **Separate Security Groups** - Per application tier
- **Network ACLs** - Additional network-level filtering

### For Production Use:
1. Remove public IP assignments
2. Use private subnets
3. Implement proper network segmentation
4. Use AWS Systems Manager Session Manager instead of SSH
5. Enable VPC Flow Logs
6. Implement proper monitoring and alerting

## Troubleshooting

**Key pair already exists error:**
```bash
# Delete existing key pair in AWS console or use different name
key_name = "my-keypair-v2"
```

**Permission denied (publickey) error:**
```bash
# Ensure correct key file permissions
chmod 400 my-keypair.pem
```

**AMI not found error:**
```bash
# Verify AMI availability in your region
aws ec2 describe-images --owners 099720109477 --region us-west-2
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Disclaimer

**This configuration is provided for educational and development purposes only. Users are responsible for implementing proper security measures for production environments. The authors are not responsible for any security breaches or damages resulting from the use of this configuration.**

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## Future Plans

- Add autoscaling support - if needed
- Add CIDR config blocks to .tfvars - as needed