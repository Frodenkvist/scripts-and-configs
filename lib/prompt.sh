#!/bin/bash

source "$HOME/lib/colors.sh"

prompt_cmd() {
    LAST_STATUS=$?

    if [ ${LAST_STATUS} = 0 ]; then
        PS1="$BG✓ "
    else
        PS1="$BR✘ "
    fi

    PS1+="$C\t$RESET-${debian_chroot:+($debian_chroot)}$G\u$RESET@$BG\h$RESET:$BU\w"
    PS1+="$(git-parser)"
    PS1+="$RESET\$ "
}

PROMPT_COMMAND="prompt_cmd"

