#!/usr/bin/env bash
###############################################################################%

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
shopt -s histappend
shopt -s checkwinsize

HISTFILE="$XDG_STATE_HOME/.bash_history"   # History filepath
HISTSIZE=100000                            # Max lines for internal history
SAVEHIST=100000                            # Max lines in history file
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups
LESSHISTFILE="$HOME/CACHE/less/history"
GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    _OS=linux
    ;;
  darwin*)
    _OS=macos
    ;;
  msys*)
    _OS=windows
    ;;
  *)
    _OS=notset
    ;;
esac

##### Aliases #####

# ls, file-ops and movement
if [[ "$(command -v eza)" != '' ]]; then
    EZA_OPTIONS=(
        -F
        --group-directories-first
        -I='Library|Downloads|Desktop|Movies|Music|Pictures|.DS_Store|__pycache__|.pytest_cache'
        --no-time
                -s=name
                --color=always
                --icons=never
        )
    alias l='eza -TF -L=2 ${EZA_OPTIONS[@]}'
    alias ll='eza -aFlTh -L=2 ${EZA_OPTIONS[@]}'
    alias lll='eza -aFlTh -L=4 ${EZA_OPTIONS[@]}'
    cdls() {
        cd "$@" || return;
        clear
        eza -F "${EZA_OPTIONS[@]}"
        echo
    }
elif [[ "$(command -v exa)" != '' ]]; then
    EXA_OPTIONS=(
        --classify
        --color=always
        --color-scale
        --no-icons
        --sort=name
        --group-directories-first
    )
    alias l='exa ${EXA_OPTIONS[@]}'
    alias ll='exa -a --tree --level=2 ${EXA_OPTIONS[@]}'
    alias lll='exa -a --tree --level=3 --long ${EXA_OPTIONS[@]}'
    cdls() {
        cd "$@" || return;
        clear
        exa "${EXA_OPTIONS[@]}"
        echo
    }
else
    alias l='ls -hF --color=always'
    alias la='ls -ahF --color=always'
    alias ll='ls -lhAF --color=always'
    cdls() {
      cd "$@" && ls -hF --color=always
    }
fi
alias cd=cdls
alias cdbin='cd $EXEC_DIR'
alias lsbin='ls -lAhF --color=always $EXEC_DIR'

# git
alias gc='git clone'
alias ga="git add ."

# network and comms
alias ping='c; ping -c 5 '
alias p8="c; ping -c 5 8.8.8.8"
#alias pubkey="pbcopy < ~/.ssh/id_rsa.pub && echo \"Public key copied to pasteboard.\""
#alias fssh='fast-ssh'

# docker
alias dils='docker image ls'
alias dcls='docker container ls'
alias dpsa='docker ps -a'
if [ -e "${DOCKER_FILE_DIR}" ]; then
    alias dcup='docker compose -f ${DOCKER_FILE_DIR}/docker-compose.yml up -d'
    alias dcdn='docker compose -f ${DOCKER_FILE_DIR}/docker-compose.yml stop'
    alias dcpull='docker compose -f ${DOCKER_FILE_DIR}/docker-compose.yml pull'
    alias dclogs='docker compose -f ${DOCKER_FILE_DIR}/docker-compose.yml logs -tf --tail=50'
    alias dtail='docker logs -tf --tail=50'
fi

# misc
alias ss="sudo "
alias c="clear"
alias edit='micro'
alias cb='$EDITOR ${HOME}/.bashrc'
alias sb='. ${HOME}/.bashrc'



##### Path #####

declare -a paths

_pathstring=''

function _build_path() {

    paths_macos=( "/nix/var/nix/profiles/default/bin"
                         "${PKG_MANAGER_PREFIX}/sbin"
                          "${PKG_MANAGER_PREFIX}/bin"
                              "$HOME/.gem/ruby/2.6.0"
                                "$HOME/.local/go/bin"
                                       "$HOME/.cargo/bin"
                                   "$HOME/.local/bin"
                                    "/usr/local/sbin"
                                     "/usr/local/bin"
                                          "/usr/sbin"
                                           "/usr/bin"
                                              "/sbin"
                                               "/bin" )

    paths_linux=( "$HOME/.local/bin"
                   "/usr/local/sbin"
                    "/usr/local/bin"
                         "/usr/sbin"
                          "/usr/bin"
                             "/sbin"
                              "/bin" )


    [ "${1}" == macos ] && paths=( "${paths_macos[@]}" )
    [ "${1}" == linux ] && paths=( "${paths_linux[@]}" )


    for d in "${paths[@]}"; do
        if [ "${_pathstring}" == '' ]; then
            _pathstring="${d}"
            continue
        else
            _pathstring="${_pathstring}:${d}"
        fi
    done

    export PATH="${_pathstring}"

}


if [ "$_OS" == macos ]; then
    _build_path macos
elif [ "$_OS" == linux ]; then
    _build_path linux
else
    echo "OS not supported"
fi


##### Theme #####
PS1=$'\n\\[\\e[91m\\]\\[\\e[97;101m\\] @ \\[\\e[0;48;5;238m\\] \\u@\\h \\[\\e[37;47m\\]\\[\\e[38;5;236m\\] \\w \\[\\e[0;37m\\] \\$ \\[\\e[0m\\] '
