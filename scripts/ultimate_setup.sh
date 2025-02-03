if [ "$EUID" -ne 0 ]; then
	  echo "Please run this script with sudo privileges"
	    exit 1
fi

# Update package lists
apt update

# Install applications
apt install -y \
	  terminator \
	  ncdu \
	  gitk \
	  nvtop \
	  nautilus \
	  zsh \
	  alsa-topology-conf \
	  alsa-ucm-conf \
	 # libasound2 \
	  libasound2-data \
	  libgbm1 \
	  libwayland-server0 \
	  cmake \
	  python3-pip \
	  sudo apt install brave-browser
	  flameshot
	  #----------------


# Install PyCharm Community Edition using snap
snap install pycharm-community --classic
snap install gitkraken --classic
snap install bitwarden

# Make zsh default shell 
# Get the path to Zsh
ZSH_PATH=$(which zsh)

# Check if Zsh is in /etc/shells
if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "Adding Zsh to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

# Change the default shell to Zsh
if sudo -u $SUDO_USER chsh -s "$ZSH_PATH"; then
    echo "Default shell changed to Zsh. Please log out and log back in for the changes to take effect."
else
    echo "Failed to change the default shell. Please try again or change it manually."
    exit 1
fi


# Install Oh-my-zsh
sudo -u $SUDO_USER sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended


# Add aliases
ALIAS_TO_ADD_1='alias pycharm="pycharm-community"'
ALIAS_TO_ADD_2='alias python="python3"'

# Add the line to .bashrc if it's not already there
if ! grep -qF "$ALIAS_TO_ADD_1" "/home/$SUDO_USER/.zshrc"; then
  echo "$ALIAS_TO_ADD_1" >> "/home/$SUDO_USER/.zshrc"
  echo "pycharm alias added to .bashrc"
elif ! grep -qF "$ALIAS_TO_ADD_2" "/home/$SUDO_USER/.zshrc"; then
  echo "$ALIAS_TO_ADD_2" >> "/home/$SUDO_USER/.zshrc"
  echo "python alias added to .zshrc"
else
  echo "Alias already exists in .zshrc"
fi

# Set zsh prompt config
ADD_PROMPT='#export PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)"'

if ! grep -qF "PROMPT" "/home/$SUDO_USER/.zshrc"; then
  echo "$ADD_PROMPT" >> "/home/$SUDO_USER/.zshrc"
  echo "Prompt config added to .zshrc"
else
  echo "Prompt config already in .zshrc"
fi


echo "Source .zshrc if you want to see the change or just open a new terminal"

# Add terminator config 
mkdir -p "/home/$SUDO_USER/.config/terminator/"
cp "$PWD/../resources/terminator/trees.jpg" "/home/$SUDO_USER/.config/terminator/"
cp "$PWD/../resources/terminator/config" "/home/$SUDO_USER/.config/terminator/"
chown -R $USER:$USER ~/.config/

# Set git config
git config --global user.email "maxhol@hotmail.fr"
git config --global user.name "Max"


#Because of a bug in oh-my-zsh: https://github.com/ohmyzsh/ohmyzsh/issues/12328


escape_sed() {
    echo "$1" | sed -e 's/[]\/$*.^[]/\\&/g'
}

TARGET_FILE="/home/$SUDO_USER/.oh-my-zsh/themes/robbyrussell.zsh-theme"
SEARCH_LINE='PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%}"'
REPLACE_LINE='PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%~%{$reset_color%}"'

ESCAPED_SEARCH_LINE=$(escape_sed "$SEARCH_LINE")
ESCAPED_REPLACE_LINE=$(escape_sed "$REPLACE_LINE")

if [ ! -f "$TARGET_FILE" ]; then
  echo "File not found!"
  exit 1
fi

sed -i "s/^$ESCAPED_SEARCH_LINE$/$ESCAPED_REPLACE_LINE/" "$TARGET_FILE"

echo "Installation complete!"
