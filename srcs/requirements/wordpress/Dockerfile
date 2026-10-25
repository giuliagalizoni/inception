# base image: penultimate stable Debian
FROM debian:bookworm

# install PHP-FPM (runs PHP), PHP CLI (needed by wp-cli),
# the MariaDB driver and the extensions WordPress uses;
# curl + certificates to download wp-cli over HTTPS
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		php8.2-fpm php8.2-cli php8.2-mysql \
		php8.2-curl php8.2-mbstring php8.2-xml \
		curl ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# download wp-cli (a tool to install WordPress from the terminal)
# and make it executable as the "wp" command
RUN curl -o /usr/local/bin/wp \
		https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp

# folder where PHP-FPM keeps its runtime files
RUN mkdir -p /run/php

# send PHP-FPM logs to stderr so they show in "docker logs"
RUN sed -i 's|^error_log = .*|error_log = /proc/self/fd/2|' /etc/php/8.2/fpm/php-fpm.conf

# our PHP-FPM config (listen on port 9000 for nginx)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# copy scripts into system PATH folder and make them executable
COPY tools/ /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# where the website files live (the volume is mounted here)
WORKDIR /var/www/html

# document the port PHP-FPM listens on (only nginx uses it)
EXPOSE 9000

# script that installs WordPress on first run, then starts PHP-FPM
ENTRYPOINT [ "setup.sh" ]
