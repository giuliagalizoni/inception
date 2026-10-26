# base image: penultimate stable Debian
FROM debian:bookworm

# install nginx and openssl (creates the TLS certificate)
RUN apt-get update \
	&& apt-get install -y --no-install-recommends nginx openssl \
	&& rm -rf /var/lib/apt/lists/*

# delete the default site, so only our config is used
RUN rm -f /etc/nginx/sites-enabled/default

# send nginx logs to stdout/stderr so they show in "docker logs"
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# create the folder for the certificate and its key
RUN mkdir -p /etc/nginx/ssl

# copy our server config where nginx loads extra configs
COPY conf/nginx.conf /etc/nginx/conf.d/inception.conf

# copy scripts into system PATH folder and make them executable
COPY tools/ /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# document the only port nginx listens on (HTTPS)
EXPOSE 443

# script that creates the certificate and starts nginx
ENTRYPOINT [ "setup.sh" ]
