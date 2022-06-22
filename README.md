# Dotfiles

Dotfiles contains and updated configuration for the vim editor

## Installation

### Intall basic dependencies

```bash
apt-get install git make -y
```

### Add your ssh/gpg keys
```bash
cp /path/to/ssh/priv/key $HOME/.ssh/id_ed25519
cp /path/to/ssh/pub/key $HOME/.ssh/id_ed25519.pub
chmod 600 $HOME/.ssh/id_ed25519
chmod 600 $HOME/.ssh/id_ed25519.pub
eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_ed25519
cp /path/to/gpg/priv/key $HOME/.gnupg/private.pem
cp /path/to/gpg/pub/key $HOME/.gnupg/public.pem
chmod 600 $HOME/.gnupg/private.pem
chmod 600 $HOME/.gnupg/public.pem
gpg --import $HOME/.gnupg/private.pem
```

### Define requiered env variables in bashrc/zshrc, make sure text with spaces is wrapped in quotes
```bash
cat <<EOT >> $HOME/.bashrc
export USER=linuxusername
export PASSWORD=linuxuserpassword
export GIT_USER_NAME='Git name, not username but name'
export GIT_USER_USERNAME='this-one-is-the-git-username'
export GIT_USER_SIGNINGKEY='gpg public key id'
export GIT_USER_EMAIL='example@example.com'
EOT
. $HOME/.bashrc
```

### Clone the repo and recurse submodules

```bash
git clone --recurse-submodules -j8 
cd dotfiles
```

### Create gpg folder in repo and copy gpg private key to it

```bash
mkdir gpg
cp $HOME/.gnupg/private.pem gpg/private.pem
```

### Install required dependencies on the host machine

```bash
sudo make install -e USER=$USER -e HOME=$HOME
```

### Log out

Log out and log back in for group changes to take effect

### Configure fonts in terminal settings

Choose the MesloLGS NF font in your terminal preferences

### Build the image
This will take a while :)
```bash
make build
```

### Run the container

```bash
make run
```

### Exec the container

```bash
make exec
```


## License
[MIT](https://choosealicense.com/licenses/mit/)
