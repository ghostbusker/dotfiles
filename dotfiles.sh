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

#more apps
sudo apt install -y screenkey ttyrec realvnc-vnc-server realvnc-vnc-viewer chromium-browser

###Setup New Encrypted User#################################################################################################

#install apps needed to encrypt the user folder
sudo apt install -y ecryptfs-utils lsof cryptsetup

#encrypt new user home directory
sudo ecryptfs-migrate-home -u $USER

#show encryption password with command: 
#ecryptfs-unwrap-passphrase

#copy "dotfiles" into place
sudo cp -r .config/ /home/$USER/
sudo cp -r .bashrc /home/$USER/
sudo cp -r .profile /home/$USER/

#add new user to sudoers group
sudo usermod -a -G sudo $USER

#add user to all the groups that user pi was a part of
sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio $USER

#this next part made all the difference, chome and a bunch of other apps were broken otherwise
#take ownership and set permissions of user folder:
sudo -u $USER chmod 750 -R /home/$USER/
sudo chown -R $USER:$USER /home/$USER/

#set new root password?
#sudo passwd root

#/etc/skel is the skeleton user, all new users get their home dir from here

#Andreas Speiss recomends these swap file changes
#sudo sed -i '/CONF_SWAPFILE/c\CONF_SWAPFILE=/var/swap' /etc/dphys-swapfile 
#sudo sed -i '/CONF_SWAPFACTOR/c\CONF_SWAPFACTOR=2' /etc/dphys-swapfile 
#sudo sed -i '/CONF_SWAPSIZE/c\#CONF_SWAPSIZE=100' /etc/dphys-swapfile 
#sudo dphys-swapfile setup
#sudo dphys-swapfile swapon

#Alternatively... Disable Swap 
sudo swapoff -a -v

#add GPIO pin3 shutdown to /boot/config.txt
sudo sed -i '$a dtoverlay=gpio-shutdown,gpio_pin=3,active_low=1,gpio_pull=up' /boot/config.txt

###Install the desktop environment##########################################################################################

#set the ducking keyboard, duck!
sed -i 's/gb/us/g' /etc/default/keyboard

#enable  shh, vnc, set WiFi
raspi-config nonint do_ssh 0
raspi-config nonint do_vnc 0
raspi-config nonint do_wifi_country US

#install cool-retro-term {the cool cannot be overstated}
cd /opt/ 
sudo apt install -y build-essential qmlscene qt5-qmake qt5-default qtdeclarative5-dev qml-module-qtquick-controls qml-module-qtgraphicaleffects qml-module-qtquick-dialogs qml-module-qtquick-localstorage qml-module-qtquick-window2 qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel
git clone --recursive https://github.com/Swordfish90/cool-retro-term.git
cd cool-retro-term
qmake && make
sudo cp cool-retro-term.desktop /usr/share/applications
sudo ln -s /opt/cool-retro-term/cool-retro-term /usr/local/bin/cool-retro-term
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

echo install complete
echo log out and log in as new user no
#just a little section to layout my thougts on this config.
# try putting 'pi' as the new user name and see if anything breaks, or if the home folder gets encrypted
# try putting in a username with a space as well, i bet it breaks things
#use more whiptial
#ask for keyword for system theme (background, motd, colors?)
#fix localization (keyboard, timezone, wifi), current solution is insufficient 
#create new user (not "pi") with encrypted file system (https://technicalustad.com/how-to-encrypt-raspberry-pi-home-folder/)
#make i3bar show temp/cpu/ram/ the way i want
#fetch backgrounds based on keyword

#I want this pi to have as many use-cases as possible. 
#-provide wifi hotspot if plugged into internet via ethernet
#-provide internet via ethernet if connected to wifi
#-provide filesharing in both use-cases
#-provide vnc desktop for access via phone/tablet/laptop/refridgerator

#new user first login script?
#Update list of default apps (terminal, browser, etc.): update-alternatives --all
#delete pi user?
#sudo pkill -u pi
#sudo userdel --remove-all-files pi