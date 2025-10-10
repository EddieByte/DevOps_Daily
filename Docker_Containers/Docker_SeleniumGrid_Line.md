# Selenium Grid with Docker – Full Setup, Workflow, and Learnings

## Overview

This was a deep dive into Selenium Grid using Docker containers, where I explored how Selenium manages distributed browser testing environments and how containers communicate internally. The process helped me understand Docker networking, event bus communication, and the difference between headless and GUI-based nodes.

**Goal:** Set up a Selenium Grid Hub, connect multiple browser nodes (Chrome and Firefox), and view the running browsers via VNC Viewer for a visual test interface.

---

## Step-by-Step Workflow

### 1. Clean the Environment

Before starting, I made sure no existing containers or networks were interfering with the setup:

```bash
docker rm -f selenium-hub chrome firefox
docker network rm selenium-grid
```

This ensures a clean slate before building a fresh grid.

### 2. Create a Custom Docker Network

Selenium Grid's hub and nodes need to communicate internally, so I created a custom bridge network for them:

```bash
docker network create selenium-grid
```

> **Note:** Containers within the same network can reference each other by name (like `selenium-hub`) instead of IP addresses.

### 3. Run the Selenium Hub

The hub acts as the central coordinator that receives test requests and routes them to available browser nodes.

```bash
docker run -d -p 4445:4444 \
--net selenium-grid \
--name selenium-hub \
selenium/hub:latest
```

**Access the hub's web interface:** <http://localhost:4445/ui>

At this point, the Selenium Grid UI shows a running hub but no connected nodes.

### 4. Add Browser Nodes (Chrome and Firefox)

Next, I started two browser nodes, each connecting to the Selenium Hub through environment variables that define the event bus host and ports:

```bash
# Chrome Node
docker run -d --name chrome \
--net selenium-grid \
-e SE_EVENT_BUS_HOST=selenium-hub \
-e SE_EVENT_BUS_PUBLISH_PORT=4442 \
-e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
selenium/node-chrome:latest

# Firefox Node
docker run -d --name firefox \
--net selenium-grid \
-e SE_EVENT_BUS_HOST=selenium-hub \
-e SE_EVENT_BUS_PUBLISH_PORT=4442 \
-e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
selenium/node-firefox:latest
```

**Key Learning:**

- The hub and nodes communicate through an event bus
- Without the correct host and ports, the nodes won't register to the hub, and the grid stays empty

### 5. Verify Container Setup

List all running containers:

```bash
docker ps
```

You should see `selenium-hub`, `chrome`, and `firefox` containers all running and connected to the same `selenium-grid` network.

### 6. Access Selenium Grid Dashboard

Open: <http://localhost:4445/ui>

This dashboard visually confirms that both Chrome and Firefox nodes are active and ready to receive sessions.

### 7. Attempt to View Browser GUI via VNC

Initially, I expected to view the browser's visual interface (like a remote desktop) through VNC Viewer. Each node exposes a port (like 5901, 5902), so connecting via VNC should have shown the browsers running live tests.

However, modern Selenium images (`selenium/node-chrome` and `selenium/node-firefox`) run in headless mode — meaning no graphical display. When connecting through VNC, only the base environment appeared, not the browsers themselves.

---

## Key Learnings and Insights

### 1. Docker Networking Matters

The `--net selenium-grid` bridge network allows containers to communicate by name. Without this, the hub and nodes fail to sync.

### 2. Event Bus Is the Backbone

The `SE_EVENT_BUS_HOST`, `PUBLISH_PORT`, and `SUBSCRIBE_PORT` variables form the backbone of communication between hub and nodes. They're essential for proper registration and job routing.

### 3. Headless Browsers Are Now Default

- Selenium Grid 4+ focuses on automation efficiency rather than GUI visualization
- Older `-debug` images (like `selenium/node-chrome-debug`) are deprecated or unavailable on Docker Hub
- **Tradeoff:** Lighter performance and CI/CD compatibility, but no live GUI view

### 4. VNC Access Requires Custom Setup

To actually see the browsers, you now need:

- A legacy standalone-debug image (if available), or
- A custom Docker image with a desktop environment + VNC server installed manually

Modern workflow recommends headless browsers with screenshots and logs instead of VNC.

### 5. Practical Understanding of Grid Architecture

This exercise made the internal flow clear:

- **Hub:** Acts as the central coordinator
- **Nodes:** Register and announce capabilities
- **Event Bus:** Bridges the hub-node communication
- **Tests:** Are distributed dynamically across nodes

---

## Summary

This hands-on experience provided deep insights into:

- Docker container networking and communication
- Selenium Grid architecture and event bus system
- Modern headless browser automation workflows
- The evolution from GUI-based to headless testing environments
