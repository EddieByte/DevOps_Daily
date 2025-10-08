# Multi-Container LAMP + CI/CD + Testing Environment using Docker (on WSL)

## Overview

This project demonstrates the deployment of a multi-container Docker architecture built on WSL Ubuntu with Docker integration. It includes a full LAMP stack, a CI/CD pipeline environment, and a testing setup using Selenium Grid — all implemented locally.

The purpose is to simulate how isolated services (database, web, automation, and testing) interact in a DevOps workflow. This implementation uses Docker's legacy `--link` method for inter-container networking (to be later replaced by Docker Compose).

## Project Workflow

1. Setup and Configuration
2. Database Deployment (MySQL)
3. LAMP Stack Deployment
4. Inter-Container Linking
5. CI/CD Environment (Jenkins + Tomcat)
6. Testing Environment (Selenium Grid)
7. Cleanup and Best Practices
8. Transition to Docker Compose

---

## 1. Setup and Configuration

### Prerequisites

- WSL (Ubuntu) installed on Windows
- Docker Engine & CLI installed and integrated with WSL
- Stable network connectivity
- Basic familiarity with container commands

### Verify Installation

```bash
docker --version
```

### List Containers

```bash
docker ps
```

### Clean Environment Before Deployment

```bash
docker rm -f $(docker ps -aq)
```

---

## 2. Database Deployment (MySQL)

### Run MySQL Container

```bash
docker run \
  --name <db_container_name> \
  -d \
  -e MYSQL_ROOT_PASSWORD=<YOUR_PASSWORD_HERE> \
  mysql:5
```

**Naming Example:** Use descriptive names like `mysql-db`, `lamp-db`, or `dev-mysql`.

> **Note:** Replace `<YOUR_PASSWORD_HERE>` with your desired MySQL root password.

### Access MySQL Shell

```bash
docker exec -it <db_container_name> bash
mysql -u root -p
```

When prompted, enter the root password you defined.

### Example MySQL Session

```sql
SHOW DATABASES;
USE mysql;

CREATE TABLE dept (
  deptno INT PRIMARY KEY,
  dname VARCHAR(50),
  loc VARCHAR(50)
);

CREATE TABLE emp (
  empno INT PRIMARY KEY,
  ename VARCHAR(50),
  job VARCHAR(50),
  deptno INT,
  FOREIGN KEY (deptno) REFERENCES dept(deptno)
);
```

### Exit MySQL and Container

```bash
exit
# exit
```

---

## 3. LAMP Stack Deployment

### LAMP Stack Components

LAMP = Linux + Apache (Tomcat) + MySQL + PHP

Since Linux is provided by your Docker host, you'll deploy Apache, MySQL, and PHP as separate containers.

### Step 1: Run the Database (if not already running)

```bash
docker run \
  --name <db_container_name> \
  -d \
  -e MYSQL_ROOT_PASSWORD=<YOUR_PASSWORD_HERE> \
  mysql:5
```

> **Note:** Replace `<YOUR_PASSWORD_HERE>` with your desired MySQL root password.

### Step 2: Run Apache Tomcat Container

Link it with the database:

```bash
docker run \
  --name <web_container_name> \
  -d \
  -p 6060:8080 \
  --link <db_container_name>:db_alias \
  tomee
```

**Naming Example:**

- Apache container: `lamp-web`
- MySQL alias: `lamp-db`

### Step 3: Run PHP Container

Link PHP with both Apache and MySQL:

```bash
docker run \
  --name <php_container_name> \
  -d \
  --link <web_container_name>:web_alias \
  --link <db_container_name>:db_alias \
  php
```

### Validation

```bash
docker container ls
```

Inspect relationships:

```bash
docker inspect <web_container_name>
```

**Access Apache via browser:** <http://localhost:6060>

---

## 4. Inter-Container Linking Example

To test container communication manually, you can use lightweight containers like BusyBox.

### Step 1: Start the First Container

```bash
docker run --name <first_container> -it busybox
```

**Detach without exiting:** `CTRL + P + Q`

### Step 2: Start the Second Container and Link It

```bash
docker run \
  --name <second_container> \
  --link <first_container>:alias_name \
  -it busybox
```

### Test Communication

Ping the first container from the second:

```bash
ping alias_name
```

- **Stop with:** `CTRL + C`
- **Detach with:** `CTRL + P + Q`

---

## 5. CI/CD Environment (Jenkins + Tomcat)

This simulates a pipeline where Jenkins manages builds and deployments to multiple Tomcat servers.

### Step 1: Run Jenkins Container

```bash
docker run \
  --name <jenkins_container> \
  -d \
  -p 7070:8080 \
  jenkins/jenkins
```

**Access Jenkins:** <http://localhost:7070>

### Step 2: Run QA and Production Tomcat Containers

Each linked to Jenkins:

```bash
# QA Environment
docker run \
  --name <qa_tomcat_container> \
  -d \
  -p 8080:8080 \
  --link <jenkins_container>:jenkins \
  tomee

# Production Environment
docker run \
  --name <prod_tomcat_container> \
  -d \
  -p 9090:8080 \
  --link <jenkins_container>:jenkins \
  tomee
```

**Naming Example:**

- Jenkins: `jenkins-dev`
- QA server: `qa-tomcat`
- Production server: `prod-tomcat`

**Access URLs:**

- QA: <http://localhost:8080>
- Production: <http://localhost:9090>

---

## 6. Testing Environment (Selenium Grid)

This setup allows browser-based test automation using Selenium Hub and browser nodes.

### Step 1: Start Selenium Hub

```bash
docker run \
  --name <hub_container> \
  -d \
  -p 4444:4444 \
  selenium/hub
```

**Access Selenium Dashboard:** <http://localhost:4444>

### Step 2: Start Browser Nodes

**Chrome Node:**

```bash
docker run \
  --name <chrome_node> \
  -d \
  -p 5901:5900 \
  --link <hub_container>:selenium \
  selenium/node-chrome-debug
```

**Firefox Node:**

```bash
docker run \
  --name <firefox_node> \
  -d \
  -p 5902:5900 \
  --link <hub_container>:selenium \
  selenium/node-firefox-debug
```

### Step 3: Verify Containers

```bash
docker container ls
```

### VNC Access

Use VNC Viewer to view browser GUI:

- **Chrome:** localhost:5901
- **Firefox:** localhost:5902

> **Note:** Default password is usually `secret`, but always set your own in production.

---

## 7. Cleanup and Maintenance

### Remove All Containers

```bash
docker rm -f $(docker ps -aq)
```

### Prune Unused Resources

```bash
docker system prune -a
```

---

## 8. Transition to Docker Compose

For maintainability and scalability, replace `--link` with Docker Compose, which defines services declaratively.

### Sample docker-compose.yml

```yaml
version: "3.9"

services:
  db:
    image: mysql:8
    container_name: lamp-db
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql

  web:
    image: tomee
    container_name: lamp-web
    ports:
      - "6060:8080"
    depends_on:
      - db

  php:
    image: php
    container_name: lamp-php
    depends_on:
      - web
      - db

volumes:
  db_data:
```

**Validate YAML syntax at:** [yamllint.com](https://yamllint.com)

### Run Services

```bash
docker-compose up -d
```

---

## Key Takeaways

- ✅ Learned container networking using the legacy `--link` feature
- ✅ Deployed a modular LAMP stack using Docker containers
- ✅ Simulated a CI/CD pipeline with Jenkins and Tomcat
- ✅ Built a browser automation testing environment with Selenium Grid
- ✅ Practiced infrastructure cleanup and resource management
- ✅ Prepared for modern orchestration with Docker Compose

---

## Best Practices Summary

| Category | Best Practice |
|----------|---------------|
| **Naming** | Use lowercase with hyphens or underscores (`lamp-db`, `jenkins-dev`) |
| **Security** | Never hardcode passwords; use environment variables or `.env` |
| **Networking** | Prefer Docker Compose networks over `--link` (deprecated) |
| **Volumes** | Persist data with named volumes (e.g., `db_data`) |
| **Documentation** | Include clear workflows and command explanations |
| **Cleanup** | Regularly prune unused containers and images |

---

## Conclusion

This project encapsulates the core of container-based DevOps — modularity, automation, and environment parity. Each container serves a clear role, and their interaction mirrors real-world deployment pipelines.

The next phase will extend this setup with Docker Compose, improved network management, and eventually Kubernetes orchestration.
