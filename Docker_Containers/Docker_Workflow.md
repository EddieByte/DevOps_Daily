# Docker Workflow Guide

## Image Management

### Basic Image Operations
```bash
# Download image
docker pull <image_name>

# List images
docker images

# Remove image
docker rmi <image_name>

# Search for image
docker search <image_name>

# Build from Dockerfile
docker build -t <new_image_name> .

# Create image from container
docker commit <container_name> <new_image_name>

# Tag image
docker tag <image_name> <registry>:<port>/<image_name>

# Push to registry
docker push <image_name>

# Clean unused images
docker system prune -a
```

## Container Management

### Container Lifecycle
```bash
# Create and run container
docker run <image_name>

# List running containers
docker container ls

# List all containers
docker ps -a

# Start stopped container
docker start <container_name>

# Stop running container
docker stop <container_name>

# Restart container
docker restart <container_name>

# Remove stopped container
docker rm <container_name>

# Force remove running container
docker rm -f <container_name>
```

### Bulk Container Operations
```bash
# Stop all containers
docker stop $(docker ps -aq)

# Restart all containers
docker restart $(docker ps -aq)

# Remove all stopped containers
docker rm $(docker ps -aq)

# Remove all containers (force)
docker rm -f $(docker ps -aq)
```

### Container Inspection & Interaction
```bash
# View logs
docker logs <container_name>

# Check ports
docker port <container_name>

# Inspect container details
docker inspect <container_name>

# Attach to running container
docker attach <container_name>

# Execute command in container
docker exec -it <container_name> <command>

# Open bash shell
docker exec -it <container_name> bash
```

## Run Command Options

| Option | Purpose | Example |
|--------|---------|---------|
| `-it` | Interactive terminal | `docker run -it ubuntu` |
| `--name` | Container name | `docker run --name myapp nginx` |
| `-d` | Detached mode | `docker run -d nginx` |
| `-p` | Port mapping | `docker run -p 8080:80 nginx` |
| `-P` | Auto port mapping | `docker run -P nginx` |
| `-e` | Environment variables | `docker run -e ENV=prod app` |
| `-v` | Volume mount | `docker run -v /host:/container app` |
| `--network` | Specify network | `docker run --network mynet app` |
| `--memory` | Memory limit | `docker run --memory 512m app` |

## Common Deployment Patterns

### Web Server Pattern
```bash
# Tomcat/TomEE
docker run --name webserver -p 7070:8080 -d tomee

# Nginx
docker run --name appserver -P -d nginx

# Access: http://<host_ip>:<mapped_port>
```

### Development Server Pattern
```bash
# Jenkins
docker run --name devserver -p 9090:8080 -d jenkins/jenkins

# Access: http://<host_ip>:9090
```

### Interactive OS Pattern
```bash
# Ubuntu
docker run --name myubuntu -it ubuntu

# CentOS
docker run --name mycentos -it centos

# Exit with: exit
```

## Workflow Scenarios

### Scenario 1: Web Application Deployment
```bash
# 1. Pull application image
docker pull <app_image>

# 2. Run with port mapping
docker run --name webapp -p 80:8080 -d <app_image>

# 3. Verify deployment
docker container ls
docker logs webapp

# 4. Access application
# http://<host_ip>:80
```

### Scenario 2: Development Environment
```bash
# 1. Create development container
docker run --name devenv -it -v $(pwd):/workspace ubuntu

# 2. Install development tools inside container
apt update && apt install -y git vim nodejs npm

# 3. Work on project in /workspace
# 4. Exit and restart when needed
docker start devenv
docker exec -it devenv bash
```

### Scenario 3: Multi-Service Stack
```bash
# Database
docker run --name db -e MYSQL_ROOT_PASSWORD=secret -d mysql

# Application
docker run --name app --link db:database -p 8080:8080 -d myapp

# Web Server
docker run --name web --link app:backend -p 80:80 -d nginx
```

## Quick Reference Commands

### Health Checks
```bash
# Check container status
docker ps

# View resource usage
docker stats

# Check port mappings
docker port <container_name>
```

### Troubleshooting
```bash
# View container logs
docker logs <container_name>

# Follow logs in real-time
docker logs -f <container_name>

# Inspect container configuration
docker inspect <container_name>

# Execute diagnostic commands
docker exec -it <container_name> ps aux
docker exec -it <container_name> netstat -tlnp
```

### Cleanup Operations
```bash
# Remove unused containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Complete cleanup
docker system prune -a --volumes
```

## Best Practices

1. **Always name your containers** for easier management
2. **Use specific image tags** instead of `latest` in production
3. **Map ports explicitly** for predictable access
4. **Use volumes** for persistent data
5. **Run containers in detached mode** for services
6. **Monitor resource usage** with `docker stats`
7. **Clean up regularly** to save disk space
8. **Use environment variables** for configuration
9. **Implement health checks** for production containers
10. **Use multi-stage builds** to reduce image size