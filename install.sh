#!/bin/bash

fail() {
    echo "ERROR: $1"
    exit 1
}

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [[ -z ${HOME} ]]; then
    fail "The HOME variable has to be set!"
fi

INPUT="Y"

# install gitconfig
if [ -f "${SCRIPT_PATH}/gitconfig" ]; then
    echo "Installing gitconfig..."
    if [ -f "$HOME/.gitconfig" ]; then
        echo ".gitconfig already exists. Would you like to replace it? (Y/N)"
        read INPUT
    fi
    
    if [ ${INPUT} = "y" -o ${INPUT} = "Y" ]; then
        [ -f "$HOME/.gitconfig" ] && rm -rf "$HOME/.gitconfig"
        ln -s "$SCRIPT_PATH/gitconfig" "$HOME/.gitconfig"
    fi
else
    echo "Unable to find gitconfig in ${SCRIPT_PATH}"
fi

INPUT="Y"

# install vimrc
if [ -f "${SCRIPT_PATH}/vimrc" ]; then
    echo "Installing vimrc..."
    if [ -f "$HOME/.vimrc" ]; then
        echo ".vimrc already exists. Would you like to replace it? (Y/N)"
        read INPUT
    fi
    
    if [ ${INPUT} = "y" -o ${INPUT} = "Y" ]; then
        [ -f "$HOME/.vimrc" ] && rm -rf "$HOME/.vimrc"
        ln -s "$SCRIPT_PATH/vimrc" "$HOME/.vimrc"
    fi
else
    echo "Unable to find gitconfig in ${SCRIPT_PATH}"
fi

