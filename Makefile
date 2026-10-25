include srcs/.env

# the compose command with project name and file, used by every rule
COMPOSE = docker compose -p inception -f srcs/docker-compose.yml

# default rule: build and start everything
all: up

# create the data folders, then build the images and start the containers
up:
	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
	@echo "Building and starting containers..."
	$(COMPOSE) up -d --build

# stop and remove the containers (images and data stay)
down:
	$(COMPOSE) down

# show the status of the containers
ps:
	$(COMPOSE) ps

# follow the logs of all containers
logs:
	$(COMPOSE) logs -f

# remove the containers and the images built by compose
clean:
	$(COMPOSE) down --rmi all

# remove everything: containers, images, volumes and the data on the host
fclean:
	$(COMPOSE) down --rmi all -v
	@echo "Deleting data in $(DATA_PATH)..."
	sudo rm -rf $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

re: fclean all

.PHONY: all up down ps logs clean fclean re
