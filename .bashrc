# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#the ghstbskr section of the file, *ahem*

#figlet ghstbskr | lolcat
neofetch --ascii ~/.watermark

#im going to add these to ~/.bash_aliases
#alias ls='ls -F '
#alias ll='ls -lh '
#alias gh='history|grep '
#alias hg='history|grep '
#alias tp='trash-put '

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# scrape user's ~/.config/scripts folder, make each script executable, and add to aliases
SCRIPTS=$(ls ~/.config/scripts)
REALHOME=$(realpath ~/)
for script in $SCRIPTS ; do \
  chmod +x $REALHOME/.config/scripts/$script
  alias $(echo "$script" | cut -f 1 -d '.')="bash $REALHOME/.config/scripts/$script" ; \
done

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
#HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Store multi-line commands in one history entry:
shopt -s cmdhist

# append to the history file, don't overwrite it
shopt -s histappend

# save each command right after it has been executed
PROMPT_COMMAND='history -a'

# donâ€™t save ls, ps and history commands
#export HISTIGNORE="ls:ps:history"

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
    else
  color_prompt=
    fi
fi

# set variable identifying the chroot you work in (used in the prompt below)
#if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#    debian_chroot=$(cat /etc/debian_chroot)
#fi

# head here for better options http://networking.ringofsaturn.com/Unix/Bash-prompts.php
#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
#unset color_prompt force_color_prompt

# Custom bash prompt via kirsle.net/wizards/ps1.html
#PS1='\n#\[$(tput bold)\]\[$(tput setaf 4)\]\d \t \[$(tput setaf 4)\][\[$(tput setaf 2)\]\u\[$(tput setaf 4)\]@\[$(tput setaf 2)\]\H\[$(tput setaf 7)\]:\[$(tput setaf 6)\]\W\[$(tput setaf 4)\]]\[$(tput setaf 1)\]\\$ \n\[$(tput sgr0)\]'

#made with the bash generator at http://omar.io/ps1gen/
export PS1="\n\[\e[0;37m\]# \[\e[0;31m\]\d \[\e[0;31m\]\t \[\e[0;37m\][\[\e[0;32m\]\u\[\e[0;37m\]@\[\e[0;32m\]\H\[\e[0;37m\]]\[\e[0;37m\]: \[\e[0;36m\]\w\[\e[0m\]\n"

# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# https://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="%h %d %H:%M:%S "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
