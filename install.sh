#!/bin/bash

fail() {
    echo "ERROR: $1"
    exit 1
}

SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

PROFILE=""
if [ -f "$HOME/.profile" ]; then
    PROFILE="$HOME/.profile"
elif [ -f "$HOME/.bash_profile" ]; then
    PROFILE="$HOME/.bash_profile"
else
    fail "Unable to find profile file!"
fi

# checking home variable
if [[ -z ${HOME} ]]; then
    fail "The HOME variable has to be set!"
fi

# install p4merge
echo "Installing p4merge..."
[ -f "$HOME/bin/p4merge" ] && rm -rf "$HOME/bin/p4merge"
ln -s "$SCRIPT_PATH/dist/p4v/bin/p4merge" "$HOME/bin/p4merge"

# install post-merge hook
echo "Installing post-merge hook..."
[ -f "$SCRIPT_PATH/.git/hooks/post-merge" ] && rm -rf "$SCRIPT_PATH/.git/hooks/post-merge"
ln -s "../../post-merge" "$SCRIPT_PATH/.git/hooks/post-merge"

# install gitconfig
echo "Installing gitconfig..."
[ -f "$HOME/.gitconfig" ] && rm -rf "$HOME/.gitconfig"
ln -s "$SCRIPT_PATH/config/gitconfig" "$HOME/.gitconfig"

# install vimrc
echo "Installing vimrc..."
[ -f "$HOME/.vimrc" ] && rm -rf "$HOME/.vimrc"
ln -s "$SCRIPT_PATH/config/vimrc" "$HOME/.vimrc"

# create bin folder if not exists
if [ ! -d "$HOME/bin" ]; then
    echo "Creating bin directory"
    mkdir "$HOME/bin"
fi

# add bin to path if not there
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$PROFILE"; then
    echo "Adding $HOME/bin to PATH"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$PROFILE"
    source "$HOME/.profile"
fi

# create lib folder if not exists
if [ ! -d "$HOME/lib" ]; then
    echo "Creating lib directory"
    mkdir "$HOME/lib"
fi

# install colors.sh
echo "Installing colors.sh..."
[ -f "$HOME/lib/colors.sh" ] && rm -rf "$HOME/lib/colors.sh"
ln -s "$SCRIPT_PATH/lib/colors.sh" "$HOME/lib/colors.sh"

# install gitstatus
echo "Installing gitstatus..."
[ -f "$HOME/lib/gitstatus" ] && rm -rf "$HOME/lib/gitstatus"
ln -s "$SCRIPT_PATH/lib/gitstatus" "$HOME/lib/gitstatus"

# install git-parser
echo "Installing git-parser..."
[ -f "$HOME/bin/git-parser" ] && rm -rf "$HOME/bin/git-parser"
ln -s "$SCRIPT_PATH/bin/git-parser" "$HOME/bin/git-parser"

# install prompt.sh
echo "Installing prompt.sh..."
[ -f "$HOME/lib/prompt.sh" ] && rm -rf "$HOME/lib/prompt.sh"
ln -s "$SCRIPT_PATH/lib/prompt.sh" "$HOME/lib/prompt.sh"

# Adding prompt to bashrc if not there
if ! grep -q 'source "$HOME/lib/prompt.sh"' "$HOME/.bashrc"; then
    echo "Installing prompt in .bashrc"
    echo 'source "$HOME/lib/prompt.sh"' >> "$HOME/.bashrc"
    source "$PROFILE"
fi

echo "Installation complete!"

