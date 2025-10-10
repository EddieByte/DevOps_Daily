# Selenium Grid Workflow using Docker Compose

## Project Overview

This project sets up a Selenium Grid environment using Docker Compose. It includes a Selenium Hub and two browser nodes (Chrome and Firefox) with VNC access for GUI monitoring. The workflow demonstrates how to orchestrate a distributed testing environment and provides a hands-on learning experience with Docker networking and container management.

## Docker Compose File

```yaml
services:
  selenium-hub:
    image: selenium/hub:latest
    container_name: selenium-hub
    ports:
      - "4445:4444"  # Selenium Hub UI
    networks:
      - selenium-grid

  chrome:
    image: selenium/node-chrome:latest
    container_name: chrome
    depends_on:
      - selenium-hub
    environment:
      - SE_EVENT_BUS_HOST=selenium-hub
      - SE_EVENT_BUS_PUBLISH_PORT=4442
      - SE_EVENT_BUS_SUBSCRIBE_PORT=4443
    ports:
      - "5901:5900"  # VNC access for Chrome
    networks:
      - selenium-grid

  firefox:
    image: selenium/node-firefox:latest
    container_name: firefox
    depends_on:
      - selenium-hub
    environment:
      - SE_EVENT_BUS_HOST=selenium-hub
      - SE_EVENT_BUS_PUBLISH_PORT=4442
      - SE_EVENT_BUS_SUBSCRIBE_PORT=4443
    ports:
      - "5902:5900"  # VNC access for Firefox
    networks:
      - selenium-grid

networks:
  selenium-grid:
    driver: bridge
```

## Workflow Steps

1. **Create Project Folder**

   ```bash
   mkdir selenium-grid
   cd selenium-grid
   ```

2. **Save the Docker Compose file**
   Save the above YAML content as `docker-compose.yml` inside the project folder.

3. **Start the Selenium Grid**

   ```bash
   docker-compose up -d
   ```

4. **Verify Running Containers**

   ```bash
   docker ps
   ```

   Expected containers: `selenium-hub`, `chrome`, `firefox`.

5. **Access Interfaces**

   * Selenium Grid UI: [http://localhost:4445/ui](http://localhost:4445/ui)
   * Chrome VNC: `vnc://localhost:5901` (password: `secret`)
   * Firefox VNC: `vnc://localhost:5902` (password: `secret`)

6. **Stop and Clean Up**

   ```bash
   docker-compose down
   ```

## Key Learnings

* Docker Compose simplifies multi-container management for distributed systems.
* Custom Docker networks enable container communication without exposing ports unnecessarily.
* Environment variables are essential for Selenium nodes to connect to the Hub.
* VNC access allows monitoring browser actions visually.
* Removing the `version:` key in Compose avoids warnings in modern Docker Compose versions.

## Notes & Best Practices

* Use `depends_on` to ensure nodes start after the Hub.
* Adjust `shm_size` if encountering browser crashes due to memory constraints.
* Default VNC password is `secret`; it can be changed via environment variables if needed.
* This setup can be scaled to multiple nodes by adding additional services or using `--scale`.
