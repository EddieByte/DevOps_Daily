# Jenkins Lab Setup

## Purpose
Automated EC2 provisioning for Jenkins CI/CD lab environment using Terraform.

## Lab Components
- **Jenkins Server** - CI/CD automation
- **Apache Maven** - Build tool for Java projects
- **Git** - Version control
- **Java** - Runtime environment
- **Multi-pipeline jobs** - Advanced Jenkins workflows

## Quick Deploy
```bash
cd Code/
cp "terraform copy.tfvars" terraform.tfvars
# Edit terraform.tfvars with your settings
terraform init
terraform apply
```

## Post-Deployment Setup
1. SSH into instances using output commands
2. Install Jenkins, Maven, Git, Java
3. Configure Jenkins pipelines
4. Set up multi-branch pipeline jobs

## Lab Exercises
- Create freestyle Jenkins jobs
- Build Maven projects
- Set up Git webhooks
- Configure multi-pipeline workflows
- Practice CI/CD best practices

## Cleanup
```bash
terraform destroy
```