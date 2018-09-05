#!/bin/bash

if [[ ! -d ".git" ]]; then
    exit 0
fi

B="\[\e[0;30m\]"    # black
R="\[\e[0;31m\]"    # red
G="\[\e[0;32m\]"    # green
Y="\[\e[0;33m\]"    # yellow
U="\[\e[0;34m\]"    # blue
M="\[\e[0;35m\]"    # magenta
C="\[\e[0;36m\]"    # cyan
W="\[\e[0;37m\]"    # white

BB="\[\e[1;30m\]"   # bold black
BR="\[\e[1;31m\]"   # bold red
BG="\[\e[1;32m\]"   # bold green
BY="\[\e[1;33m\]"   # bold yellow
BU="\[\e[1;34m\]"   # bold blue
BM="\[\e[1;35m\]"   # bold magenta
BC="\[\e[1;36m\]"   # bold cyan
BW="\[\e[1;37m\]"   # bold white

GOLD="\[\e[38;2;220;190;40m\]"      # gold
PURPLE="\[\e[38;2;140;50;160m\]"    # purple
TEAL="\[\e[38;2;10;205;170m\]"      # teal
RESET="\[\e[00m\]"                  # resets the color

replaceSymbols() {
    set -f

    local VALUE=${1//_AHEAD_/${TEAL}↑}
    local VALUE1=${VALUE//_BEHIND_/${GOLD}↓}
    local VALUE2=${VALUE1//_NO_REMOTE_TRACKING_/${BM}L}

    echo ${VALUE2//_PREHASH_/:}

    set +f
}

declare -a git_status_fields=($(./gitstatus.sh 2>/dev/null))

GIT_BRANCH=$(replaceSymbols "${git_status_fields[0]}")
GIT_REMOTE="$(replaceSymbols "${git_status_fields[1]}")"
GIT_UPSTREAM_PRIVATE=${git_status_fields[2]}
GIT_STAGED=${git_status_fields[3]}
GIT_CONFLICTS=${git_status_fields[4]}
GIT_CHANGED=${git_status_fields[5]}
GIT_UNTRACKED=${git_status_fields[6]}
GIT_STASHED=${git_status_fields[7]}
GIT_CLEAN=${git_status_fields[8]}

if [[ ${GIT_REMOTE} = "." ]]; then
    unset GIT_REMOTE
fi

RESULT="${PURPLE}[${GIT_BRANCH}${GIT_REMOTE}${PURPLE}|"

add_status() {
    RESULT="${RESULT}${1}"
}

if [[ ${GIT_STAGED} != 0 ]]; then
    add_status "${Y}•${GIT_STAGED}"
fi

if [[ ${GIT_CONFLICTS} != 0 ]]; then
    add_status "${R}×${GIT_CONFLICTS}"
fi

if [[ ${GIT_CHANGED} != 0 ]]; then
    add_status "${U}₊${GIT_CHANGED}"
fi

if [[ ${GIT_UNTRACKED} != 0 ]]; then
    add_status "${C}…${GIT_UNTRACKED}"
fi

if [[ ${GIT_STASHED} != 0 ]]; then
    add_status "${BU}⚑ ${GIT_STASHED}"
fi

if [[ ${GIT_CLEAN} = 1 ]]; then
    add_status "${G}✓"
fi

RESULT="${RESULT}${PURPLE}]"

echo "${RESULT}${RESET}"
