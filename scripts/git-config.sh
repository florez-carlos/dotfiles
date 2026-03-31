cat << EOF > $XDG_CONFIG_HOME/git/config
[user]
    name = $GIT_USER_NAME
    username = $GIT_USER_USERNAME
    email = $GIT_USER_EMAIL
    signingkey = ~/.ssh/id_rsa
[core]
    editor = nvim
    whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
[gpg]
    format = ssh
[commit]
    gpgsign = true
[pager]
    diff = false
    show = false
    status = false
EOF

