FROM ghcr.io/florez-carlos/dev-env-ubuntu-base-img:latest
LABEL org.opencontainers.image.authors="carlos@florez.co.uk"

ARG USER
ARG GROUP
ARG UID
ARG GID
ARG LOCALTIME
ARG NVM_VERSION
ARG ASTRONVIM_VERSION
ARG GIT_USER_NAME
ARG GIT_USER_USERNAME
ARG GIT_USER_EMAIL
ARG GIT_USER_SIGNINGKEY
ARG HOST_INPUT_GID
ARG SYSTEM

ENV USER=$USER
ENV GROUP=$GROUP
ENV UID=$UID
ENV GID=$GID
ENV LOCALTIME=$LOCALTIME
ENV NVM_VERSION=$NVM_VERSION
ENV ASTRONVIM_VERSION=$ASTRONVIM_VERSION
ENV GIT_USER_NAME=${GIT_USER_NAME}
ENV GIT_USER_USERNAME=$GIT_USER_USERNAME
ENV GIT_USER_EMAIL=$GIT_USER_EMAIL
ENV GIT_USER_SIGNINGKEY=$GIT_USER_SIGNINGKEY
ENV SYSTEM=$SYSTEM
ENV KEEP_ZSHRC=yes
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
ENV HOST_INPUT_GID=$HOST_INPUT_GID

SHELL ["/bin/bash", "-c"]

#Create User
RUN groupadd -g ${GID} -r ${GROUP} || true

#Read password secret from a file
RUN --mount=type=secret,id=PASSWORD \
    password="$(cat /run/secrets/PASSWORD)" \
 && useradd -rm -s /bin/bash -g ${GID} -G sudo -u ${UID} ${USER} -p "$(openssl passwd -1 ${password})"

#Add the input group (wayland only)
#Correct ssh agent socket permissions (mac only)
RUN <<-EOF
  if [ "${SYSTEM}" != "Darwin" ]; then
    IMAGE_INPUT_NAME=$(getent group $HOST_INPUT_GID | cut -d: -f1)
    if [ $(getent group $HOST_INPUT_GID) ]; then
      groupmod -g 2000 $IMAGE_INPUT_NAME
    fi
    if [ $(getent passwd $IMAGE_INPUT_NAME) ]; then
      usermod -g 2000 $IMAGE_INPUT_NAME
      usermod -u 2000 $IMAGE_INPUT_NAME
    fi
    groupadd -g $HOST_INPUT_GID input
    usermod -aG input $USER
  fi
EOF

#Set Timezone to user provided/default
RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/$LOCALTIME /etc/localtime

# $XDG_CONFIG_HOME/nvim
# $XDG_DATA_HOME/nvim/site/pack/plugins
RUN mkdir -p {$XDG_DATA_HOME,$XDG_CONFIG_HOME,$DOT_HOME_ZSH,$XDG_DATA_HOME/jdtls-data,$XDG_CONFIG_HOME/git,$M2_HOME,$WORKSPACE}

ADD ./zsh $DOT_HOME_ZSH
ADD ./vim $DOT_HOME_VIM
ADD ./scripts $DOT_HOME_SCRIPTS

RUN chown -R ${USER}:${GID} $HOME $DOT_HOME $XDG_DATA_HOME/jdtls-data
RUN chsh ${USER} -s $(which zsh)

RUN chmod +x -R $DOT_HOME_SCRIPTS

USER ${USER}

#Link Dotfiles
RUN ln -s $DOT_HOME_ZSH/zshrc $HOME/.zshrc \
&& ln -s $DOT_HOME_ZSH/zlogin $HOME/.zlogin \
&& ln -s $DOT_HOME_ZSH/zprofile $HOME/.zprofile \
&& ln -s $DOT_HOME_ZSH/zshenv $HOME/.zshenv

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
RUN git clone https://github.com/AstroNvim/template ~/.config/nvim
RUN cd ~/.config/nvim && git reset --hard ${ASTRONVIM_VERSION} && rm -rf $HOME/.config/nvim/.git
RUN nvim --headless +'' +qa

RUN ln -s $DOT_HOME_VIM/ftplugin $XDG_CONFIG_HOME/nvim/ftplugin

# Enable pyright plugin
RUN echo -e '\
vim.lsp.enable("pyright")\
' >> $XDG_CONFIG_HOME/nvim/init.lua

# Set python provider version
RUN echo -e '\
vim.g.python3_host_prog = "/usr/local/bin/python" .. os.getenv("PYTHON_VERSION")\
' >> $XDG_CONFIG_HOME/nvim/init.lua

# Enable nvim-jdtls plugin
RUN cat > $XDG_CONFIG_HOME/nvim/lua/plugins/nvim-jdtls.lua << 'EOF'
return {
  {
    "mfussenegger/nvim-jdtls",
    name = "nvim-jdtls",
  },
}
EOF

# Enable render-markdown plugin
RUN cat > $XDG_CONFIG_HOME/nvim/lua/plugins/render-markdown.lua << 'EOF'
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
}
EOF

# Install pip dependencies
RUN /usr/local/bin/python3.11 -m pip install --upgrade pip
RUN /usr/local/bin/python3.11 -m pip install setuptools wheel pynvim ruff build twine
RUN /usr/local/bin/python3.12 -m pip install --upgrade pip
RUN /usr/local/bin/python3.12 -m pip install setuptools wheel pynvim ruff build twine


WORKDIR ${WORKSPACE}
ENTRYPOINT ["tail", "-f", "/dev/null"]
