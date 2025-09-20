# Day 1: Installing WSL2 (Windows Subsystem for Linux Ver.2), Linux Distros and Ubuntu Ver. 22.04 LTS

Today, I set up a local DevOps lab on my windows workstation to explore the functionalities of WSL and Ubuntu. 

## Objective:

The goal is to run lightweight Linux environments in Docker containers for installing packages, testing configurations, and learning core DevOps tools. This provides a cost-effective and efficient method for spinning up and tearing down resources compared to cloud VMs which can result to unexpected costs,but this method works perfect for experimentation and daily learning.

While updating these to my repo, it is also a way for me to experiment and practice my git and github skills. Please feel free to contribute or provide suggestions if any!

Here is a high-level elaboration of the steps i took to achieve this below:

# Steps and Commands:

### 1. Enable WSL2: 

**Action:** Execute the command `wsl --install` in Windows PowerShell as Administrator.

Outcome: This installs the WSL2 kernel and sets the default version to 2. It also downloads and installs the default Ubuntu distribution.

### 2. Launch & Setup Ubuntu: 

**Action:** Launch Ubuntu from the Windows Start Menu.

**Outcome:** On first launch, you will be prompted to create a UNIX username and password. This account is for the Linux environment and is separate from your Windows login. Put in something you can always retain.

As a best practice, ensure to update the package lists on every first run using the command: `sudo apt update && sudo apt upgrade -y`

### 3. Install Docker Desktop: 

**Action:** Download and install Docker Desktop for Windows.

**!!Take Note!!:** After installation, open **Docker Desktop**, go to **Settings** > **Resources** > **WSL Integration** and enable integration for your Ubuntu distribution. Without this, the process is doomed to fail.

**Outcome:** This allows you to run Docker commands directly from your Ubuntu terminal.

### 4. Fix Docker Permissions: 

On first attempt, Running `docker ps` results in a `permission denied` error.

**Solution:** Add your user to the docker group to allow communication with the Docker daemon by executing the command `sudo usermod -aG docker $USER`. If no group has been created yet, execute the command `sudo groupadd <groupname>`for <groupname> insert a group name of your choice.