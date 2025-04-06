#!/bin/bash

# Define options for the checklist
OPTIONS=(
    "1" "Dev tools" ON
    "2" "Glados" ON
    "3" "FuckNetflix" ON
    "4" "ROS2" ON
)

# Run whiptail checklist
CHOICES=$(whiptail --separate-output --title "What do you want to install?" \
    --checklist "Select options:" 15 50 5 \
    "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

INSTALL_DEV_TOOLS=false
INSTALL_GLADOS=false
INSTALL_FUCKNETFLIX=false
INSTALL_ROS2=false

# Display selected options
if [ $? -eq 0 ]; then
    echo "You selected: $CHOICES"
    for CHOICE in $CHOICES; do
        case $CHOICE in
            "1") 
		echo "- Dev tools will be installed"
		INSTALL_DEV_TOOLS=true
		;;
            "2") 
		echo "- Glados will be installed"
		INSTALL_GLADOS=true
		;;
            "3") 
		echo "- FuckNetflix will be installed"
		INSTALL_FUCKNETFLIX=true
		;;
            "4") 
		echo "- ROS2 will be installed"
		INSTALL_ROS2=true
		;;
            *) echo "- Unknown option selected";;
        esac
    done
else
    echo "No selection made."
fi



if [ "$EUID" -ne 0 ]; then
	  echo "Please run this script with sudo privileges"
	    exit 1
fi


PS4='\[\e[32m\]+ ${BASH_SOURCE}:${LINENO}: \[\e[0m\]'

# Add command line debbuging
set -x

# Update package lists
apt update

# Install applications
if $INSTALL_DEV_TOOLS; then
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
	  	brave-browser \
	  	flameshot
	  	#----------------


	# Install PyCharm Community Edition using snap
	snap install pycharm-community --classic
	snap install gitkraken --classic
	snap install bitwarden
	snap install signal-desktop
	sudo snap install code --classic

	SNAP_PATH='export PATH=$PATH:/snap/bin'


	# Add the line to .bashrc if it's not already there
	if ! grep -qF "$SNAP_PATH" "/home/$SUDO_USER/.zshrc"; then
  		echo "$SNAP_PATH" >> "/home/$SUDO_USER/.zshrc"
  		echo "pycharm alias added to .zshrc"
	else
  		echo "Alias already exists in .zshrc"
	fi

	# Install lazygit
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit -D -t /usr/local/bin/
	rm lazigit
	rm lazygit.tar.gz 
	# Add the line to .zshrc if it's not already there
	if ! grep -qF "$SOURCE_TO_ADD" "/home/$SUDO_USER/.zshrc"; then
	  echo "$SOURCE_TO_ADD" >> "/home/$SUDO_USER/.zshrc"
	  echo "ROS2 alias added to .zshrc"
	else
	  echo "ROS2 alias already exists in .zshrc"
	fi


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
	apt install fzf
	

	# Add aliases
	ALIAS_TO_ADD_1='alias pycharm="pycharm-community"'
	ALIAS_TO_ADD_2='alias python="python3"'

	# Add the line to .bashrc if it's not already there
	if ! grep -qF "$ALIAS_TO_ADD_1" "/home/$SUDO_USER/.zshrc"; then
	  echo "$ALIAS_TO_ADD_1" >> "/home/$SUDO_USER/.zshrc"
	  echo "pycharm alias added to .zshrc"
	if ! grep -qF "$ALIAS_TO_ADD_2" "/home/$SUDO_USER/.zshrc"; then
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
fi

# Install ROS2 and dependancies
if $INSTALL_ROS2; then
	apt install -y curl gnupg2 lsb-release software-properties-common
	add-apt-repository universe
	locale-gen en_US en_US.UTF-8
	update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
	export LANG=en_US.UTF-8
	locale
	curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
	apt update && apt install -y ros-dev-tools
	apt -y upgrade
	apt install -y ros-jazzy-desktop
	SOURCE_TO_ADD='source /opt/ros/jazzy/setup.bash'
fi



#Install Glados
if $INSTALL_GLADOS; then
	./glados_installer.sh
fi
# Install FuckNetflix
#if $INSTALL_FUCKNETFLIX; then
#	./fucknetflix_installer.sh
#fi
# Pogo
# Krokocrab
# MangaTranslator

echo "Installation complete!"

# Remove commande line debugging
set +x

