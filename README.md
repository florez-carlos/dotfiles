# Dotfiles

Creates a containerized development environment with the following:

- zsh/oh-my-zsh
- Powerlevel10k
- neovim w/ LSP
- SSH and GPG keys usable in the container

## Table of Contents

* [Installation](#installation)
  * [Install basic dependencies](#install-basic-dependencies)
    * [Ubuntu](#ubuntu)
    * [WSL2 - Ubuntu distro](#wsl2---ubuntu-distro)
  * [Generate new GPG/SSH keys or import existing keys and add them to agents](#generate-new-gpgssh-keys-or-import-existing-keys-and-add-them-to-agents)
  * [Export required env variables to bashrc](#export-required-env-variables-to-bashrc)
  * [Set pinentry-mode in gpg conf file](#set-pinentry-mode-in-gpg-conf-file)
  * [Define required keychain command in bash_profile](#define-required-keychain-command-in-bash_profile)
    * [WSL2 - Ubuntu distro](#wsl2---ubuntu-distro-1)
  * [Clone the repo with recurse submodules](#clone-the-repo-with-recurse-submodules)
  * [Install required dependencies on the host machine](#install-required-dependencies-on-the-host-machine)
    * [Ubuntu](#ubuntu-1)
    * [WSL2 - Ubuntu distro](#wsl2---ubuntu-distro-2)
  * [Set font to MesloLGS in your terminal](#set-font-to-meslolgs-in-your-terminal)
  * [Build the Image](#build-the-image)
  * [Running the dev env](#running-the-dev-env)


## Installation

## Install basic dependencies

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


## Generate new GPG/SSH keys or import existing keys and add them to agents

These will be available on the host machine and will be forwarded to the container

For reference on generating an [SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
For reference on generating a [GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

Continue to the 
[next section](#export-required-env-variables-to-bashrc,-make-sure-text-with-spaces-is-wrapped-in-quotes) 
if you have generated new keys and added them to the agents per the instructions above.

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

## Export required env variables to bashrc

- NOTE: Make sure to replace the variables in brackets with the relevant credentials
- NOTE: if the value contains empty space, wrap the entire value in single quotes 'like this'

```bash
cat <<EOT >> $HOME/.bashrc
export GIT_USER_NAME={Git name, not the username but name}
export GIT_USER_USERNAME={Git username, not the name but the username}
export GIT_USER_SIGNINGKEY={gpg public key id}
export GIT_USER_EMAIL={example@example.com}
EOT
. $HOME/.bashrc
```

## Set pinentry-mode in gpg conf file

This fixes an issue where gpg does not prompt for the passphrase
when attempting to sign a commit in the container.

```bash
cat <<EOT >> $HOME/.gnupg/gpg.conf
pinentry-mode loopback
EOT
```

## Define required keychain command in bash_profile

- NOTE: Only do this if on WSL2 - Ubuntu distro. <br>

Skip to the [next section](#create-the-workspace-dir-and-clone-the-repo-with-recurse-submodules) if on Ubuntu

### WSL2 - Ubuntu distro

```bash
cat <<EOT >> $HOME/.bash_profile
eval `keychain --eval --agents ssh id_ed25519`
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
EOT
. $HOME/.bash_profile
```

## Create the workspace dir and clone the repo with recurse submodules

The workspace directory is a volume in the container, it's important <br>
to clone all the repos and do all the important work in this directory <br>
since it will be preserved between container shutdowns.

```bash
mkdir $HOME/workspace
cd workspace
git clone --recurse-submodules -j8 git@github.com:florez-carlos/dotfiles.git
cd dotfiles
```

## Install required dependencies on the host machine

### Ubuntu

- Run the install target

This will install Docker and MesloLGS fonts on the host machine

```bash
sudo make install -e USER=$USER -e HOME=$HOME
```

- Log out

Log out and log back in for group changes to take effect

---

### WSL2 - Ubuntu distro

Follow these instructions to install 
[WSL2](https://docs.microsoft.com/en-us/windows/wsl/install)
and [Docker Desktop](https://docs.docker.com/desktop/windows/install/)


## Set font to MesloLGS in your terminal

Choose the MesloLGS NF font in your terminal preferences
You might have to restart your terminal for changes to take effect



## Login to the Github container registry to gain access to the base image

This is required to build the image

```bash
echo <Git Personal Access Token w/ at least read permissions> | docker login ghcr.io -u $GIT_USER_USERNAME --password-stdin
```

## Build the image

```bash
make build
```

## Running the dev env

The dev env is a runnig docker container that is being exec into

To run the dev env:
```bash
make start
```

To trash the dev env and start a new one:
WARNING: remember only contents inside the ~/workspace dir will be persisted across shutdowns
```bash
make reload
```

To only trash the dev env and not start a new one:
```bash
make trash
```


## License
[MIT](https://choosealicense.com/licenses/mit/)
