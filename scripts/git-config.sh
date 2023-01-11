cat << EOF > $XDG_CONFIG_HOME/git/config
[user]
    name = $GIT_USER_NAME
	username = $GIT_USER_USERNAME
    email = $GIT_USER_EMAIL
    signingkey = $GIT_USER_SIGNINGKEY
[core]
	editor = nvim
	whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
[gpg]
    program = gpg
[commit]
    gpgsign = true
[pager]
    diff = false
    show = false
    status = false
EOF

