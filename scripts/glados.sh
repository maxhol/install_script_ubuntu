#todo

# Install depedencies
apt update

apt install -y \
	#espeak <- not sure if needed, uncomment if libespeak.so.1: cannot open shared object file: No such file or directory
	alsa-utils \
	pulseaudio \
	ffmpeg
