export MODULE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MODULE_HOME)/scripts
export DOT_HOME_CONFIG := $(MODULE_HOME)/config
INSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-host-dependencies.sh
UNINSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/uninstall-host-dependencies.sh
export UID := $(shell id -u)
export GID := $(shell id -g)
export GROUP := $(shell id -gn)
export GPG_TTY := $(shell tty)

install:
	@$(INSTALL_HOST_DEPENDENCIES)

build:
	docker build \
		--build-arg USER=$$USER \
		--build-arg GROUP=$(GROUP) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		--build-arg PASSWORD \
		--build-arg GIT_USER_NAME \
		--build-arg GIT_USER_USERNAME \
		--build-arg GIT_USER_EMAIL \
		--build-arg GIT_USER_SIGNINGKEY \
		--build-arg GIT_PAT \
		--build-arg GPG_TTY=$(GPG_TTY) \
		-t dev-env-img .


run:
	docker run -it --rm -d \
		--name dev-env-cont \
		-v $$(dirname $$SSH_AUTH_SOCK):$$(dirname $$SSH_AUTH_SOCK) \
		-v $$HOME/workspace:$$HOME/workspace \
		-v $$HOME/.gnupg:$$HOME/.gnupg \
		-e SSH_AUTH_SOCK=$$SSH_AUTH_SOCK \
		dev-env-img

exec:
	docker exec -it dev-env-cont /usr/bin/zsh

trash:
	docker container stop dev-env-cont
