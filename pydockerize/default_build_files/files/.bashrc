export HISTCONTROL="ignoreboth:erasedups"
 # This entire file indented one line so history ignores it

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

 # Helper for putting git branch on bash prompt
 parse_git_branch () {
     export __parse_git_branch__=1
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/( \1 )/'
 }

 # Function to source a file if it exists
 function source_if_exists () { 
     if [ -f "$1" ]; then
        . "$1"
     fi
 }

 # Function to source all files in a bash_hooks directory
 function source_bash_hooks () { 
     set +o history
     if compgen -G "/project/_pydockerize_/bash_hooks/*.sh" > /dev/null; then
         for hook in `ls /project/_pydockerize_/bash_hooks/*.sh`
         do
             source_if_exists $hook
         done
     fi
     set -o history
 }

 # Determine the way this shell is being run
 if [[ -n $PS1 ]]; then
     : # These are executed only for interactive shells
     SHELL_IS_INTERACTIVE=1
 else
     : # Only for NON-interactive shells
     SHELL_IS_INTERACTIVE=0
 fi
 
 if shopt -q login_shell ; then
     : # These are executed only when it is a login shell
     SHELL_IS_LOGIN=1
 else
     : # Only when it is NOT a login shell
     SHELL_IS_LOGIN=0
 fi


 # Determine the type of os being run 
 # uname_type=$(uname)  DELETE DELETE
 # mac_type="Darwin" DELETE DELETE
 if [ "$(uname)" == "Darwin" ]; then 
     export OS_TYPE="mac"
 else
     # This indicates running on some type of linux
     export OS_TYPE="container"
 fi

 # Disable shell meanings of ctrl-s and ctrl-q
 stty stop '' >& /dev/null
 stty start '' >& /dev/null
 
 # Set up utf8 console
 export LC_ALL=en_US.UTF-8
 export LANG=en_US.UTF-8
 export LANGUAGE=en_US.UTF-8
 
 # Make sure the umask is set properly
 # umask 027 (writable only by owner, readable/executable only by group)
 # umask 002 (read-write by owner and group, read/execute by world)
 # umask 007 (read-write by owner and group, no access to others)
 umask 002
 
 # Set up terminal working preferences
 shopt -s histappend
 shopt -s extglob
 set -o vi
 export EDITOR=vim
 export HISTFILE="/opt/.bash_history"
 export HISTFILESIZE=20000
 export HISTSIZE=20000
 export HISTIGNORE="clear:ls:pwd:history:hig:say"
 export HISTTIMEFORMAT='%F %T '

 # Save history after each command, but only if this an interactive shell
 if [ $SHELL_IS_INTERACTIVE -eq 1 ]; then 
     export PROMPT_COMMAND="history -a; history -c; history -r;"
 fi

 # If history file doesn't exist, create it
 touch /opt/.bash_history

 # define some color escape codes
 grey='\[\033[1;30m\]'
 red='\[\033[0;31m\]'
 RED='\[\033[1;31m\]'
 green='\[\033[0;32m\]'
 GREEN='\[\033[1;32m\]'
 yellow='\[\033[0;33m\]'
 YELLOW='\[\033[1;33m\]'
 purple='\[\033[0;35m\]'
 PURPLE='\[\033[1;35m\]'
 white='\[\033[0;37m\]'
 WHITE='\[\033[1;37m\]'
 blue='\[\033[0;34m\]'
 BLUE='\[\033[1;34m\]'
 cyan='\[\033[0;36m\]'
 CYAN='\[\033[1;36m\]'
 NC='\[\033[0m\]'
 
 # Set the prompt
 PS1="$grey[${green}${OS_TYPE}${grey}][$BLUE\t$grey]\$(parse_git_branch)[$cyan \w $grey$grey]$NC\n${PURPLE}λ$NC "

 # set up aliases
 alias less='less -R'
 alias dirs='dirs -v'

 # Put conda on the path
 # export PATH="/opt/conda/bin:$PATH"

 # Only alias the ls command if it doesn't fail
 ls --color=tty >&/dev/null
 if [ $? -eq 0 ]; then
     alias ls=' ls --color=tty' 
 else
     export CLICOLOR=1
     export LSCOLORS=GxFxCxDxBxegedabagaced
 fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
        . "/opt/conda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda activate viz 2>/dev/null || true

# Run any bash_hooks
source_bash_hooks
