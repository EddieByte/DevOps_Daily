output "instances" {
  value = {
    for k, v in aws_instance.instances : k => {
      instance_id = v.id
      public_ip   = v.public_ip
      name        = v.tags.Name
      ssh_command = "ssh -i ${var.key_name}.pem ${var.ssh_user}@${v.public_ip}"
    }
  }
}

output "keypair_info" {
  value = var.create_keypair ? {
    message     = "New keypair created and saved as ${var.key_name}.pem"
    key_name    = aws_key_pair.keypair[0].key_name
    private_key = "${var.key_name}.pem"
    } : {
    message = "Using existing keypair: ${var.key_name}"
  }
}

#output "private_ips" {
 # value = {
   # for k, v in aws_instance.instances : k => {
   #   private_ip = v.private_ip
   #   public_ip  = v.public_ip
   # }
 # }
# }
