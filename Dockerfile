FROM ubuntu:focal-20220316
LABEL org.opencontainers.image.authors="carlos@florez.co.uk"

ARG USER=user
ARG PASSWORD=password
ARG DEBIAN_FRONTEND=noninteractive
ARG LOCALTIME=Eastern
ARG GIT_USER_NAME=user
ARG GIT_USER_USERNAME=user
ARG GIT_USER_EMAIL=none@none.com
ARG GIT_USER_SIGNINGKEY=nothing
ARG GIT_PAT
ARG SSH_AUTH_SOCK

ENV USER=$USER
ENV PASSWORD=$PASSWORD
ENV LOCALTIME=$LOCALTIME
ENV GIT_USER_NAME=$GIT_USER_NAME
ENV GIT_USER_USERNAME=$GIT_USER_USERNAME
ENV GIT_USER_EMAIL=$GIT_USER_EMAIL
ENV GIT_USER_SIGNINGKEY=$GIT_USER_SIGNINGKEY
ENV GIT_PAT=$GIT_PAT
ENV HOME=/home/${USER}
ENV XDG_DATA_HOME=$HOME/.local/share
ENV XDG_CONFIG_HOME=$HOME/.config
ENV KEEP_ZSHRC=yes
ENV TERM=xterm-256color
ENV DOT_HOME=/usr/local/src/dotfiles
ENV DOT_HOME_SCRIPTS=$DOT_HOME/scripts
ENV DOT_HOME_CONFIG=$DOT_HOME/config
ENV DOT_HOME_ZSH=$DOT_HOME/zsh
ENV DOT_HOME_LIB=$DOT_HOME/lib
ENV DOT_HOME_VIM=$DOT_HOME/vim
ENV SSH_AUTH_SOCK=$SSH_AUTH_SOCK


SHELL ["/bin/bash", "-c"]
RUN mkdir -p {$DOT_HOME_SCRIPTS,$DOT_HOME_CONFIG,$DOT_HOME_ZSH,$DOT_HOME_LIB,$DOT_HOME_VIM,$DOT_HOME_LIB/jdtls,$DOT_HOME_LIB/maven,$XDG_DATA_HOME/jdtls-data,$XDG_CONFIG_HOME/nvim,$XDG_DATA_HOME/nvim/site,$HOME/.gpg,$XDG_CONFIG_HOME/git}

ADD ./scripts $DOT_HOME_SCRIPTS
ADD ./config $DOT_HOME_CONFIG
ADD ./zsh $DOT_HOME_ZSH
ADD ./lib $DOT_HOME_LIB
ADD ./vim $DOT_HOME_VIM
ADD ./gpg $HOME/.gpg
RUN chmod +x -R $DOT_HOME_SCRIPTS
RUN $DOT_HOME_SCRIPTS/install-dependencies.sh
  
RUN groupadd -g 1000 -r ${USER}
RUN useradd -rm -s /bin/bash -g ${USER} -G sudo -u 1000 ${USER} -p "$(openssl passwd -1 $PASSWORD)"

RUN chown -R ${USER}:${USER} $HOME
RUN chown -R ${USER}:${USER} $DOT_HOME
RUN chown -R ${USER}:${USER} $XDG_DATA_HOME/jdtls-data
RUN chown -R ${USER}:${USER} $HOME/.gpg
RUN chsh ${USER} -s $(which zsh)
RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/US/$LOCALTIME /etc/localtime

RUN npm i -g pyright typescript typescript-language-server

RUN chmod 600 -R $HOME/.gpg && chmod 700 $HOME/.gpg

USER ${USER}

RUN ln -s $DOT_HOME_ZSH/zshrc $HOME/.zshrc \
&& ln -s $DOT_HOME_ZSH/zlogin $HOME/.zlogin \
&& ln -s $DOT_HOME_ZSH/zprofile $HOME/.zprofile \
&& ln -s $DOT_HOME_ZSH/zshenv $HOME/.zshenv \
&& ln -s $DOT_HOME_VIM/init.lua $XDG_CONFIG_HOME/nvim/init.lua \
&& ln -s $DOT_HOME_VIM/ftplugin $XDG_CONFIG_HOME/nvim/ftplugin \
&& ln -s $DOT_HOME_VIM/pack $XDG_DATA_HOME/nvim/site/pack \
&& ln -s $DOT_HOME_VIM/lua $XDG_CONFIG_HOME/nvim/lua

RUN yes Y | $DOT_HOME_LIB/ohmyzsh/tools/install.sh
RUN ln -s $DOT_HOME_LIB/powerlevel10k  ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k \
&& ln -s $DOT_HOME_ZSH/p10k.zsh $HOME/.p10k.zsh

RUN curl -L -o /tmp/jdtls.tar.gz https://download.eclipse.org/jdtls/milestones/1.9.0/jdt-language-server-1.9.0-202203031534.tar.gz
RUN curl -L -o /tmp/maven.tar.gz https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz

RUN tar -xvzf /tmp/jdtls.tar.gz -C $DOT_HOME_LIB/jdtls
RUN tar -xvzf /tmp/maven.tar.gz -C $DOT_HOME_LIB/maven

RUN gpg --batch --passphrase $(echo $PASSWORD) --import $HOME/.gpg/private.pem
RUN cd $DOT_HOME_SCRIPTS && ./git-config.sh 
RUN cd $DOT_HOME_SCRIPTS && ./mvn-settings.sh
WORKDIR /home/${USER}
ENTRYPOINT ["tail", "-f", "/dev/null"]
