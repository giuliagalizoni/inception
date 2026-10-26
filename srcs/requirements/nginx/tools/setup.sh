#!/bin/sh
# stop the script if any command fails
set -e

# create the self-signed certificate on first start only
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
	echo "Creating self-signed certificate for $DOMAIN_NAME..."
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=DE/ST=Berlin/L=Berlin/O=42Berlin/CN=$DOMAIN_NAME"
fi

# replace the shell with nginx in the foreground so it runs as PID 1
echo "Starting NGINX..."
exec nginx -g "daemon off;"
