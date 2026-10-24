#!/bin/sh
set -e
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# the volume may be mounted owned by root, so fix ownership
chown -R mysql:mysql /var/lib/mysql

# first start only: the data directory is still empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
	 mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

	mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
DELETE FROM mysql.global_priv WHERE User='';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
fi

# replace the shell with mysqld so it runs as PID 1
exec mysqld --user=mysql
