#!/bin/bash

source "$HOME/lib/colors.sh"

prompt_cmd() {
    LAST_STATUS=$?
    PS1="${debian_chroot:+($debian_chroot)}$G\u@$BG\h$RESET:$BU\w"
    PS1+="$(git-parser)"
    PS1+="$RESET\$ "
}

PROMPT_COMMAND="prompt_cmd"

