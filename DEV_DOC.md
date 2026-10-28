# Inception - Developer Documentation

This guide explains how to set up the project from an empty machine and how to work on it. For daily use, see [USER_DOC](USER_DOC.md).

## 1. Prerequisites

- A Linux virtual machine
- Docker Engine with the Docker Compose plugin (the command is `docker compose`)
- `make`, `git` and `sudo`

Add this line to `/etc/hosts` so the domain points to your machine:
```
127.0.0.1 ggalizon.42.fr
```

## 2. Setup from scratch

### Clone the repository

```bash
git clone <repository-url> inception
cd inception
```

### Create `srcs/.env`

This file is not in Git. Create it with these variables:

| Variable | Example | Meaning |
|---|---|---|
| `DOMAIN_NAME` | `ggalizon.42.fr` | Domain of the site |
| `MYSQL_DATABASE` | `mysite` | Database name |
| `MYSQL_USER` | `mysiteuser` | Database user |
| `WP_DB_HOST` | `mariadb:3306` | Database service name and port |
| `WP_TITLE` | `Inception` | Site title |
| `WP_ADMIN_USER` | `giulia` | Admin username (must not contain "admin") |
| `WP_ADMIN_EMAIL` | | Admin email |
| `WP_USER` | `mainuser` | Second user |
| `WP_USER_EMAIL` | | Second user email |
| `DATA_PATH` | `/home/ggalizon/data` | Where the volumes store data on the host |

### Create the secrets

The `secrets/` folder is not in Git. Create four files, with one password in each:

```
 secrets/db_password.txt
 secrets/db_root_password.txt
 secrets/wp_admin_password.txt
 secrets/wp_user_password.txt
```

Docker Compose gives each secret to the containers as a file in `/run/secrets/`. The `setup.sh` scripts read the passwords from there. No password should be written in a Dockerfile or in `.env`.

## 3. Build and launch

Every rule uses `docker compose -p inception -f srcs/docker-compose.yml`. The `-p inception` option sets the project name, which is used as a prefix for the volume and network names.

| Rule | Docker Compose command | What it does |
|---|---|---|
| `make` or `make up` | `up -d --build` | Creates the data folders, builds the images and starts the containers |
| `make down` | `down` | Stops and removes the containers and the network |
| `make ps` | `ps` | Shows the status of the containers |
| `make logs` | `logs -f` | Follows the logs of all containers |
| `make clean` | `down --rmi all` | Same as `down`, and deletes the images |
| `make fclean` | `down --rmi all -v` | Same as `clean`, deletes the volumes and the data in `DATA_PATH` |
| `make re` | | Runs `fclean`, then `make` |

### Start order

1. MariaDB starts first. A healthcheck (`mariadb-admin ping`) tells Docker when it is ready.
2. WordPress starts only when MariaDB is healthy.
3. NGINX starts after WordPress.

### First start and later starts

On the first start, the scripts create the database, the database user, the WordPress files and the two WordPress users. On later starts, they see the data already exists and skip this step.

This means that changing `.env` or `secrets/` after the first start has no effect. To apply the changes, run `make fclean` and then `make` or `make re`. This deletes all site content.

## 4. Manage containers, volumes and network

### Containers

```bash
docker compose -p inception ps    # status
docker logs nginx                 # logs of one container
docker exec -it wordpress sh      # open a shell in a container
```

### Database

Log in to the database:
```bash
docker exec -it mariadb mariadb -u mysiteuser -p mysite
```
Type the password from `secrets/db_password.txt`. Then check that the database is not empty:
```sql
SHOW TABLES;
```

### Volumes

```bash
docker volume ls
docker volume inspect inception_mariadb_data
docker volume inspect inception_wordpress_data
```
The output shows the path on the host, for example `/home/ggalizon/data/mariadb`.

### Network

```bash
docker network ls
docker network inspect inception_inception
```
The containers are on the `inception` network. They reach each other by service name: NGINX talks to `wordpress:9000`, and WordPress talks to `mariadb:3306`.

### Checks

Test the NGINX config:
```bash
docker exec nginx nginx -t
```

HTTP must not work (port 80 is closed):
```bash
curl -I http://ggalizon.42.fr
```

HTTPS must work (`-k` accepts the self-signed certificate):
```bash
curl -kI https://ggalizon.42.fr
```

Show the certificate:
```bash
openssl s_client -connect ggalizon.42.fr:443 </dev/null 2>/dev/null | openssl x509 -noout -subject -dates
```

Only TLS 1.2 and 1.3 are allowed:
```bash
openssl s_client -connect ggalizon.42.fr:443 -tls1_2 </dev/null   # works
openssl s_client -connect ggalizon.42.fr:443 -tls1_3 </dev/null   # works
openssl s_client -connect ggalizon.42.fr:443 -tls1_1 -cipher 'DEFAULT@SECLEVEL=0' </dev/null   # refused
```

## 5. Data and persistence

The project uses two named volumes:

| Volume | Path in the container | Path on the host |
|---|---|---|
| `mariadb_data` | `/var/lib/mysql` | `/home/ggalizon/data/mariadb` |
| `wordpress_data` | `/var/www/html` | `/home/ggalizon/data/wordpress` |

NGINX also uses `wordpress_data`, so it can serve the WordPress files.

The Makefile creates the two folders on the host before starting, because Docker needs them to exist.

### What is kept and what is deleted

| Action | Site data |
|---|---|
| `make down` | Kept |
| `make clean` | Kept |
| Reboot of the VM (then `make`) | Kept |
| A container crashes | Kept, the container restarts (`restart: unless-stopped`) |
| `make fclean` | Deleted |

`make fclean` uses `sudo rm -rf` because the files on the host belong to the users inside the containers (`mysql` and `www-data`).

The TLS certificate is not kept. NGINX creates a new one each time its container is created.

## 6. Change the configuration

Example 1: change the public port from 443 to 8443.

1. In `srcs/docker-compose.yml`, change `"443:443"` to `"8443:443"`.
2. Run `make down` and then `make`.
3. Update the site address saved in the database:

	```bash
	docker exec wordpress wp option update home 'https://ggalizon.42.fr:8443' --allow-root --path=/var/www/html
	docker exec wordpress wp option update siteurl 'https://ggalizon.42.fr:8443' --allow-root --path=/var/www/html
	```
4. Open https://ggalizon.42.fr:8443

Example 2: change the PHP-FPM port from 9000. The port must be the same in three files:

- `srcs/requirements/wordpress/conf/www.conf` (`listen`)
- `srcs/requirements/nginx/conf/nginx.conf` (`fastcgi_pass wordpress:9000`)
- `srcs/requirements/wordpress/Dockerfile` (`EXPOSE`)

Then run `make down` and `make`.

## 7. Project structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                  (not in Git)
└── srcs/
    ├── .env                  (not in Git)
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

Each service folder has a `Dockerfile`, a `.dockerignore`, a `conf/` folder with the config file and a `tools/` folder with `setup.sh`.
