cat << EOF > $XDG_CONFIG_HOME/git/config
[user]
    name = $GIT_USER_NAME
	username = $GIT_USER_USERNAME
    email = $GIT_USER_EMAIL
    signingkey = $GIT_USER_SIGNINGKEY
[core]
	editor = nvim
	whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
	pager = delta
[gpg]
    program = gpg
[commit]
    gpgsign = true

EOF

