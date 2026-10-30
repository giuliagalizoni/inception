FROM debian:bookworm

# installs mariadb and cleanup system tables
RUN apt-get update \
	&& apt-get install -y --no-install-recommends mariadb-server mariadb-client \
	&& rm -rf /var/lib/apt/lists/* /var/lib/mysql/*

# create a runtime directory and give ownership to the mysql user
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# copy files from build folder to the image (origin/destination)
COPY conf/ /etc/mysql/mariadb.conf.d/

# copy scripts into system PATH folder
COPY tools/ /usr/local/bin/

# give exec permissions to the scripts
RUN chmod +x /usr/local/bin/setup.sh

# expose which port the container listens on
EXPOSE 3306

# sets the command that runs when the container starts
ENTRYPOINT [ "setup.sh" ]
