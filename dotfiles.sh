#!/bin/bash

whiptail --title "This is the script you are about to install:" --textbox --scrolltext $0 36 90

#set the fucking keyboard, fuck!
sed -i 's/gb/US/g' /etc/default/keyboard

#update
#sudo apt-get update 
#force iv4?
#sudo apt-get -o Acquire::ForceIPv4=true update

sudo apt update

#we aint got all night budy
#sudo apt-get upgrade -y 

#install some apps
sudo apt install -Y xorg xserver-xorg xinit git cmake lxappearance

#my daily apps
sudo apt install -Y feh compton cmatrix nmon chromium-browser geany ranger

#more apps
sudo apt install -Y sysbench florence mixxx nemo ttyrec realvnc-vnc-sever real-vnc-viewer

#this is the install directory for any software we need to build from source
cd /opt/

#installing i3-gaps window manager from source
sudo apt install i3 gcc make dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0 libxcb-shape0-dev
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

#now to get polybar like the rest of the coool kids
#sudo apt install build-essential git cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev
#the dependencies below are marked as optional so try removing them and seeing what happens
#sudo apt install libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev i3-wm libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev
#sudo mkdir ~/Downloads
#cd ~/Downloads/
#sudo wget https://github.com/polybar/polybar/releases/download/3.4.2/polybar-3.4.2.tar
#sudo tar -x -f polybar-3.4.2.tar
#sudo mkdir /opt/polybar/
#sudo mv polybar /opt/
#cd /opt/polybar/
#sudo mkdir build
#cd build/
#sudo cmake ..
#sudo make -j8
#sudo make install
#cd

#gif-for-cli, was looking cute, might delete
#sudo apt install -y python3-pip ffmpeg zlib* libjpeg* python3-setuptools
#pip3 install --user wheel
#pip3 install --user gif-for-cli
#gif-for-cli &

#copy wallpapers
#sudo cp -r Pictures ~/
sudo mkdir ~/Pictures
sudo mkdir ~/Pictures/Wallpapers
cd ~/Pictures/Wallpapers
sudo wget http://getwallpapers.com/wallpaper/full/2/2/3/702223-free-rainforest-backgrounds-2560x1440.jpg
sudo wget http://getwallpapers.com/wallpaper/full/9/d/6/702176-rainforest-backgrounds-1920x1080-for-mac.jpg
sudo wget http://getwallpapers.com/wallpaper/full/8/0/e/702147-rainforest-backgrounds-2560x1600-images.jpg
sudo wget http://getwallpapers.com/wallpaper/full/e/8/7/702136-rainforest-backgrounds-1920x1080-for-mobile.jpg
sudo wget http://getwallpapers.com/wallpaper/full/a/6/e/702131-beautiful-rainforest-backgrounds-1920x1080-for-iphone-6.jpg
sudo wget http://getwallpapers.com/wallpaper/full/a/a/9/702126-rainforest-backgrounds-2560x1600-for-computer.jpg



#sudo reboot

#just a little section to layout my thougts on this config.
#
#use more whiptial
#	- ask for keyword for system theme (background, motd, colors?)
#	- ask for username (getting encrypted home directory)
#fix localization (keyboard, timezone, wifi)
#create new user (not "pi") with encrypted file system (https://technicalustad.com/how-to-encrypt-raspberry-pi-home-folder/)
#make polybar show temp/cpu/ram/
#fetch backgrounds based on keyword
#
#I want this pi to have as many use-cases as possible. 
#-provide hotspot if plugged into ethernet internet connection
#-provide ethernet networking if connected to wfif
#-provide filesharing in both use-cases
#-provide vnc desktop
#/#

#copy "dotfiles" into place
sudo cp -r .config/ ~/

raspi-config nonint do_ssh 0
raspi-config nonint do_vnc 0
raspi-config nonint do_wifi_country US
#clear