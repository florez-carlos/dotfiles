#!/bin/bash

printf "Create New Key? (y/n) " && read -r ans

case $ans in
[Yy]*)
  # Generate a new PEM RSA key pair
  printf "Name of the key: " && read -r machine_name
  ssh-keygen -m PEM -t rsa -b 4096 -C "$machine_name"
  ;;
*)
  # Paste existing key pair
  printf %"s\n" "Paste Public Key (press ctrl+d twice):"
  PUBLIC_KEY=$(cat)

  printf %"s\n" ""
  printf %"s\n" ""
    
  printf %"s\n" "Paste Private Key (press ctrl+d twice):"
  PRIVATE_KEY=$(cat)

  # Ensure the .ssh directory exists
  mkdir -p "$HOME/.ssh"
  chmod 700 $HOME/.ssh

  # Write the keys to the standard locations
  cat > "$HOME/.ssh/id_rsa.pub" <<EOF
$PUBLIC_KEY
EOF
  cat > "$HOME/.ssh/id_rsa" <<EOF
$PRIVATE_KEY
EOF

  chmod 600 "$HOME"/.ssh/id_rsa 2>/dev/null
  chmod 644 "$HOME"/.ssh/id_rsa.pub 2>/dev/null

  ;;
esac

if [[ "$(uname -s)" == "Darwin" ]]; then
  RC_FILE=$HOME/.zshrc
else
  RC_FILE=$HOME/.bashrc
fi

cat >> "$RC_FILE" <<'EOF'
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
fi
ssh-add "$HOME/.ssh/id_rsa"
EOF

if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
fi
ssh-add ~/.ssh/id_rsa
