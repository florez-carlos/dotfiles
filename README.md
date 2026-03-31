# Dotfiles

A containerized development environment with essential tools and packages

# Table of Contents

* [Installation](#installation)
  * [Install basic dependencies](#install-basic-dependencies)
  * [Inject SSH Key](#inject-ssh-key)
  * [Create the workspace dir and clone the repo](#create-the-workspace-dir-and-clone-the-repo)
  * [Install required dependencies on the host machine](#install-required-dependencies-on-the-host-machine)
  * [Export required env variables](#export-required-env-variables)
  * [Build the Image](#build-the-image)
  * [Manually set font in terminal preferences](#manually-set-font-in-terminal-preferences)
* [Using Dotfiles](#using-dotfiles)
* [Configure a Remote SSH Client (optional)](#configure-a-remote-ssh-client-optional)

# Installation

> [!NOTE]
> Installation is supported for the following:
> - Ubuntu LTS (amd64)
>   - X11
>   - Wayland
> - MacOS (amd64/rosetta)

## Install basic dependencies
  
These dependencies are required to clone the repo and invoke the Makefile targets. <br>

### Ubuntu
```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install git make curl -y
```

### MacOS

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git make curl
```

## Inject SSH key 

> [!NOTE]
> This is necessary for repository authentication and commit signing <br>
> :exclamation: Ensure this key is added to github as both authentication and signing key

```bash
cd $HOME/workspace/dotfiles/scripts/ && ./inject-ssh-key.sh
```

Confirm the SSH agent is running and key is added
```bash
ssh-add -l
```

should give an output like so:
> <em>4096 SHA256:aaaaAAAAAAAAaaaaAAAAAAAAaa /home/user/.ssh/id_rsa (RSA)</em>


## Create the workspace dir and clone the repo

The workspace directory is a [volume](https://docs.docker.com/storage/volumes/) in the Docker container, it's important to clone all the repos and do all the <br> 
important work in this directory since it will be preserved between container shutdowns.

```bash
mkdir -p $HOME/workspace 
cd $HOME/workspace
git clone git@github.com:florez-carlos/dotfiles.git
cd dotfiles
```

## Install required dependencies on the host machine

These dependencies are directly installed to the host machine

### Ubuntu

Run the install target. <br>
> [!NOTE]
> This will install the dependencies listed on [host dependencies file](config/host-dependencies.txt) 

```bash
sudo make install -e USER=$USER -e HOME=$HOME
```
Log out and log back in for group changes to take effect </br>
```bash
sudo pkill -u $USER
```

### MacOS

```bash
make install
```

## Export required env variables

These are necessary to build your git config file, some are required at container build time and others are <br>
required at container runtime<br>
> [!NOTE]
> :exclamation: **Make sure to replace the variables in brackets with the relevant credentials.** <br>
> :warning: **if the value contains empty space, wrap the entire value in single quotes 'like this'**

### Ubuntu
```bash
cat <<EOT >> $HOME/.bashrc
export GIT_USER_NAME=<Git name, not the username but the name>
export GIT_USER_USERNAME=<Git username, not the name but the username>
export GIT_USER_SIGNINGKEY=<gpg public key id>
export GIT_USER_EMAIL=<example@example.com>
alias start='cd $HOME/workspace/dotfiles && make start'
alias hook='cd $HOME/workspace/dotfiles && make hook'
alias trash='cd $HOME/workspace/dotfiles && make trash'
alias reload='cd $HOME/workspace/dotfiles && make trash && sleep 5 && make start'
EOT
. $HOME/.bashrc
```

### MacOS

```bash
cat <<EOT >> $HOME/.zshrc
export GIT_USER_NAME=<Git name, not the username but the name>
export GIT_USER_USERNAME=<Git username, not the name but the username>
export GIT_USER_SIGNINGKEY=<gpg public key id>
export GIT_USER_EMAIL=<example@example.com>
alias start='cd $HOME/workspace/dotfiles && make start'
alias hook='cd $HOME/workspace/dotfiles && make hook'
alias trash='cd $HOME/workspace/dotfiles && make trash'
alias reload='cd $HOME/workspace/dotfiles && make trash && sleep 5 && make start'
EOT
. $HOME/.zshrc
```

## Build the image

```bash
cd $HOME/workspace/dotfiles || exit 1
make build
```

## Manually set font in terminal preferences

Set the font to 'MesloLGS' is terminal preferences and restart the terminal.

---

# Using Dotfiles

To start the container:
```bash
start
```

To reenter a running container:
```bash
hook
```

To trash the current instance of the container and start a new one:<br />
> [!NOTE]
> :warning: **Remember, only contents inside the ~/workspace dir will be persisted across shutdowns**
```bash
reload
```

To only trash the container and not start a new one:
```bash
trash
```

To update the host machine dependencies:<br />
> [!NOTE]
> Important to run this frequently in order to keep the host machine dependencies up-to-date
```bash
sudo make update-host
```

---

# Configure a remote SSH client (optional)

You only need to do this if connecting remotely from a different device

### Manually install MesloLGS fonts
Download the following fonts and install on your machine:

 * [Bold Italic](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Bold%20Italic.ttf)
 * [Bold](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Bold.ttf)
 * [Italic](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Italic.ttf)
 * [Regular](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Regular.ttf)

> [!NOTE]
> :warning: After installing the fonts you might have to manually set them on the terminal preferences/settings

### Add SSH key

> [!NOTE]
> Follow your client instructions to add an SSH key 

# License
[MIT](https://choosealicense.com/licenses/mit/)
