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

The following platforms are supported: <br>

 - Ubuntu
 - ~~WSL2 (Ubuntu distro) from here on referred only as 'WSL2'~~ (Support for WSL2 has been removed since V1.3.0)

---

## Configure SSH client (Optional)

You only need to do this if connecting remotely from a different device

Manually install MesloLGS fonts<br>
Download the following fonts and install on your machine:

 * [Bold Italic](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Bold%20Italic.ttf)
 * [Bold](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Bold.ttf)
 * [Italic](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Italic.ttf)
 * [Regular](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Regular.ttf)


## Install basic dependencies

These dependencies are required to clone the repo and invoke the Makefile targets. <br>

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install git make keychain -y
```

---

## Create the workspace dir and clone the repo with recurse submodules
> <em>(Ubuntu & WSL2)</em>

The workspace directory is a volume in the container, it's important to clone all the repos and do all the <br> 
important work in this directory since it will be preserved between container shutdowns.

```bash
mkdir -p $HOME/workspace 
cd $HOME/workspace
```

```bash
git clone --recurse-submodules -j8 git@github.com:florez-carlos/dotfiles.git
cd dotfiles
```
---

## Install required dependencies on the host machine

These dependencies are directly installed to the host machine

> ### Ubuntu

Run the install target. <br>
:information_source: This will install Docker and MesloLGS fonts on the host machine

```bash
sudo make install -e USER=$USER -e HOME=$HOME
```
:exclamation: **Log out and log back in for group changes to take effect before proceeding.**

> ### WSL2

Follow these instructions to install Docker Desktop:

 * [Docker Desktop](https://docs.docker.com/desktop/windows/install/)

Ensure Docker desktop is properly installed before proceeding. <br>

Manually install MesloLGS fonts in Windows. <br>
Download the following fonts, click on each font once downloaded and click install when prompted:

 * [Bold Italic](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Bold%20Italic.ttf)
 * [Bold](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Bold.ttf)
 * [Italic](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Italic.ttf)
 * [Regular](https://github.com/romkatv/powerlevel10k-media/blob/master/MesloLGS%20NF%20Regular.ttf)

Once the fonts have been installed, open the Windows terminal settings and change the face font to 'MesloLGS NF' for the ubuntu profile. <br>
> :warning: **Restart your terminal for changes to take effect.**

Run the install-wsl2 target. <br>
> :information_source: **This will install minikube, kubectl, jq on the host machine.**
```bash
sudo make install-wsl2
```

---

## Generate a new SSH key
> <em>(Ubuntu & WSL2)</em>

If you already have an existing SSH key, skip to [Import an existing SSH key](#import-an-existing-ssh-key) <br>

For instructions on generating an [SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) <br>

---

## Import an existing SSH key
> <em>(Ubuntu & WSL2)</em>

If you have generated a new SSH key following the instruction above, skip to [Generate a new GPG key](#generate-a-new-gpg-key)

### Export from the device where keys are available

If your keys are already exported to an external device or the cloud, skip to [Import to the new device](#import-to-the-new-device-1) <br>

Export your existing keys to an external device

```bash
cp $HOME/.ssh/id_ed25519 <path/to/external/device>
cp $HOME/.ssh/id_ed25519.pub <path/to/external/device>
```
-OR- <br>

Export your existing keys to Azure vault. <br>

:exclamation: **az cli is required to run the following commands**.

```bash
az keyvault secret set --vault-name <vault name> --name <private key secret name> --file $HOME/.ssh/id_ed25519
az keyvault secret set --vault-name <vault name> --name <public key secret name> --file $HOME/.ssh/id_ed25519.pub
```

### Import to the new device

Create the .ssh directory and assign the correct permissions

```bash
mkdir -p $HOME/.ssh
sudo chmod 700 $HOME/.ssh
```

Retrieve your keys from external device by copying them into the .ssh directory

```bash
cp <path/to/private/ssh/key> $HOME/.ssh/id_ed25519
cp <path/to/public/ssh/key> $HOME/.ssh/id_ed25519.pub
```
Assign the correct permissions to your keys

```bash
sudo chmod 600 $HOME/.ssh/id_ed25519
sudo chmod 600 $HOME/.ssh/id_ed25519.pub
```

Init the SSH agent and add the private key to it

```bash
eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_ed25519
```

Confirm ssh agent is available and key is properly added

```bash
ssh-add -l
```

Running the above command should have a similar output to this: <br>
> <em>256 SHA256:AaaaaaaaaaAAAAAAAAAAABBBBBbbbb example@email.com (ED25519)</em>
If so, then the ssh agent is available and the key has been correctly added.

--- 

## Generate a new GPG key
> <em>(Ubuntu & WSL2)</em>

If you already have an existing GPG key, skip to [Import an existing GPG key](#import-an-existing-gpg-key)

For instructions on generating a [GPG key](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)

--- 

## Import an existing GPG key
> <em>(Ubuntu & WSL2)</em>

If you have generated a new GPG key following the instructions above, skip to [Export required env variables to bashrc](#export-required-env-variables-to-bashrc)

### Export from the device where keys are available

If your keys are already exported to an external device or the cloud, skip to [Import to the new device](#import-to-the-new-device-2) <br>

Export your existing keys. <br>
:exclamation: **replace brackets with the email associated with your key.**

```bash
gpg --output $HOME/public.pgp --armor --export <email@example.com>
```

```bash
gpg --output $HOME/private.pgp --armor --export-secret-key <email@example.com>
```

Copy your existing keys to an external device

```bash
cp $HOME/public.pgp <path/to/external/device>
```
```bash
cp $HOME/private.pgp <path/to/external/device>
```
-OR- <br>

Export your existing keys to Azure Vault. <br>
:exclamation: **az cli is required to run the following commands.**

```bash
az keyvault secret set --vault-name <vault name> --name <public key secret name> --file $HOME/public.pgp
```

```bash
az keyvault secret set --vault-name <vault name> --name <private key secret name> --file $HOME/private.pgp
```

### Import to the new device

Create the .gnupg directory

```bash
mkdir -p $HOME/.gnupg
```

Retrieve your keys from external device by copying them into the .gnupg directory
```bash
cp <path/to/gpg_pub/key> $HOME/.gnupg/public.pem
```
```bash
cp <path/to/gpg_priv/key> $HOME/.gnupg/private.pem
```

Assign the correct permissions to your keys

```bash
sudo chmod 600 $HOME/.gnupg/private.pem
sudo chmod 600 $HOME/.gnupg/public.pem
```

Add the key to GPG agent
```bash
gpg --import $HOME/.gnupg/private.pem
```

---

## Export required env variables to bashrc
> <em>(Ubuntu & WSL2)</em>

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
> <em>(Ubuntu & WSL2)</em>

This fixes an issue where gpg does not prompt for the passphrase when attempting to sign a commit in the container.

```bash
cat <<EOT >> $HOME/.gnupg/gpg.conf
pinentry-mode loopback
EOT
```

---

## Define required keychain command in bash_profile
> <em>(WSL2 ONLY)</em>

Skip to the [Create the workspace dir and clone the repo with recurse submodules](#create-the-workspace-dir-and-clone-the-repo-with-recurse-submodules) if not on WSL2. <br>
This is required in WSL2 to automatically start the agent and add the ssh key to it. <br>
:exclamation: **Only do this if using WSL2.** <br>

> ### WSL2

```bash
cat <<"EOT" > $HOME/.bash_profile
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

---

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

# Known Issues

The use of loopback pinentry provokes an error when attempting to delete a GPG key, to circumvent, use the following <br>
command when needing to delete a GPG key:
```bash
gpg --batch --yes delete-keys
```
TODO: git submodule update --remote --merge

# License
[MIT](https://choosealicense.com/licenses/mit/)
