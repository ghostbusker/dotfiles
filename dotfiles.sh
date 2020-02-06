#!/bin/bash

whiptail --title "This is the script you are about to install:" --textbox --scrolltext $0 36 90

#Create new username and password
USER=username
USER=$(whiptail --inputbox "Enter new user name. User 'pi' should be deleted for security reasons. No spaces please." 8 78 $USER --title "New User Name" 3>&1 1>&2 2>&3)
sudo adduser $USER

#update 
#force iv4?
#sudo apt-get -o Acquire::ForceIPv4=true update
sudo apt update

#install some apps needed to make UI
sudo apt install -y xorg xserver-xorg xinit git cmake lxappearance

#install apps that will be part of desktop composition
sudo apt install -y i3blocks feh compton clipit arandr mplayer

#termnial upgrade + terminal candy)
sudo apt install -y terminator lolcat figlet cmatrix hollywood libaa-bin thefuck howdoi

#system utilities and monitors
sudo apt install -y	nmon conky htop sysbench

#file browsers
sudo apt install -y ranger nemo

#MEDIA apps
sudo apt install -y cmus vis playerctl mixxx

###Setup New Encrypted User#################################################################################################

#install apps needed to encrypt the user folder
sudo apt install -y ecryptfs-utils lsof cryptsetup

#encrypt new user home directory
sudo ecryptfs-migrate-home -u $USER

#copy "dotfiles" into place
sudo cp -r .config/ /home/$USER/

#add new user to sudoers group
sudo usermod -a -G sudo $USER

#add user to all the groups that user pi was a part of
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio, $USER

#this next part made all the difference, chome and a bunch of other apps were broken otherwise
#take ownership and set permissions of user folder:
sudo -u $USER chmod 750 -R /home/$USER/
sudo chown -R $USER:$USER /home/$USER/

###Install the desktop environment##########################################################################################

#set the ducking keyboard, duck!
sed -i 's/gb/us/g' /etc/default/keyboard

#enable  shh, vnc, set WiFi
raspi-config nonint do_ssh 0
raspi-config nonint do_vnc 0
raspi-config nonint do_wifi_country US


#this is the install directory for any software we need to build from source
cd /opt/ 

#installing i3-gaps window manager from source
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

cd /opt/

#install cool-retro-term {the cool-ness CANNOT be overstated}
sudo apt install build-essential qmlscene qt5-qmake qt5-default qtdeclarative5-dev qml-module-qtquick-controls qml-module-qtgraphicaleffects qml-module-qtquick-dialogs qml-module-qtquick-localstorage qml-module-qtquick-window2 qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel
git clone --recursive https://github.com/Swordfish90/cool-retro-term.git
cd cool-retro-term
qmake && make
#done installing cool-retro-term


#copy wallpapers
sudo mkdir /home/$USER/Pictures
sudo mkdir /home/$USER/Pictures/Wallpapers
cd /home/$USER/Pictures/Wallpapers
sudo wget http://getwallpapers.com/wallpaper/full/2/2/3/702223-free-rainforest-backgrounds-2560x1440.jpg
sudo wget http://getwallpapers.com/wallpaper/full/9/d/6/702176-rainforest-backgrounds-1920x1080-for-mac.jpg
sudo wget http://getwallpapers.com/wallpaper/full/8/0/e/702147-rainforest-backgrounds-2560x1600-images.jpg
sudo wget http://getwallpapers.com/wallpaper/full/e/8/7/702136-rainforest-backgrounds-1920x1080-for-mobile.jpg
sudo wget http://getwallpapers.com/wallpaper/full/a/6/e/702131-beautiful-rainforest-backgrounds-1920x1080-for-iphone-6.jpg
sudo wget http://getwallpapers.com/wallpaper/full/a/a/9/702126-rainforest-backgrounds-2560x1600-for-computer.jpg

#clear?
#sudo reboot?

#just a little section to layout my thougts on this config.
# try putting 'pi' as the new user name and see if anything breaks, or if the home folder gets encrypted
# try putting in a username with a space as well, i bet it breaks things
#use more whiptial
#ask for keyword for system theme (background, motd, colors?)
#fix localization (keyboard, timezone, wifi), current solution is insufficient 
#create new user (not "pi") with encrypted file system (https://technicalustad.com/how-to-encrypt-raspberry-pi-home-folder/)
#make i3bar show temp/cpu/ram/ the way i want
#fetch backgrounds based on keyword
#
#I want this pi to have as many use-cases as possible. 
#-provide hotspot if plugged into ethernet internet connection
#-provide ethernet networking if connected to wfif
#-provide filesharing in both use-cases
#-provide vnc desktop
#

#NEW USER STUFF 
#show encryption password with command: ecryptfs-unwrap-passphrase
#show backup of home folder with command: $USER. zyxxc: ls /home
#then remove backed up home folder with: sudo rm -r -f $FOLDERNAMEGOESHERE
#Disable Swap with : sudo swapoff -a -v
#breaks all permissions somehow?!?: sudo chmod 0750 -R /home/newuser/*
#set new root password: sudo passwd root
#delete pi user :sudo userdel --remove-all-files pi
#List groups wich pi is belonging: sudo cat/etc/group | grep pi
#Update list of default apps (terminal, browser, etc.): update-alternatives --all
#/etc/skel is the skeleton user, all new users get their home dir guts copied from right here
#consider making this an option in the menu

#delete pi user?
#sudo pkill -u pi
#sudo deluser pi

#AFTER LOGGIN IN AS NEW USER / RUN-FIRST SCRIPT FOR NEW USER
#make a user config folder for chrome to use
#sudo mkdir /home/$USER/.config/chromium/
#to make chromium work use command:
#chromium-browser --user-data-dir=~/.config/chromium

#more apps
sudo apt install -y screenkey ttyrec realvnc-vnc-server realvnc-vnc-viewer chromium-browser
