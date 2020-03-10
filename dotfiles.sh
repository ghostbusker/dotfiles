#!/bin/bash

#check for "--help" or "-h" flags
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]
then
  printf -- 'there is no help.\n'
  sleep 3
  printf -- 'only zuul.\n'
  exit 0
fi

#set whiptail colors
export NEWT_COLORS='
window=,red
border=white,red
textbox=white,red
button=black,white
'
#inform user and prompt for consent
whiptail --title "This is the script you are about to install:" --textbox --scrolltext $0 20 78

#let user choose which modules to run
NAME=$(whiptail --title "Choose your own adventure" --checklist --separate-output \
  "Modules:" 20 30 15 \
  "mod1" "New Encrypted User" on \
  "mod2" "Copy Dotfiles to Home Directory" on \
  "mod3" "Take Ownership of Home Directory" on \
  "mod4" "Becky" off \
  "mod5" "Cheryl" off \
  "mod6" "Michelle" off \
  3>&1 1>&2 2>&3)

#backup then temporarily change terminal colors
TEMP1=$PS1
TEMP2=$PS2
TEMP2=$PS3
export PS1="\e[0;32m\]"
export PS2="\e[0;31m\]"
export PS3="\e[0;35m\]"

#enable colored output for git
sudo git config --global color.ui auto

#update package list, force use of IPv4 if failure to connect
sudo apt update || sudo apt-get -o Acquire::ForceIPv4=true update

###Setup New Encrypted User#################################################################################################

!
#Create new username
USER=username
USER=$(whiptail --inputbox "Enter new user name. User 'pi' should be deleted for security reasons. No spaces please." 8 78 $USER --title "New User Name" 3>&1 1>&2 2>&3)

#create new user and add them to the sudo group, prompts for a new password
sudo adduser $USER
sudo usermod -a -G sudo $USER

#starting script timer
sudo printf -- 'Starting script timer...\n'
STOPWATCH=0

#install apps needed to encrypt the user folder
sudo apt install -y ecryptfs-utils lsof cryptsetup

#encrypt new user home directory
sudo ecryptfs-migrate-home -u $USER

#show encryption password with command: ecryptfs-unwrap-passphrase

!
#copy "dotfiles" into place
sudo cp -r .config/ /home/$USER/
sudo cp -r .bashrc /home/$USER/

!
#this next part made all the difference, chome and a bunch of other apps were broken otherwise
#take ownership and set permissions of user folder:
sudo -u $USER chmod 750 -R /home/$USER/
sudo chown -R $USER:$USER /home/$USER/
sudo umask 0027

!
#######INSTALL DEFAULT TERMINAL ENVIRONMENT################################
#termnial upgrade + terminal candy)
sudo apt install -y terminator locate tilda neovim ranger trash-cli neofetch figlet lolcat cmatrix hollywood caca-utils libaa-bin thefuck howdoi cowsay fortune

#system utilities and monitors
sudo apt install -y	glances nmon htop

#MEDIA apps
sudo apt install -y cmus vis playerctl vlc


!
###Install the desktop environment##########################################################################################
#install some apps needed to make UI
sudo apt install -y xorg xserver-xorg xinit git cmake lxappearance

#installing i3-gaps window manager from source
cd /opt/ 
sudo apt install -y i3 gcc make autoconf dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0 libxcb-shape0-dev
sudo git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps
sudo autoreconf --force --install
sudo rm -rf build/
sudo mkdir -p build 
cd build/
sudo ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
sudo make -j8
sudo make install
#done installing i3-gaps

#install apps that will be part of desktop composition and daily apps
sudo apt install -y i3blocks feh compton clipit arandr mpv florence nemo conky

#more common apps
sudo apt install -y screenkey ttyrec realvnc-vnc-server realvnc-vnc-viewer chromium-browser

#install productivity apps
sudo apt install -y geany neovim



!
#############copy wallpapers####################
sudo mkdir /home/$USER/Pictures
sudo mkdir /home/$USER/Pictures/Wallpapers
cd /home/$USER/Pictures/Wallpapers
sudo wget http://getwallpapers.com/wallpaper/full/2/2/3/702223-free-rainforest-backgrounds-2560x1440.jpg
sudo wget http://getwallpapers.com/wallpaper/full/9/d/6/702176-rainforest-backgrounds-1920x1080-for-mac.jpg
sudo wget http://getwallpapers.com/wallpaper/full/8/0/e/702147-rainforest-backgrounds-2560x1600-images.jpg
sudo wget http://getwallpapers.com/wallpaper/full/e/8/7/702136-rainforest-backgrounds-1920x1080-for-mobile.jpg
sudo wget http://getwallpapers.com/wallpaper/full/a/6/e/702131-beautiful-rainforest-backgrounds-1920x1080-for-iphone-6.jpg
sudo wget http://getwallpapers.com/wallpaper/full/a/a/9/702126-rainforest-backgrounds-2560x1600-for-computer.jpg

!
##############make common folders################
sudo mkdir /home/$USER/Documents
sudo mkdir /home/$USER/Downloads
sudo mkdir /home/$USER/Music
sudo mkdir /home/$USER/Videos


#just a little section to layout my thougts on this config.
# try putting 'pi' as the new user name and see if anything breaks, or if the home folder gets encrypted
# try putting in a username with a space as well, i bet it breaks things
#use more whiptial
#ask for keyword for system theme (background, motd, colors?)
#fix localization (keyboard, timezone, wifi), current solution is insufficient 
#create new user (not "pi") with encrypted file system (https://technicalustad.com/how-to-encrypt-raspberry-pi-home-folder/)
#fetch backgrounds based on keyword

#I want this pi to have as many use-cases as possible. 
#-provide wifi hotspot if plugged into internet via ethernet
#-provide internet via ethernet port if connected to wifi
#-provide filesharing in both use-cases
#-provide vnc desktop for access via phone/tablet/laptop/fredidgerator

#new user first login script?
#Update list of default apps (terminal, browser, etc.): update-alternatives --all
#delete pi user?
#sudo pkill -u pi
#sudo userdel --remove-all-files pi

#maybe try the following line to intsall apps 1 by 1 for testing
#for i in package1 package2 package3; do sudo apt-get install -y $i; done

#view cpu scaling freq:
#cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 

!
###########################OpenVPN Setup####################
#This is where we install OpenVPN for tunneling back "home"
sudo apt install -y openvpn
#runs with: sudo openvpn ~./location/of/ovpn-file.ovpn
#launched by i3, see ~/.config/i3/config

##############Raspberry Pi specific stuff##################
!
#add user to all the groups that user pi was a part of
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio $USER

!
#add GPIO pin3 shutdown to /boot/config.txt AND enable UART so that phisical GPIO pin 8 acts as power LED 
sudo sed -i '$a dtoverlay=gpio-shutdown,gpio_pin=3,active_low=1,gpio_pull=up\nenable_uart=1\' /boot/config.txt

!
#set the ducking keyboard, duck!
sudo sed -i 's/gb/us/g' /etc/default/keyboard

#this is getting kind of personal
sudo timedatectl set-timezone US/Eastern
#Alternatively use command: sudo dpkg-reconfigure tzdat

!
#enable  shh, vnc, WiFi, bluetooth
sudo raspi-config nonint do_ssh 0
sudo raspi-config nonint do_vnc 0
sudo raspi-config nonint do_wifi_country US
sudo apt install -y pi-bluetooth blueman dhcpcd-gtk bluealsa network-manager wpagui
sudo apt install -y nmap macchanger wireshark

#for stress testing
sudo apt install -y stress sysbench

############OPTIONAL SOFTWARES LIST##########################

!
#install retropie
cd /opt/
sudo git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
sudo ./retropie_setup.sh
#done installing retropie



#this is not working, consider removing?
#did this earlier in the install but need to run again late to make Wallpapers folder belong to new user
#take ownership and set permissions of user folder:
#sudo -u $USER chmod 750 -R /home/$USER/
#sudo chown -R $USER:$USER /home/$USER/
#sudo umask 0027

#credit where credit is due
#wget -O /home/$USER/.conkyrc https://raw.githubusercontent.com/novaspirit/rpi_conky/master/rpi3_conkyrc

#change swap file from 100mb to something bigger, need to make this optional
sudo sed -i 's/^CONF_SWAPSIZE=[0-9]*$/CONF_SWAPSIZE=512/' /etc/dphys-swapfile
sudo dphys-swapfile setup
#Andreas Speiss recomends these swap file changes
#sudo sed -i '/CONF_SWAPFILE/c\CONF_SWAPFILE=/var/swap' /etc/dphys-swapfile 
#sudo sed -i '/CONF_SWAPFACTOR/c\CONF_SWAPFACTOR=2' /etc/dphys-swapfile 
#sudo sed -i '/CONF_SWAPSIZE/c\#CONF_SWAPSIZE=100' /etc/dphys-swapfile 
#sudo dphys-swapfile setup
#sudo dphys-swapfile swapon

#Alternatively... Disable Swap 
#sudo swapoff -a -v

#install Log2Ram for raspi, must be done last and requires reboot
printf -- 'deb http://packages.azlux.fr/debian/ buster main'| sudo tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
apt update
apt install log2ram

#######Script finished, show some helpful info ##############

#show overclock and overlay info from /boot/config.txt
printf -- 'Current /boot/config.txt settings:\n'
vcgencmd get_config int

#show codec info
for codec in H264 MPG2 WVC1 MPG4 MJPG WMV9 ; do \
	printf -- '$codec:\t$(vcgencmd codec_enabled $codec)' ; \
done

#ta ta fa na
printf -- 'install complete\n' | lolcat
printf -- 'reboot and login as new user\n' | lolcat

#print script elapsed runtime
ELAPSED="Elapsed: $(($STOPWATCH / 3600))hrs $((($STOPWATCH / 60) % 60))min $(($STOPWATCH % 60))sec"
printf -- '$ELAPSED\n' | lolcat

#return terminal colors to normal
PS1=$TEMP1
PS2=$TEMP2
PS3=$TEMP3
#alternatley/additionally, reload bash?
bash

exit 0
