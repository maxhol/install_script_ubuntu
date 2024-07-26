if [ "$EUID" -ne 0 ]; then
	  echo "Please run this script with sudo privileges"
	    exit 1
fi

# Update package lists
apt update

# Install applications
apt install -y \
	  terminator\
	  ncdu

# Install PyCharm Community Edition using snap
snap install pycharm-community --classic


# Add aliases
ALIAS_TO_ADD_1='alias pycharm="pycharm-community"'

# Add the line to .bashrc if it's not already there
if ! grep -qF "$ALIAS_TO_ADD_1" "/home/$SUDO_USER/.bashrc"; then
  echo "$ALIAS_TO_ADD_1" >> "/home/$SUDO_USER/.bashrc"
  echo "Added alias to .bashrc"
else
  echo "Alias already exists in .bashrc"
fi

# Addition to .bashrc
# Command to add to .bashrc
git_prompt='
# Git branch in prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '"'"'/^[^*]/d'"'"' -e '"'"'s/* \(.*\)/ (\\1)/'"'"'
}
PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
'

# Check if .bashrc exists
if [ -f ~/.bashrc ]; then
    # Check if the content already exists in .bashrc
    if grep -qF "export PS1" "/home/$SUDO_USER/.bashrc"; then
        echo "Git branch prompt already exists in .bashrc"
    else
        # Append the content to .bashrc
        echo "$git_prompt" >> "/home/$SUDO_USER/.bashrc"
        echo "Git branch prompt added to .bashrc"
    fi
else
    echo ".bashrc file not found in home directory"
fi

echo "Source .bashrc if you want to see the change or just open a new terminal"
 
echo "Installation complete!"
