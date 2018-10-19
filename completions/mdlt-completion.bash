#!/usr/bin/env bash

_mdlt_completions() {
    if [ "${#COMP_WORDS[@]}" != "2" ]; then
        return
    fi

    COMPREPLY=($(compgen -W "simplify derive integrate" "${COMP_WORDS[1]}"))
}

complete -F _mdlt_completions mdlt

