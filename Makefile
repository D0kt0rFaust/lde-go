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
	echo "Remove code: main"
	rm -rf ${LOCAL_CODE_PATH_MAIN}

main-env-copy:
	echo "Copy .env: main: skip"

main-packages-install:
	echo "main-packages-install: skip"

main-migration:
	echo "main-migration: skip"

### Telegram bot

bot-git-clone:
	echo "Clone repository: bot"
	git clone ${LOCAL_GIT_REPOSITORY_BOT} -b ${LOCAL_GIT_BRANCH_BOT} ${LOCAL_CODE_PATH_BOT}

bot-rm-code:
	echo "Remove code: bot"
	rm -rf ${LOCAL_CODE_PATH_BOT}

bot-env-copy:
	echo "Copy .env: bot"
	cp -rf ${LOCAL_CODE_PATH_BOT}/.env.example ${LOCAL_CODE_PATH_BOT}/.env

bot-packages-install:
	echo "bot-packages-install: skip"

bot-migration:
	echo "bot-migration: skip"

### Together

git-clone:
	make \
		main-git-clone \
		bot-git-clone

rm-code:
	make \
		main-rm-code \
		bot-rm-code

env-copy:
	make \
		main-env-copy \
		bot-env-copy

packages-install:
	make \
		main-packages-install \
		bot-packages-install

migration:
	make \
		main-migration \
		bot-migration

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
	docker compose restart app-bot