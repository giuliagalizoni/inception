#!/bin/sh
# stops the script if any command fails
set -e

# read passwords from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# go to the website folder (the volume); wp-cli works on the current directory
cd /var/www/html

# download WordPress files if the volume is empty
if [ ! -f wp-load.php ]; then
	wp core download --allow-root
fi

# create wp-config.php with the database connection info
if [ ! -f wp-config.php ]; then
	wp config create --allow-root \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$WP_DB_HOST"
fi

# install the site (creates the admin user) if not done yet
if ! wp core is-installed --allow-root 2>/dev/null; then
	wp core install --allow-root \
		--url="https://$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email
fi

# create the second user if it doesn't exist yet
if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
	wp user create --allow-root \
		"$WP_USER" "$WP_USER_EMAIL" \
		--role=author \
		--user_pass="$WP_USER_PASSWORD"
fi

# make www-data the owner of all website files, so PHP (which runs as www-data) can write to them
chown -R www-data:www-data /var/www/html

# replace the shell with PHP-FPM so it runs as PID 1
exec php-fpm8.2 -F
