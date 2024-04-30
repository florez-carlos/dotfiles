# Dotfiles

A containerized development environment with essential tools and packages

# Table of Contents

* [Installation](#installation)
  * [Install basic dependencies](#install-basic-dependencies)
  * [Add SSH and GPG Keys](#add-ssh-and-gpg-keys)
    * [SSH Key](#ssh-key)
    * [GPG Key](#gpg-key)
  * [Create the workspace dir and clone the repo](#create-the-workspace-dir-and-clone-the-repo)
  * [Add Azure Service Principal Certficate](#add-azure-service-principal-certificate)
  * [Install required dependencies on the host machine](#install-required-dependencies-on-the-host-machine)
  * [Export required env variables to bashrc](#export-required-env-variables-to-bashrc)
  * [Set pinentry-mode in gpg conf file](#set-pinentry-mode-in-gpg-conf-file)
  * [Login to the Github container registry to gain access to the base image](#login-to-the-github-container-registry-to-gain-access-to-the-base-image)
  * [Build the Image](#build-the-image)
  * [Manually set font in terminal preferences](#manually-set-font-in-terminal-preferences)
  * [Enable UFW Ports (optional)](#enable-ufw-ports-optional)
* [Using Dotfiles](#using-dotfiles)
* [Configure a Remote SSH Client (optional)](#configure-a-remote-ssh-client-optional)
* [Adding an existing SSH key](#adding-an-existing-ssh-key)
* [Creating an SSH key](#creating-an-ssh-key)
* [Adding an existing GPG key](#adding-an-existing-gpg-key)
* [Creating-a-gpg-key](#creating-a-gpg-key)
* [Known Issues](#known-issues)


# Installation

Supported Distros:

 - Ubuntu 20.04+

> [!NOTE]
> If using a remote SSH client to connect to the host machine, make sure to [follow these instructions](#configure-a-remote-ssh-client-optional) to set up the remote SSH client


## Install basic dependencies
  
These dependencies are required to clone the repo and invoke the Makefile targets. <br>

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install git make curl -y
```

## Add SSH and GPG keys

These are necessary for repository authentication and commit signing

### SSH key

Follow the instructions to [add an existing SSH key](#adding-an-existing-ssh-key) </br>
> [!NOTE]
> If you don't have an existing SSH key, follow these instructions to [create an SSH key](#creating-an-ssh-key)

### GPG key

Follow the instructions to [add an existing GPG key](#adding-an-existing-gpg-key) </br>
> [!NOTE]
> If you don't have an existing GPG key, follow these instructions to [create a GPG key](#creating-a-gpg-key)

## Create the workspace dir and clone the repo

The workspace directory is a [volume](https://docs.docker.com/storage/volumes/) in the Docker container, it's important to clone all the repos and do all the <br> 
important work in this directory since it will be preserved between container shutdowns.

```bash
mkdir -p $HOME/workspace 
cd $HOME/workspace
git clone git@github.com:florez-carlos/dotfiles.git
cd dotfiles
```
## Add Azure Service Principal Certificate

This certificate is used to authenticate against Azure, allowing for programmatic access of Azure resources </br>
Add the certificate in PEM format to the workspace directory, the certificate must hold both private key/public certificate </br>
> [!NOTE]
> :warning: Replace the path in brackets with the path to the existing certificate
```bash
#This example assumes the certificate is already present in the same machine
cp </path/to/az/certificate> $HOME/workspace/terminal-auth-cert.pem
```
> [!NOTE]
> Some repositories need programatic access to Azure in order to access files that may be outside of Git Version Control

## Install required dependencies on the host machine

These dependencies are directly installed to the host machine

Run the install target. <br>
> [!NOTE]
> This will install the following to the host machine: MesloLGS, Minikube and the dependencies listed on [host dependencies file](config/host-dependencies.txt) 

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
> [!NOTE]
> :exclamation: **Make sure to replace the variables in brackets with the relevant credentials.** <br>
> :warning: **if the value contains empty space, wrap the entire value in single quotes 'like this'**

```bash
cat <<EOT >> $HOME/.bashrc
export GIT_USER_NAME=<Git name, not the username but the name>
export GIT_USER_USERNAME=<Git username, not the name but the username>
export GIT_USER_SIGNINGKEY=<gpg public key id>
export GIT_USER_EMAIL=<example@example.com>
export AZ_LOGIN_APP_ID=<Azure login service principal app id>
export AZ_LOGIN_TENANT_ID=<Azure login service principal tenant id>
export AZ_LOGIN_CERT_PATH=<Azure login service principal certificate path>
export AZ_LOGIN_VAULT_NAME=<Azure login service principal vault name>
EOT
. $HOME/.bashrc
```

## Set pinentry-mode in gpg conf file

This fixes an issue where gpg does not prompt for the passphrase when attempting to sign a commit in the container.

```bash
cat <<EOT >> $HOME/.gnupg/gpg.conf
pinentry-mode loopback
EOT
```

## Login to the Github container registry to gain access to the base image

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

```bash
cd $HOME/workspace/dotfiles
make build
```

## Manually set font in terminal preferences

Set the font to 'MesloLGS' is terminal preferences and restart the terminal.

## Enable UFW ports (optional)

This is only required if using a remote SSH client
> [!NOTE]
> :warning: This will enable ports 22,80,443 on the host machine

```bash
make enable-ufw
```

---

# Using Dotfiles

```bash
cd $HOME/workspace/dotfiles
```

To start the container:
```bash
make start
```

To reenter a running container:
```bash
make hook
```

To trash the current instance of the container and start a new one:<br />
> [!NOTE]
> :warning: **Remember, only contents inside the ~/workspace dir will be persisted across shutdowns**
```bash
make reload
```

To only trash the container and not start a new one:
```bash
make trash
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
> If using Ubuntu as the SSH client, follow [these instructions](#adding-an-existing-ssh-key) to add the SSH key to the SSH agent in order to connect to the remote machine.


# Adding an existing SSH key

> [!NOTE]
> :warning: It's assumed name of the key is <em>id_rsa</em> </br>

Create the .ssh directory and assign correct permissions

```bash
mkdir -p $HOME/.ssh
sudo chmod 700 $HOME/.ssh
```

Place the keys into the .ssh directory </br>
> [!NOTE]
> :warning: Replace the path in brackets with the path to the existing SSH key

```bash
# This example assumes the key already exists somewhere in the same machine
cp <path/to/private/ssh/key> $HOME/.ssh/id_rsa
cp <path/to/public/ssh/key> $HOME/.ssh/id_rsa.pub
```

Assign the correct permissions to the SSH files

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

Create the .ssh directory and assign correct permissions
```bash
mkdir -p $HOME/.ssh
sudo chmod 700 $HOME/.ssh
```

Generate a new RSA key that can be used for SSH authentication </br>
> [!NOTE]
> Notice the key is being generated with a comment of <em>dev1</em>, the comment appears at the end of the public key signature and has no impact on the key therefore feel free to replace for a more suitable comment </br>
> :warning: It's important to avoid generating an <em>ed_25519</em> key as it is currently not supported by the Azure SSH key resource (2023-09-12) </br>

```bash
ssh-keygen -m PEM -t rsa -b 4096 -C "dev1"
```
When presented with this prompt, type Enter to save to the default location
> Enter file in which to save the key (/home/user/.ssh/id_rsa):

Assign the correct permissions to the SSH files

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

# Adding an existing GPG key

Create the .gnupg directory

> [!NOTE]
> :warning: It's assumed name of the files are <em>public.pem</em> and <em>private.pem</em> </br>

```bash
mkdir -p $HOME/.gnupg
sudo chmod 700 $HOME/.gnupg
```

Place the keys into the .gnupg directory </br>
> [!NOTE]
> :warning: Replace the path in brackets with the path to the existing SSH key
```bash
# This example assumes the key already exists somewhere in the same machine
cp <path/to/gpg_pub/key> $HOME/.gnupg/public.pem
cp <path/to/gpg_priv/key> $HOME/.gnupg/private.pem
```

Assign the correct permissions to the files

```bash
sudo chmod 600 $HOME/.gnupg/private.pem
sudo chmod 600 $HOME/.gnupg/public.pem
```

Add the key to GPG agent
```bash
gpg --import $HOME/.gnupg/private.pem
```
Confirm the agent is running and key is added
```bash
gpg --list-keys
```
should give output like so
> /home/user/.gnupg/pubring.kbx </br>
> ================================== </br>
> pub   rsa4096 2022-09-29 [SC] [expires: 2023-09-29] </br>
>       333789457489594958AAAAA23483AABBBBCC </br>
> uid           [ unknown] Full Name <email@email.com> </br>
> sub   rsa4096 2022-09-29 [E] [expires: 2023-09-29] </br>

# Creating a GPG key

For instructions on generating a [GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

# Known Issues

The use of loopback pinentry provokes an error when attempting to delete a GPG key, to circumvent, use the following <br>
command when needing to delete a GPG key:
```bash
gpg --batch --yes delete-keys
```

# License
[MIT](https://choosealicense.com/licenses/mit/)
