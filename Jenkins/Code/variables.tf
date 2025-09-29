variable "key_name" {
  description = "Key pair name for SSH access"
}

variable "instance_type" {
  description = "Instance type"
}

variable "ssh_user" {
  description = "SSH username for connecting to instances"
}

variable "ami_id" {
  description = "AMI ID for instances (optional - will use data source if not provided)"
  default     = null
}

variable "ami_owner" {
  description = "AMI owner ID"
}

variable "ami_name_filter" {
  description = "AMI name filter pattern"
}

variable "region" {
  description = "AWS region"
}

variable "instances" {
  description = "Map of instances to create with their names and optional private IP"
  type = map(object({
    name       = string
    private_ip = optional(string)
  }))
}

variable "create_keypair" {
  description = "Whether to create a new key pair (true) or use existing (false)"
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
}

variable "ssh_port" {
  description = "SSH port number"
  default     = 22
}

variable "security_group_name" {
  description = "Name for the security group"
  default     = "SSH Access"
}

variable "additional_ports" {
  description = "Additional ports to open (e.g., [80, 443] for web traffic)"
  type        = list(number)
  default     = []
}