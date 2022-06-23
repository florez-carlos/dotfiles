export MODULE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MODULE_HOME)/scripts
export DOT_HOME_CONFIG := $(MODULE_HOME)/config
INSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-host-dependencies.sh
UNINSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/uninstall-host-dependencies.sh


install:
	@printf "%s\n" "This target is not supported for WSL2, refer to README for manual installation steps"

build:
	docker build --build-arg USER --build-arg PASSWORD --build-arg GIT_USER_NAME \
		--build-arg GIT_USER_USERNAME --build-arg GIT_USER_EMAIL \
		--build-arg GIT_USER_SIGNINGKEY --build-arg SSH_AUTH_SOCK -t dev-env-img .

run:
	docker run -it --rm --name dev-env-cont -d -v $$(dirname $$SSH_AUTH_SOCK):$$(dirname $$SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$$SSH_AUTH_SOCK dev-env-img

exec:
	docker exec -it dev-env-cont /usr/bin/zsh

trash:
	docker container stop dev-env-cont
