export MODULE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MODULE_HOME)/scripts
export DOT_HOME_CONFIG := $(MODULE_HOME)/config
INSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-host-dependencies.sh
INSTALL_HOST_DEPENDENCIES_WSL2 := $(SCRIPTS_DIR)/install-host-dependencies-wsl2.sh
export UID := $(shell id -u)
export GID := $(shell id -g)
export GROUP := $(shell id -gn)
export GPG_TTY := $(shell tty)
export IMAGE_VERSION := 1.3.0
PASSWORD ?= $(shell bash -c 'read -r -s -p "Enter the Unix password to use inside the container: " pwd; echo $$pwd')

.PHONY: install build run exec trash start reload

install:
	@$(INSTALL_HOST_DEPENDENCIES)

install-wsl2:
	@$(INSTALL_HOST_DEPENDENCIES_WSL2)

# BUILDKIT instruction is required to use the secret flag
build:
	@echo $(PASSWORD) > $$HOME/delete-me.txt
	DOCKER_BUILDKIT=1 docker build \
		--build-arg USER=$$USER \
		--build-arg GROUP=$(GROUP) \
		--build-arg UID=$(UID) \
		--build-arg GID=$(GID) \
		--build-arg GIT_USER_NAME \
		--build-arg GIT_USER_USERNAME \
		--build-arg GIT_USER_EMAIL \
		--build-arg GIT_USER_SIGNINGKEY \
		--secret id=PASSWORD,src=$$HOME/delete-me.txt \
		-t do-not-push/$(GIT_USER_USERNAME)/dev-env-img:v$$IMAGE_VERSION .
	@rm $$HOME/delete-me.txt

run:
	docker run -it --rm -d \
		--net=host \
		--name dev-env-cont \
		-v $$(dirname $$SSH_AUTH_SOCK):$$(dirname $$SSH_AUTH_SOCK) \
		-v $$HOME/workspace:$$HOME/workspace \
		-v $$HOME/.gnupg:$$HOME/.gnupg \
		-e SSH_AUTH_SOCK=$$SSH_AUTH_SOCK \
		do-not-push/$(GIT_USER_USERNAME)/dev-env-img:v$$IMAGE_VERSION

exec:
	docker exec -it dev-env-cont /usr/bin/zsh

trash:
	docker container stop dev-env-cont

start: run exec

reload: trash start
