# Dotfiles

A containerized development environment with essential tools and packages

# Table of Contents

* [Installation](#installation)
  * [Install basic dependencies](#install-basic-dependencies)
  * [Create the workspace dir and clone the repo with recurse submodules](#create-the-workspace-dir-and-clone-the-repo-with-recurse-submodules)
  * [Install required dependencies on the host machine](#install-required-dependencies-on-the-host-machine)
  * [Generate a new SSH key](#generate-a-new-ssh-key)
  * [Import an existing SSH key](#import-an-existing-ssh-key)
    * [Export from the device where keys are available](#export-from-the-device-where-keys-are-available-1)
    * [Import to the new device](#import-to-the-new-device-1)
  * [Generate a new GPG key](#generate-a-new-gpg-key)
  * [Import an existing GPG key](#import-an-existing-gpg-key)
    * [Export from the device where keys are available](#export-from-the-device-where-keys-are-available-2)
    * [Import to the new device](#import-to-the-new-device-2)
  * [Export required env variables to bashrc](#export-required-env-variables-to-bashrc)
  * [Set pinentry-mode in gpg conf file](#set-pinentry-mode-in-gpg-conf-file)
  * [Define required keychain command in bash_profile](#define-required-keychain-command-in-bash_profile)
  * [Login to the Github container registry to gain access to the base image](#login-to-the-github-container-registry-to-gain-access-to-the-base-image)
  * [Build the Image](#build-the-image)
* [Using Dotfiles](#using-dotfiles)
* [Known Issues](#known-issues)


# Installation

:information_source: Supported Distros: <br>

 - Ubuntu 20.04 or above

:information_source: If using a remote SSH client to connect to the host machine, make sure to [follow these instructions](#configure-a-remote-ssh-client-optional) to set up the remote SSH client


## Install basic dependencies
  
These dependencies are required to clone the repo and invoke the Makefile targets. <br>

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install git make -y
```

## Add SSH and GPG keys

These are necessary for repository authentication and commit signing

### SSH key

Follow the instructions to [add an existing SSH key](#adding-an-existing-ssh-key) </br>
:information_source:If you don't have an existing SSH key, follow these instructions to [create an SSH key](#creating-an-ssh-key)

### GPG key

Follow the instructions to [add an existing GPG key](#adding-an-existing-gpg-key) </br>
:information_source: If you don't have an existing GPG key, follow these instructions to [create a GPG key](#creating-a-gpg-key)

## Create the workspace dir and clone the repo with recurse submodules

The workspace directory is a [volume](https://docs.docker.com/storage/volumes/) in the Docker container, it's important to clone all the repos and do all the <br> 
important work in this directory since it will be preserved between container shutdowns.

```bash
mkdir -p $HOME/workspace 
cd $HOME/workspace
git clone --recurse-submodules -j8 git@github.com:florez-carlos/dotfiles.git
cd dotfiles
```

## Install required dependencies on the host machine

These dependencies are directly installed to the host machine

Run the install target. <br>
:information_source: This will install Docker and MesloLGS fonts on the host machine

```bash
sudo make install -e USER=$USER -e HOME=$HOME
```
Log out and log back in for group changes to take effect </br>
```bash
sudo pkill -u $USER
```





## Export required env variables to bashrc

These are necessary to build your git config file, some are required at container build time and others are <br>
required at container runtime, therefore it's recommended to keep these env variables in your .bashrc <br>
:exclamation: **Make sure to replace the variables in brackets with the relevant credentials.** <br>
> :warning: **if the value contains empty space, wrap the entire value in single quotes 'like this'**

```bash
cat <<EOT >> $HOME/.bashrc
export GIT_USER_NAME=<Git name, not the username but the name>
export GIT_USER_USERNAME=<Git username, not the name but the username>
export GIT_USER_SIGNINGKEY=<gpg public key id}
export GIT_USER_EMAIL=<example@example.com>
export AZ_LOGIN_APP_ID=<Azure login service principal app id>
export AZ_LOGIN_TENANT_ID=<Azure login service principal tenant id>
export AZ_LOGIN_CERT_PATH=<Azure login service principal certificate path>
export AZ_LOGIN_VAULT_NAME=<Azure login service principal vault name>
EOT
. $HOME/.bashrc
```

---

## Set pinentry-mode in gpg conf file

This fixes an issue where gpg does not prompt for the passphrase when attempting to sign a commit in the container.

```bash
cat <<EOT >> $HOME/.gnupg/gpg.conf
pinentry-mode loopback
EOT
```

## Login to the Github container registry to gain access to the base image
> <em>(Ubuntu & WSL2)</em>

This is required to build the image. <br>

Add your Github Personal Access token with a minimum of package read permissions.

```bash
export GIT_PAT=<Github Personal Access Token with at least package read permissions>
```

Then login to the Github container registry.

```bash
echo $GIT_PAT | docker login ghcr.io -u $GIT_USER_USERNAME --password-stdin
```

## Build the image
> <em>(Ubuntu & WSL2)</em>

```bash
make build
```

---

# Using Dotfiles

```bash
cd $HOME/workspace/dotfiles
```

To start Dotfiles:
```bash
make start
```

To trash the current instance of Dotfiles and start a new one:<br />
> :warning: **Remember, only contents inside the ~/workspace dir will be persisted across shutdowns**
```bash
exit
```
```bash
make reload
```

To only trash Dotfiles and not start a new one:
```bash
make trash
```

# Configure a remote SSH client (Optional)

You only need to do this if connecting remotely from a different device

### Manually install MesloLGS fonts
Download the following fonts and install on your machine:

 * [Bold Italic](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Bold%20Italic.ttf)
 * [Bold](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Bold.ttf)
 * [Italic](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Italic.ttf)
 * [Regular](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Regular.ttf)

:warning: After installing the fonts you might have to manually set them on the terminal preferences/settings

### Add SSH key

:information_source: If using Ubuntu as the SSH client, follow [these instructions](#adding-an-ssh-key) to add the SSH key to the SSH agent in order to connect to the remote machine.


# Adding an existing SSH key
> <em>Ubuntu</em>


:warning: It's assumed name of the key is <em>id_rsa</em> </br>

Create the .ssh directory and assign correct permissions

```bash
mkdir -p $HOME/.ssh
sudo chmod 700 $HOME/.ssh
```

Place the keys into the .ssh directory </br>
:warning: Replace the path in brackets with the path to the existing SSH key

```bash
# This example assumes the key already exists somewhere in the same machine
cp <path/to/private/ssh/key> $HOME/.ssh/id_rsa
cp <path/to/public/ssh/key> $HOME/.ssh/id_rsa.pub
```

Assign the correct permissions to the SSH keys

```bash
sudo chmod 600 $HOME/.ssh/id_rsa
sudo chmod 600 $HOME/.ssh/id_rsa.pub
```

Install the keychain dependency, which starts the SSH agent automatically on login

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install keychain -y
cat <<"EOT" > $HOME/.bash_profile
eval `keychain --eval --agents ssh id_rsa`
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
EOT
. $HOME/.bash_profile
```

Confirm the SSH agent is running and key is added
```bash
ssh-add -l
```
should give an output like so:
> <em>4096 SHA256:aaaaAAAAAAAAaaaaAAAAAAAAaa /home/$user/.ssh/id_rsa (RSA)</em>

# Creating an SSH key
> <em>Ubuntu</em>


Create the .ssh directory and assign correct permissions
```bash
mkdir -p $HOME/.ssh
sudo chmod 700 $HOME/.ssh
```

Generate a new RSA key that can be used for SSH authentication </br>
:information_source: Notice the key is being generated with a comment of <em>dev1</em>, the comment appears at the end of the public key signature and has no impact on the key therefore feel free to replace for a more suitable comment </br>
:warning: It's important to avoid generating an <em>ed_25519</em> key as it is currently not supported by the Azure SSH key resource (2023-09-12) </br>

```bash
ssh-keygen -m PEM -t rsa -b 4096 -C "dev1"
```
When presented with this prompt, type Enter to save to the default location
> Enter file in which to save the key (/home/user/.ssh/id_rsa):

Assign the correct permissions to the SSH keys

```bash
sudo chmod 600 $HOME/.ssh/id_rsa
sudo chmod 600 $HOME/.ssh/id_rsa.pub
```
Install the keychain dependency, which starts the SSH agent automatically on login

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install keychain -y
cat <<"EOT" > $HOME/.bash_profile
eval `keychain --eval --agents ssh id_rsa`
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
EOT
. $HOME/.bash_profile
```

Confirm the SSH agent is running and key is added
```bash
ssh-add -l
```
should give an output like so:
> <em>4096 SHA256:aaaaAAAAAAAAaaaaAAAAAAAAaa /home/$user/.ssh/id_rsa (RSA)</em>


# Known Issues

The use of loopback pinentry provokes an error when attempting to delete a GPG key, to circumvent, use the following <br>
command when needing to delete a GPG key:
```bash
gpg --batch --yes delete-keys
```
TODO: git submodule update --remote --merge

# License
[MIT](https://choosealicense.com/licenses/mit/)
