.SILENT:

include .env

### Hosts

main-hosts:
	echo "127.0.0.1  ${LOCAL_HOSTNAME_MAIN}"
	grep -q "127.0.0.1  ${LOCAL_HOSTNAME_MAIN}" "${HOSTS}" || echo '127.0.0.1  ${LOCAL_HOSTNAME_MAIN}' | sudo tee -a "${HOSTS}"

pma-hosts:
	echo "127.0.0.1  ${LOCAL_HOSTNAME_PMA}"
	grep -q "127.0.0.1  ${LOCAL_HOSTNAME_PMA}" "${HOSTS}" || echo '127.0.0.1  ${LOCAL_HOSTNAME_PMA}' | sudo tee -a "${HOSTS}"

traefik-hosts:
	echo "127.0.0.1  ${LOCAL_HOSTNAME_TRAEFIK}"
	grep -q "127.0.0.1  ${LOCAL_HOSTNAME_TRAEFIK}" "${HOSTS}" || echo '127.0.0.1  ${LOCAL_HOSTNAME_TRAEFIK}' | sudo tee -a "${HOSTS}"

### Main service

main-git-clone:
	echo "Clone repository: main"
	git clone ${LOCAL_GIT_REPOSITORY_MAIN} -b ${LOCAL_GIT_BRANCH_MAIN} ${LOCAL_CODE_PATH_MAIN}

main-rm-code:
	echo "Remove code: back"
	rm -rf ${LOCAL_CODE_PATH_MAIN}

main-env-copy:
	echo "Copy .env: main"
	cp -rf ${LOCAL_CODE_PATH_MAIN}/.env.example ${LOCAL_CODE_PATH_MAIN}/.env

main-packages-install:
	echo "main-packages-install: skip"

main-migration:
	echo "main-migration: skip"

### Together

git-clone:
	make \
		main-git-clone

rm-code:
	make \
		main-rm-code

env-copy:
	make \
		main-env-copy

packages-install:
	make \
		main-packages-install

migration:
	make \
		main-migration

### 

hosts:
	make \
		main-hosts \
		pma-hosts \
		traefik-hosts

network:
	docker network inspect traefik_net >/dev/null 2>&1 || docker network create traefik_net

build:
	docker compose build

up: network
	docker compose up -d

restart:
	docker compose restart

down:
	docker compose down

down-v:
	- docker compose down -v --rmi local

clean-build-cache:
	- yes | docker builder prune -a

clean: clean-build-cache
	- docker compose down --rmi local

###

lde: hosts git-clone env-copy network build up
	echo "Local Docker Environment installed"

re:
	docker compose restart app-main