FROM ghcr.io/florez-carlos/dev-env-ubuntu-base-img:latest
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
ARG NVM_VERSION=v0.39.7

#Static args (some of these are redefined by the Makefile)
ARG USER=user
ARG GROUP=user
ARG UID=1000
ARG GID=1000
ARG KEEP_ZSHRC=yes

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

ENV KEEP_ZSHRC=$KEEP_ZSHRC
ENV HOME=/home/${USER}
ENV XDG_DATA_HOME=$HOME/.local/share
ENV XDG_CONFIG_HOME=$HOME/.config
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

# $XDG_CONFIG_HOME/nvim
# $XDG_DATA_HOME/nvim/site/pack/plugins
RUN mkdir -p {$XDG_DATA_HOME,$XDG_CONFIG_HOME,$DOT_HOME_ZSH,$XDG_DATA_HOME/jdtls-data,$XDG_CONFIG_HOME/git,$M2_HOME,$WORKSPACE}

ADD ./zsh $DOT_HOME_ZSH
ADD ./vim $DOT_HOME_VIM
ADD ./scripts $DOT_HOME_SCRIPTS

RUN chown -R ${USER}:${GROUP} $HOME $DOT_HOME $XDG_DATA_HOME/jdtls-data
RUN chsh ${USER} -s $(which zsh)

RUN chmod +x -R $DOT_HOME_SCRIPTS

USER ${USER}

#Link Dotfiles
RUN ln -s $DOT_HOME_ZSH/zshrc $HOME/.zshrc \
&& ln -s $DOT_HOME_ZSH/zlogin $HOME/.zlogin \
&& ln -s $DOT_HOME_ZSH/zprofile $HOME/.zprofile \
&& ln -s $DOT_HOME_ZSH/zshenv $HOME/.zshenv
# && ln -s $DOT_HOME_VIM/init.lua $XDG_CONFIG_HOME/nvim/init.lua \
# && ln -s $DOT_HOME_VIM/ftplugin $XDG_CONFIG_HOME/nvim/ftplugin \
# && ln -s $DOT_HOME_LIB/vim-plugins $XDG_DATA_HOME/nvim/site/pack/plugins/start \
# && ln -s $DOT_HOME_VIM/lua $XDG_CONFIG_HOME/nvim/lua

#Install Powerlevel10k
RUN yes Y | $DOT_HOME_LIB/ohmyzsh/tools/install.sh
RUN ln -s $DOT_HOME_LIB/powerlevel10k ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k \
&& ln -s $DOT_HOME_ZSH/p10k.zsh $HOME/.p10k.zsh

#Creates Git configuration
RUN cd $DOT_HOME_SCRIPTS && ./git-config.sh 

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

# Install npm dependencies
RUN . $XDG_CONFIG_HOME/nvm/nvm.sh && nvm install node
RUN . $XDG_CONFIG_HOME/nvm/nvm.sh && npm install -g neovim pyright typescript typescript-language-server

# Lunarvim
RUN git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim && rm -rf $HOME/.config/nvim/.git
RUN nvim --headless +'' +qa

RUN ln -s $DOT_HOME_VIM/ftplugin $XDG_CONFIG_HOME/nvim/ftplugin

# Enable pyright plugin
RUN echo -e '\
require "lspconfig".pyright.setup{}\
' >> $XDG_CONFIG_HOME/nvim/init.lua

# Set python provider version
RUN echo -e '\
vim.g.python3_host_prog = "/usr/local/bin/python" .. os.getenv("PYTHON_VERSION")\
' >> $XDG_CONFIG_HOME/nvim/init.lua

# Enable nvim-jdtls plugin
RUN echo -e '\
return {\n\
  {\n\
    "mfussenegger/nvim-jdtls",\n\
    name = "nvim-jdtls",\n\
  },\n\
}\
' > $XDG_CONFIG_HOME/nvim/lua/plugins/nvim-jdtls.lua

# Install pip dependencies
RUN /usr/local/bin/python3.8 -m pip install --upgrade pip setuptools wheel pynvim
RUN /usr/local/bin/python3.11 -m pip install --upgrade pip setuptools wheel pynvim


WORKDIR ${WORKSPACE}
ENTRYPOINT ["tail", "-f", "/dev/null"]
