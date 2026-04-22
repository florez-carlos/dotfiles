# Dotfiles

A containerized development environment with essential tools and packages

# Table of Contents

* [Installation](#installation)
  * [Install basic dependencies](#install-basic-dependencies)
  * [Inject SSH Key](#inject-ssh-key)
  * [Create the workspace dir and clone the repo](#create-the-workspace-dir-and-clone-the-repo)
  * [Install required dependencies on the host machine](#install-required-dependencies-on-the-host-machine)
  * [Config Git](#config-git)
  * [Build the Image](#build-the-image)
* [Using Dotfiles](#using-dotfiles)
* [Configure a Remote SSH Client (optional)](#configure-a-remote-ssh-client-optional)

# Installation

> [!NOTE]
> Installation is supported for the following:
> - Ubuntu LTS (amd64/arm64)
>   - X11
>   - Wayland
> - MacOS (arm64)

## Install basic dependencies
  
These dependencies are required to clone the repo and invoke the Makefile targets. <br>

### Ubuntu
```bash
sudo apt update -y && sudo apt upgrade -y
sudo apt install git make curl -y
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
make install
```
Log out and log back in for group changes to take effect </br>
```bash
sudo pkill -u $USER
```

### MacOS

```bash
make install
```

## Config Git

This will append to .bashrc/.zshrc your Git name, username, email <br>
It will also append necessary commands to use dotfiles
```bash
cd $HOME/workspace/dotfiles/scripts/ && ./inject-env.sh
```

## Build the image

```bash
cd $HOME/workspace/dotfiles
make build
```

## Manually set font in terminal preferences

Set the font to 'MesloLGS' is terminal preferences and restart the terminal.

---

# Using Dotfiles

## Start the Container
```bash
start
```

## Reenter a Running Container
```bash
hook
```

## Remove the container
```bash
trash
```

## Remove the container and start a new one<br />
> [!NOTE]
> :warning: **Remember, only contents inside the ~/workspace dir will be persisted across shutdowns**
```bash
reload
```

## Update Dotfiles

```bash
make update
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
[GNU GPLv3](https://github.com/florez-carlos/dotfiles/blob/main/LICENSE)
