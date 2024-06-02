# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

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
