FROM ghcr.io/florez-carlos/dev-env-ubuntu-base-img:v1.5.0
LABEL org.opencontainers.image.authors="carlos@florez.co.uk"

#Configurable args, define these with your own, these are build time args
ARG LOCALTIME=Pacific
ARG GIT_USER_NAME=user
ARG GIT_USER_USERNAME=user
ARG GIT_USER_EMAIL=none@none.com
ARG GIT_USER_SIGNINGKEY=gpg_key_id
ARG AZ_LOGIN_APP_ID=app_id
ARG AZ_LOGIN_TENANT_ID=tenant_id
ARG AZ_LOGIN_CERT_PATH=path
ARG AZ_LOGIN_VAULT_NAME=vault_name

#Static args (some of these are redefined by the Makefile)
ARG USER=user
ARG GROUP=user
ARG UID=1000
ARG GID=1000
ARG DEBIAN_FRONTEND=noninteractive

#All env variables available to the container
ENV USER=$USER
ENV GROUP=$GROUP
ENV UID=$UID
ENV GID=$GID
ENV LOCALTIME=$LOCALTIME
ENV GIT_USER_NAME=$GIT_USER_NAME
ENV GIT_USER_USERNAME=$GIT_USER_USERNAME
ENV GIT_USER_EMAIL=$GIT_USER_EMAIL
ENV GIT_USER_SIGNINGKEY=$GIT_USER_SIGNINGKEY
ENV AZ_LOGIN_APP_ID=$AZ_LOGIN_APP_ID
ENV AZ_LOGIN_TENANT_ID=$AZ_LOGIN_TENANT_ID
ENV AZ_LOGIN_CERT_PATH=$AZ_LOGIN_CERT_PATH
ENV AZ_LOGIN_VAULT_NAME=$AZ_LOGIN_VAULT_NAME
ENV HOME=/home/${USER}
ENV XDG_DATA_HOME=$HOME/.local/share
ENV XDG_CONFIG_HOME=$HOME/.config
ENV KEEP_ZSHRC=yes
ENV TERM=xterm-256color
ENV DOT_HOME=/usr/local/src/dotfiles
ENV DOT_HOME_SCRIPTS=$DOT_HOME/scripts
ENV DOT_HOME_ZSH=$DOT_HOME/zsh
ENV DOT_HOME_LIB=$DOT_HOME/lib
ENV DOT_HOME_VIM=$DOT_HOME/vim
ENV M2_HOME=$HOME/.m2
ENV WORKSPACE=$HOME/workspace

SHELL ["/bin/bash", "-c"]

#Create User
RUN groupadd -g ${GID} -r ${GROUP}

#Read password secret from a file
RUN --mount=type=secret,id=PASSWORD \
    password="$(cat /run/secrets/PASSWORD)" \
 && useradd -rm -s /bin/bash -g ${GROUP} -G sudo -u ${UID} ${USER} -p "$(openssl passwd -1 ${password})"

#Set Timezone to user provided/default
RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/US/$LOCALTIME /etc/localtime

RUN mkdir -p {$HOME,$DOT_HOME,$DOT_HOME_SCRIPTS,$DOT_HOME_ZSH,$DOT_HOME_LIB,$DOT_HOME_VIM,$DOT_HOME_LIB/jdtls,$DOT_HOME_LIB/maven,$XDG_DATA_HOME/jdtls-data,$XDG_CONFIG_HOME/nvim,$XDG_DATA_HOME/nvim/site,$XDG_CONFIG_HOME/git,$M2_HOME,$WORKSPACE}

ADD ./scripts $DOT_HOME_SCRIPTS
ADD ./zsh $DOT_HOME_ZSH
ADD ./lib $DOT_HOME_LIB
ADD ./vim $DOT_HOME_VIM

RUN chown -R ${USER}:${GROUP} $HOME
RUN chown -R ${USER}:${GROUP} $DOT_HOME
RUN chown -R ${USER}:${GROUP} $XDG_DATA_HOME/jdtls-data
RUN chsh ${USER} -s $(which zsh)

RUN chmod +x -R $DOT_HOME_SCRIPTS

USER ${USER}

#Link Dotfiles
RUN ln -s $DOT_HOME_ZSH/zshrc $HOME/.zshrc \
&& ln -s $DOT_HOME_ZSH/zlogin $HOME/.zlogin \
&& ln -s $DOT_HOME_ZSH/zprofile $HOME/.zprofile \
&& ln -s $DOT_HOME_ZSH/zshenv $HOME/.zshenv \
&& ln -s $DOT_HOME_VIM/init.lua $XDG_CONFIG_HOME/nvim/init.lua \
&& ln -s $DOT_HOME_VIM/ftplugin $XDG_CONFIG_HOME/nvim/ftplugin \
&& ln -s $DOT_HOME_VIM/pack $XDG_DATA_HOME/nvim/site/pack \
&& ln -s $DOT_HOME_VIM/lua $XDG_CONFIG_HOME/nvim/lua

#Install Powerlevel10k
RUN yes Y | $DOT_HOME_LIB/ohmyzsh/tools/install.sh
RUN ln -s $DOT_HOME_LIB/powerlevel10k ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k \
&& ln -s $DOT_HOME_ZSH/p10k.zsh $HOME/.p10k.zsh

#Install jdtls (Java LSP) and custom maven
RUN tar -xvzf /tmp/jdtls.tar.gz -C $DOT_HOME_LIB/jdtls
RUN tar -xvzf /tmp/maven.tar.gz -C $DOT_HOME_LIB/maven
RUN cp /tmp/lombok.jar $DOT_HOME_LIB/lombok.jar

#Creates Git configuration
RUN cd $DOT_HOME_SCRIPTS && ./git-config.sh 

WORKDIR ${WORKSPACE}
ENTRYPOINT ["tail", "-f", "/dev/null"]
