export IMAGE_VERSION := 3.0.1
export MODULE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MODULE_HOME)/scripts
export DOT_HOME_CONFIG := $(MODULE_HOME)/config
INSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-host-dependencies.sh
INSTALL_MAC_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-mac-host-dependencies.sh
SYSTEM := $(shell uname -s)
CONTAINER_HOME := /home/$$USER

# -- BUILD ARGS BEGIN ---
export UID := $(shell id -u)
export GID := $(shell id -g)
export GROUP := $(shell id -gn)
export GPG_TTY := $(shell tty)

# Uncomment the desired timezone or set with any available in /usr/share/timezone
# export LOCALTIME := America/Los_Angeles
# export LOCALTIME := America/New_York
export LOCALTIME := UTC

export NVM_VERSION := v0.40.3
#This is by commit hash
export ASTRONVIM_VERSION := ae96a25a77864a82d7e363ea4ca1fcfcfa20da94
# -- BUILD ARGS END --

# -- RUN ARGS BEGIN --
#Uncomment the desired python version, then build
# !This is only respected by venv on a python repo!
# export PYTHON_VERSION := 3.11
export PYTHON_VERSION := 3.12
# -- RUN ARGS END --

PASSWORD ?= $(shell bash -c 'read -r -s -p "Enter the Unix password to use inside the container: " pwd; echo $$pwd')

.PHONY: install enable-ufw build run exec trash start reload

install:

	@if [ "$(SYSTEM)" = "Darwin" ]; then \
		$(INSTALL_MAC_HOST_DEPENDENCIES); \
	else \
		$(INSTALL_HOST_DEPENDENCIES); \
		adduser $(USER) docker; \
		systemctl start nginx; \
	fi

# BUILDKIT instruction is required to use the secret flag
build:
	@echo $(PASSWORD) > $$HOME/delete-me.txt
	@if [ "$(SYSTEM)" = "Darwin" ]; then \
		DOCKER_BUILDKIT=1 docker build \
			--no-cache \
			--platform linux/amd64 \
			--build-arg USER=$$USER \
			--build-arg GROUP=$(GROUP) \
			--build-arg UID=$(UID) \
			--build-arg GID=$(GID) \
			--build-arg NVM_VERSION=$(NVM_VERSION) \
			--build-arg ASTRONVIM_VERSION=$(ASTRONVIM_VERSION) \
			--build-arg LOCALTIME=$(LOCALTIME) \
			--build-arg GIT_USER_NAME \
			--build-arg GIT_USER_USERNAME \
			--build-arg GIT_USER_EMAIL \
			--build-arg SYSTEM=$(SYSTEM) \
			--secret id=PASSWORD,src=$$HOME/delete-me.txt \
			-t do-not-push/$(GIT_USER_USERNAME)/dev-env-img:v$$IMAGE_VERSION . ; \
	else \
		DOCKER_BUILDKIT=1 docker build \
			--no-cache \
			--build-arg USER=$$USER \
			--build-arg GROUP=$(GROUP) \
			--build-arg UID=$(UID) \
			--build-arg GID=$(GID) \
			--build-arg HOST_INPUT_GID=$$(getent group input | cut -d: -f3) \
			--build-arg NVM_VERSION=$(NVM_VERSION) \
			--build-arg ASTRONVIM_VERSION=$(ASTRONVIM_VERSION) \
			--build-arg LOCALTIME=$(LOCALTIME) \
			--build-arg GIT_USER_NAME \
			--build-arg GIT_USER_USERNAME \
			--build-arg GIT_USER_EMAIL \
			--build-arg SYSTEM=$(SYSTEM) \
			--secret id=PASSWORD,src=$$HOME/delete-me.txt \
			-t do-not-push/$(GIT_USER_USERNAME)/dev-env-img:v$$IMAGE_VERSION . ; \
	fi
	@rm $$HOME/delete-me.txt

#xhost commands allow X server in the container, important for Wayland environments using Xwayland
run:
	@if [ "$(SYSTEM)" = "Darwin" ]; then \
		docker run -it --rm -d \
			--platform linux/amd64 \
			--net=host \
			--name dev-env-cont \
			-v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock \
			-v $$HOME/workspace:$(CONTAINER_HOME)/workspace \
			-v $$HOME/.gnupg:$(CONTAINER_HOME)/.gnupg \
			-v $$HOME/.ssh:$(CONTAINER_HOME)/.ssh \
			-e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock \
			-e PYTHON_VERSION=$$PYTHON_VERSION \
			-e DISPLAY=$$DISPLAY \
			-e WAYLAND_DISPLAY=$$WAYLAND_DISPLAY \
			do-not-push/$(GIT_USER_USERNAME)/dev-env-img:v$$IMAGE_VERSION ; \
	else \
		xhost +local:docker; \
		xhost +SI:localuser:$$(id -un); \
		docker run -it --rm -d \
			--net=host \
			--name dev-env-cont \
			--device=/dev/input:/dev/input \
			-v $$(dirname $$SSH_AUTH_SOCK):$$(dirname $$SSH_AUTH_SOCK) \
			-v $$HOME/workspace:$$HOME/workspace \
			-v $$HOME/.gnupg:$$HOME/.gnupg \
			-v $$HOME/.ssh:$(CONTAINER_HOME)/.ssh \
			-v /tmp/.X11-unix:/tmp/.X11-unix \
			-v $$XDG_RUNTIME_DIR/$$WAYLAND_DISPLAY:$$XDG_RUNTIME_DIR/$$WAYLAND_DISPLAY \
			-e XDG_RUNTIME_DIR=$$XDG_RUNTIME_DIR \
			-e XDG_SESSION_TYPE=$$XDG_SESSION_TYPE \
			-e SSH_AUTH_SOCK=$$SSH_AUTH_SOCK \
			-e PYTHON_VERSION=$$PYTHON_VERSION \
			-e DISPLAY=$$DISPLAY \
			-e WAYLAND_DISPLAY=$$WAYLAND_DISPLAY \
			do-not-push/$(GIT_USER_USERNAME)/dev-env-img:v$$IMAGE_VERSION ; \
	fi


update-host:
	
	@if [ "$(SYSTEM)" = "Darwin" ]; then \
		$(INSTALL_MAC_HOST_DEPENDENCIES); \
	else \
		$(INSTALL_HOST_DEPENDENCIES); \
	fi

hook:
	docker exec -it dev-env-cont /usr/bin/zsh

trash:
	docker container stop dev-env-cont

start: run hook

reload: trash start
