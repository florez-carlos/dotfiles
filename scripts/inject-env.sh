#!/bin/bash

case "$SHELL" in
  */zsh)   RC_FILE="$HOME/.zshrc" ;;
  */bash)  RC_FILE="$HOME/.bashrc" ;;
  *)       RC_FILE="$HOME/.bashrc" ;;
esac

printf "Git Name: " && read -r git_name
export GIT_USER_NAME=$git_name
printf "Git Username: " && read -r git_username
export GIT_USER_USERNAME=$git_username
printf "Git Email: " && read -r git_email
export GIT_USER_EMAIL=$git_email

cat <<EOT >> $RC_FILE
export GIT_USER_NAME='$GIT_USER_NAME'
export GIT_USER_USERNAME=$GIT_USER_USERNAME
export GIT_USER_EMAIL=$GIT_USER_EMAIL
alias start='cd $HOME/workspace/dotfiles && make start'
alias hook='cd $HOME/workspace/dotfiles && make hook'
alias trash='cd $HOME/workspace/dotfiles && make trash'
alias reload='cd $HOME/workspace/dotfiles && make trash && sleep 5 && make start'
EOT
. $RC_FILE
