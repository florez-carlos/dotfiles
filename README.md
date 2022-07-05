# Dotfiles

Creates a containerized development environment with the following:

- zsh/oh-my-zsh
- Powerlevel10k
- neovim w/ LSP
- SSH and GPG keys usable in the container

## Table of Contents


## Intall basic dependencies

These are required to clone the repo and invoke the Makefile targets. <br>
NOTE: WSL2 - Ubuntu distro requires some additional dependencies for SSH

### Ubuntu

```bash
apt-get install git make -y
```

---

### WSL2 - Ubuntu distro

```bash
apt-get install git make keychain socat -y
```

---

## Generate new GPG/SSH keys or import existing keys and add them to agents

These will be available on the host machine and will be forwarded to the container

For reference on generating an [SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
For reference on generating a [GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

Continue with the next section if you have generated new keys and added them to the agents per the instructions above.

If you already have existing SSH/GPG keys, however, then:

- Copy your existing priv/pub SSH key pair and set appropriate permissions

```bash
cp /path/to/ssh/priv_key $HOME/.ssh/id_ed25519
cp /path/to/ssh/pub_key $HOME/.ssh/id_ed25519.pub
chmod 600 $HOME/.ssh/id_ed25519
chmod 600 $HOME/.ssh/id_ed25519.pub
```

- Init the SSH agent and add the key to it

```bash
eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_ed25519
```

- Copy your existing priv/pub GPG key pair and set appropriate permissions
```bash
cp /path/to/gpg_priv/key $HOME/.gnupg/private.pem
cp /path/to/gpg_pub/key $HOME/.gnupg/public.pem
chmod 600 $HOME/.gnupg/private.pem
chmod 600 $HOME/.gnupg/public.pem
```

- Add the key to GPG agent
```bash
gpg --import $HOME/.gnupg/private.pem
```

## Export required env variables to bashrc, make sure text with spaces is wrapped in quotes

Make sure to replace the variables in brackets with the relevant credentials


NOTE: if the value contains empty space, wrap the entire value in single quotes 'like this'
```bash
cat <<EOT >> $HOME/.bashrc
export PASSWORD={Desired password for the user in container}
export GIT_USER_NAME={Git name, not the username but name}
export GIT_USER_USERNAME={Git username, not the name but the username}
export GIT_USER_SIGNINGKEY={gpg public key id}
export GIT_USER_EMAIL={example@example.com}
export GIT_PAT={The Personal Access Token}
EOT
. $HOME/.bashrc
```

## Clone the repo with recurse submodules

```bash
git clone --recurse-submodules -j8 
cd dotfiles
```

## Install required dependencies on the host machine

### Ubuntu

#### Run the install target

This will install Docker and MesloLGS fonts on the host machine

```bash
sudo make install -e USER=$USER -e HOME=$HOME
```

#### Log out

Log out and log back in for group changes to take effect

---

### WSL2 - Ubuntu distro

Follow these instructions to install 
[WSL2](https://docs.microsoft.com/en-us/windows/wsl/install)
and [Docker Desktop](https://docs.docker.com/desktop/windows/install/)


## Set font to MesloLGS in your terminal

Choose the MesloLGS NF font in your terminal preferences
You might have to restart your terminal for changes to take effect

## Build the image

```bash
make build
```

## Run the container

```bash
make run && make exec
```


## License
[MIT](https://choosealicense.com/licenses/mit/)
