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


echo "Installation complete!"
