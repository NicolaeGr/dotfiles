# Load version control information
autoload -Uz vcs_info
precmd() {
	vcs_info
}

if [[ $- != *i* ]]; then
	return
fi

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '%F{088}(%b)'

# Set up the prompt (with git branch name)
setopt PROMPT_SUBST
RPROMPT='${vcs_info_msg_0_}'

# Test if connectiong over ssh, if so, show the hostname
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	ps1_hostname="@%{%F{032}%}%M"
else
	ps1_hostname=""
fi

# Colored prompt
autoload -U colors && colors
PS1="%F{053}[%F{178}%n%F{071}$ps1_hostname %F{172}%(3~|%-1~/…/%1~|%2~)%F{088}%F{053}]%{$reset_color%}$ "

tmpcmd() {
	if [ -z "$1" ]; then
		echo "Usage: tmpcmd <name>"
		return 1
	fi

	mkdir -p "/tmp/scripts/$USER"

	local name="$1-$$.sh"
	local tmpfile="/tmp/scripts/$USER/$name"

	touch "$tmpfile"
	chmod +x "$tmpfile"

	[[ ":$PATH:" != *":/tmp/scripts/$USER:"* ]] && export PATH="/tmp/scripts/$USER:$PATH"

	eval "alias edit-$name='${EDITOR:-vim} \"$tmpfile\"'"

	${EDITOR:-vim} "$tmpfile"

	echo "Executable '$name' created at $tmpfile. Edit it with 'edit-$name'."

	trap "rm -f '$tmpfile'" EXIT
}
