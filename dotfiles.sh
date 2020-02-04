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

#install some apps
sudo apt install -y xorg xserver-xorg xinit git cmake lxappearance

#my daily apps
sudo apt install -y i3blocks feh compton cmatrix nmon geany ranger

#more apps
sudo apt install -y sysbench florence mixxx nemo ttyrec realvnc-vnc-sever real-vnc-viewer

###Setup New Encrypted User#################################################################################################

#install apps needed to encrypt the user folder
sudo apt install -y ecryptfs-utils lsof cryptsetup

#encrypt new user home directory
sudo ecryptfs-migrate-home -u $USER

#add new user to sudoers group
sudo usermod -a -G sudo $USER

#add user to all the groups that user pi was a part of
sudo usermod -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio,$USER $USER

###Install the desktop environment##########################################################################################

#set the fucking keyboard, fuck!
sed -i 's/gb/US/g' /etc/default/keyboard

#enable  shh, vnc, set WiFi
raspi-config nonint do_ssh 0
raspi-config nonint do_vnc 0
raspi-config nonint do_wifi_country US

#copy "dotfiles" into place
sudo cp -r .config/ /home/$USER/

#this is the install directory for any software we need to build from source
cd /opt/ 

#installing i3-gaps window manager from source
sudo apt install -y i3 gcc make dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0 libxcb-shape0-dev
sudo git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps
sudo autoreconf --force --install
sudo rm -rf build/
sudo mkdir -p build 
cd build/
sudo ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
sudo make -j8
sudo make install
cd

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
#	- ask for keyword for system theme (background, motd, colors?)
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
#fix permissions: sudo chmod 0750 -R /home/bob/*
#set new root password: sudo passwd root
#delete pi user :sudo userdel --remove-all-files pi
#List groups wich pi is belonging: sudo cat/etc/group | grep pi

#delete pi user?
#sudo pkill -u pi
#sudo deluser pi
#sudo apt install --yes chromium-browser