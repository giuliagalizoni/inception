*This project has been created as part of the 42 curriculum by ggalizon.*

## Description

This is a System Administration project built with Docker. The goal is to learn about containers, images and volumes, and how to coordinate multiple containers with Docker Compose to build a complete service: a WordPress site, a database (MariaDB) and a web server (NGINX). The site is reachable only through HTTPS, and the database is not reachable from outside.

## Instructions

To build and start everything:
```bash
make
```
To stop the site:
```bash
make down
```

- Website: https://ggalizon.42.fr
- Admin panel: https://ggalizon.42.fr/wp-admin

For more information, see [USER_DOC](USER_DOC.md) and [DEV_DOC](DEV_DOC.md).

## Resources

#### General
- [Debian releases](https://www.debian.org/releases/)
- <https://dev.to/educhigon/docker-containers-how-to-think-about-it-inception-42-exercise-4op9>

#### Docker, containers, compose, networks, PID1
- [Docker documentation](https://docs.docker.com/)
- [Docker and the PID 1 zombie reaping problem](https://blog.phusion.nl/docker-and-the-pid-1-zombie-reaping-problem/)
- <https://www.youtube.com/watch?v=DQdB7wFEygo>
- <https://www.youtube.com/watch?v=q3VbsNozKyo>

#### WordPress, PHP-FPM
- [PHP documentation](https://www.php.net/docs.php)
- [WP-CLI](https://wordpress.org/cli/)
- [WordPress developer resources](https://developer.wordpress.org/)

#### NGINX
- [NGINX documentation](https://nginx.org/en/docs/)

#### MariaDB
- [MariaDB documentation](https://mariadb.com/docs)

#### AI

I used AI (mostly Claude, by Anthropic) to help me understand concepts like Docker, containers, images and volumes, and how containers relate to each other on a Docker network. I also used it to find references for the Dockerfiles, configuration files and scripts, to review the code for errors and syntax issues, and to polish the documentation. I checked all the concepts and information against the references and documentation linked above.

### Design choices

- Debian bookworm as the base image for all three services.
- One container per service, connected by one Docker network.
- Passwords in Docker secrets, other settings in `srcs/.env`.
- Named volumes that store data in `/home/ggalizon/data`.

### Comparisons

| | Option A | Option B |
|---|---|---|
| **Virtual Machines vs Docker** | A VM runs a full OS with its own kernel. Heavy and slow to start. | A container shares the host kernel. Light and fast to start. |
| **Secrets vs Environment Variables** | Secrets are files in `/run/secrets/`, only visible to the services that need them. | Environment variables are visible with `docker inspect` and in logs. OK for non-secret settings. |
| **Docker Network vs Host Network** | A Docker network isolates the containers. They reach each other by name, and only the ports you publish are open. | The host network removes the isolation. The container uses the host's ports directly. Forbidden in this project. |
| **Docker Volumes vs Bind Mounts** | A named volume is managed by Docker (`docker volume ls`). | A bind mount links any host folder directly into the container, with no Docker management. Not allowed for this project's data. |
