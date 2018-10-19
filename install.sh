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
if ! grep -q 'export PATH="$PATH:$HOME/bin"' "$PROFILE"; then
    echo "Adding $HOME/bin to PATH"
    echo 'export PATH="$PATH:$HOME/bin"' >> "$PROFILE"
    source "$PROFILE"
fi

# create lib folder if not exists
if [ ! -d "$HOME/lib" ]; then
    echo "Creating lib directory"
    mkdir "$HOME/lib"
fi

# install scripts
for file_path in $SCRIPT_PATH/bin/*; do
    FILE=$(basename $file_path)
    echo "Installing ${FILE}..."
    [ -f "$HOME/bin/$FILE" ] && rm -rf "$HOME/bin/$FILE"
    ln -s "$file_path" "$HOME/bin/$FILE"
done

# install colors.sh
echo "Installing colors.sh..."
[ -f "$HOME/lib/colors.sh" ] && rm -rf "$HOME/lib/colors.sh"
ln -s "$SCRIPT_PATH/lib/colors.sh" "$HOME/lib/colors.sh"

# install gitstatus
echo "Installing gitstatus..."
[ -f "$HOME/lib/gitstatus" ] && rm -rf "$HOME/lib/gitstatus"
ln -s "$SCRIPT_PATH/lib/gitstatus" "$HOME/lib/gitstatus"

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

# Installing completion scripts
for file_path in $SCRIPT_PATH/completions/*; do
    FILE=$(basename $file_path)
    echo "Installing ${FILE}..."
    [ -f "/etc/bash_completion.d/$FILE" ] && sudo rm -rf "/etc/bash_completion.d/$FILE"
    sudo ln -s "$file_path" "/etc/bash_completion.d/$FILE"
    source $file_path
done

echo "Installation complete!"

