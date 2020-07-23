#!/usr/bin/env bash
# https://github.com/ghostbusker/dotfiles
# install using "curl -sSL dotfiles.ghostbusker.com | sudo bash"

# get terminal dimensions for sizing menus
MENU_HEIGHT=$(($(tput lines)-8))
MENU_WIDTH=$(($(tput cols)-8))

# set whiptail menu colors
export NEWT_COLORS='
root=,red
roottext=white,red
title=red,
border=white,
'

whiptail \
--title "This is the script you are about to install:" \
--backtitle "ghostbusker's dotfiles installer" \
--msgbox "$(curl -sSL http://dotfiles.ghostbusker.com)" \
--scrolltext --fullbuttons $MENU_HEIGHT $MENU_WIDTH

# these are the variables you might consider changing before continuing script
SWAPSIZE=128    #swap file in MB
TIMEZONE=US/Eastern
LOCALE=en_US.UTF-8
LAYOUT=us   #keyboard
WIFICOUNTRY=US

# start a log
TEMPLOG="/tmp/dotfiles-install.log"

### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ### Modules ###

new_encrypted_user() {
  TARGETUSER=$(whiptail \
    --title "New Encrypted User"  \
    --backtitle "ghostbusker's dotfiles installer" \
    --inputbox "Enter new user name. \nUser 'pi' should be deleted for security reasons. \nNo spaces please." \
    --fullbuttons --nocancel 10 40 username 3>&1 1>&2 2>&3)
  export TARGETUSER=$TARGETUSER
  
   userPass=$(whiptail \
    --title "New Encrypted User"  \
    --backtitle "ghostbusker's dotfiles installer" \
    --passwordbox "Enter password for new user: " \
    --fullbuttons --nocancel 10 40 3>&1 1>&2 2>&3)

  #create new user, set password, and add them to the sudo group
  sudo adduser --gecos "" $TARGETUSER 
  printf "$userPass\n$userPass\n" | sudo passwd $TARGETUSER 
  sudo usermod -a -G sudo $TARGETUSER 

  #clear password variable after use
  userPass=""

  #install apps needed to encrypt the user folder
  sudo apt -y --fix-missing install ecryptfs-utils lsof cryptsetup

  #encrypt new user home directory
  sudo ecryptfs-migrate-home -u $TARGETUSER
} 

set_localization() {
  # something here is broken but the keyboard part works so IM happy
  sudo timedatectl set-timezone $TIMEZONE
  sudo raspi-config nonint do_change_locale $LOCALE
  sudo raspi-config nonint do_configure_keyboard $LAYOUT
  sudo raspi-config nonint do_wifi_country $WIFICOUNTRY
  export LANGUAGE=$LOCALE
  export LANG=$LOCALE
  export LC_ALL=$LOCALE
  sudo locale-gen $LOCALE
  sudo dpkg-reconfigure localeslocale-gen $LOCALE
}

enable_SSH() {
  sudo raspi-config nonint do_ssh 0
}

enable_VNC() {
  sudo apt -y --fix-missing install realvnc-vnc-server realvnc-vnc-viewer
  sudo raspi-config nonint do_vnc 0
}

desktop_from_scratch () {
  sudo apt -y --fix-missing install xorg xserver-xorg xinit git cmake lxappearance
  #installing i3-gaps window manager from source
  cd /opt/ 
  sudo apt -y --fix-missing install i3 gcc make autoconf dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev \
  libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev \
  libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0 libxcb-shape0-dev
  sudo git clone https://www.github.com/Airblader/i3 i3-gaps
  cd i3-gaps
  sudo autoreconf --force --install
  sudo rm -rf build/
  sudo mkdir -p build 
  cd build/
  sudo ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
  sudo make -j8
  sudo make install
  #installing apps that will be part of desktop composition and daily use
  sudo apt -y --fix-missing install i3blocks feh compton clipit arandr mpv florence dunst nemo conky dhcpcd-gtk wpagui
  #installing wifi and bluetooth tools"
  sudo apt -y --fix-missing install pi-bluetooth blueman bluealsa network-manager nm-tray
}

favorite_apps() {
  #This is going to get an implementation and organization overhaul
  echo "installer: installing favorite apps and tools"
  echo "installing termnial upgrade + terminal candy"
  sudo apt -y --fix-missing install xterm locate tilda neovim ranger trash-cli neofetch figlet lolcat cmatrix hollywood \
  funny-manpages caca-utils libaa-bin thefuck howdoi cowsay fortune
  echo "installing vanity fonts"
  sudo apt -y --fix-missing install fonts-ocr-a
  sudo fc-cache -f -v 
  echo "installing system utilities and monitors"
  sudo apt -y --fix-missing install glances nmon htop # this line not working
  echo "installing media apps"
  sudo apt -y --fix-missing install cmus vis playerctl vlc fswebcam
  echo "installing apps for stress testing and benchmarks"
  sudo apt -y --fix-missing install stress sysbench
  echo "installing network info tools"
  sudo apt -y --fix-missing install nmap tshark zenmap 
  export DEBIAN_FRONTEND=noninteractive
  yes | sudo apt -y --fix-missing install macchanger wireshark #still prompting for user input
  echo "installing more common apps"
  sudo apt -y --fix-missing install screenkey ttyrec realvnc-vnc-server realvnc-vnc-viewer chromium-browser # this line not working
  echo "installing productivity apps"
  sudo apt -y --fix-missing install geany neovim remind
}

make_common_folders() {
  sudo mkdir /home/$TARGETUSER/Documents
  sudo mkdir /home/$TARGETUSER/Downloads
  sudo mkdir /home/$TARGETUSER/Music
  sudo mkdir /home/$TARGETUSER/Videos
  sudo mkdir /home/$TARGETUSER/Pictures
}

scrape_wallpapers() {
  echo "installer: scraping wallpapers from the web" #shamelessly
  sudo mkdir /home/$TARGETUSER/Pictures/Wallpapers
  cd /home/$TARGETUSER/Pictures/Wallpapers
  sudo wget https://cdn.clipart.email/ea453281dbdec70a2bf5b70464f41e4f_desert-sand-background-gallery-yopriceville-high-quality-_5500-3667.jpeg
  sudo wget http://getwallpapers.com/wallpaper/full/2/2/3/702223-free-rainforest-backgrounds-2560x1440.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/9/d/6/702176-rainforest-backgrounds-1920x1080-for-mac.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/8/0/e/702147-rainforest-backgrounds-2560x1600-images.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/e/8/7/702136-rainforest-backgrounds-1920x1080-for-mobile.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/a/6/e/702131-beautiful-rainforest-backgrounds-1920x1080-for-iphone-6.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/a/a/9/702126-rainforest-backgrounds-2560x1600-for-computer.jpg
  sudo wget --output-document=77d851d65c43.jpg https://images.unsplash.com/photo-1518965539400-77d851d65c43
  sudo wget --output-document=e29b079736c0.jpg https://images.unsplash.com/photo-1565138146061-e29b079736c0
  sudo wget --output-document=afa90b13e000.jpg https://images.unsplash.com/photo-1516528387618-afa90b13e000
  sudo wget --output-document=7d1092d8c6c6.jpg https://images.unsplash.com/photo-1428572184420-7d1092d8c6c6
  sudo wget --output-document=ef046c08a56e.jpg https://images.unsplash.com/photo-1497250681960-ef046c08a56e
  sudo wget --output-document=e0475b1856c4.jpg https://images.unsplash.com/photo-1580630873708-e0475b1856c4
  sudo wget --output-document=9da59a9b1fef.jpg https://images.unsplash.com/photo-1518058488548-9da59a9b1fef
  sudo wget --output-document=7706220a65f6.jpg https://images.unsplash.com/photo-1570828066702-7706220a65f6
  sudo wget --output-document=c7d3dc332654.jpg https://images.unsplash.com/photo-1495527400402-c7d3dc332654
  sudo wget --output-document=36f6e462f56d.jpg https://images.unsplash.com/photo-1515615575935-36f6e462f56d
  sudo wget --output-document=5ec7c8c8e1a6.jpg https://images.unsplash.com/photo-1524207874394-5ec7c8c8e1a6
  sudo wget --output-document=821febf1275c.jpg https://images.unsplash.com/photo-1548759806-821febf1275c
  sudo wget --output-document=0b7889e0f147.jpg https://images.unsplash.com/photo-1547499417-0b7889e0f147
  sudo wget --output-document=b498b3fb3387.jpg https://images.unsplash.com/photo-1569429593410-b498b3fb3387
  sudo wget --output-document=580b10ae7715.jpg https://images.unsplash.com/photo-1504548840739-580b10ae7715
  sudo wget --output-document=53a374d2d2e1.jpg https://images.unsplash.com/photo-1563836728031-53a374d2d2e1
  sudo wget --output-document=208c53a23c2a.jpg https://images.unsplash.com/photo-1556331968-208c53a23c2a
  sudo wget --output-document=80a3466b13fe.jpg https://images.unsplash.com/photo-1564565562150-80a3466b13fe
  sudo wget --output-document=5ae24d986629.jpg https://images.unsplash.com/photo-1561622481-5ae24d986629
  sudo wget --output-document=fb52f37ba73c.jpg https://images.unsplash.com/photo-1544481921-fb52f37ba73c
  sudo wget --output-document=f0e5c91fa707.jpg https://images.unsplash.com/photo-1527409335569-f0e5c91fa707
  sudo wget --output-document=b24cf25c4a36.jpg https://images.unsplash.com/photo-1472145246862-b24cf25c4a36
}

openVPN() {
  # install openvpn for tunneling back to home network
  sudo apt -y --fix-missing install openvpn
  # runs with: sudo openvpn ~./location/of/ovpn-file.ovpn
  # launched by i3, see ~/.config/i3/config
}

fix_pi_groups() {
  # adding user to all the groups that user pi was a part of
  sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio $TARGETUSER
}

power_button_LED() {
  # adding GPIO pin3 shutdown to /boot/config.txt AND enabling UART so that pin 8 acts as power LED 
  sudo sed -i '$a dtoverlay=gpio-shutdown,gpio_pin=3,active_low=1,gpio_pull=up\' /boot/config.txt
  sudo sed -i '$a enable_uart=1\' /boot/config.txt
}

moonlight_stream() {
  # installing: setting up Moonlight nvidia Shield game streaming
  sudo bash -c 'printf "deb http://archive.itimmer.nl/raspbian/moonlight buster main\n" >> /etc/apt/sources.list'
  wget http://archive.itimmer.nl/itimmer.gpg
  sudo apt-key add itimmer.gpg
  sudo apt update
  sudo apt -y --fix-missing install moonlight-embedded
  # don't forget to pair with target IP then stream using $:moonlight stream -1080 -30fps -app Steam
}
retropie() {
  cd /opt/
  sudo git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
  cd RetroPie-Setup
  sudo ./retropie_setup.sh
}

creative_suite() {
  sudo apt -y --fix-missing install mixxx kdenlive blender audacity gimp fswebcam fluidsynth
  #sudo apt -y --fix-missing install non-daw non-mixer non-sequencer non-session-manager
  # trying out reaper daw
  cd /opt/
  wget http://reaper.fm/files/6.x/reaper609_linux_armv7l.tar.xz
  sudo tar xvf reaper609_linux_armv7l.tar.xz 
  cd reaper_linux_armv7l
  sudo install-reaper.sh
}

cool_retro_term() {
  cd /opt/ 
  sudo apt -y --fix-missing install build-essential qmlscene qt5-qmake qt5-default qtdeclarative5-dev qml-module-qtquick-controls \
  qml-module-qtgraphicaleffects qml-module-qtquick-dialogs qml-module-qtquick-localstorage qml-module-qtquick-window2 \
  qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel
  git clone --recursive https://github.com/Swordfish90/cool-retro-term.git
  cd cool-retro-term
  qmake && make
  sudo make install
  sudo cp cool-retro-term.desktop /usr/share/applications
  #sudo ln -s /opt/cool-retro-term/cool-retro-term /usr/local/bin/cool-retro-term

}

terminal_pipes() {
  cd /opt/
  sudo git clone https://github.com/pipeseroni/pipes.sh
  cd pipes.sh
  sudo make install
}

#more matrix stuff apparently
#cd /opt/
#sudo git clone https://github.com/mayfrost/ncmatrix
#cd ncmatrix
#sudo chmod +x configure
#sudo ./configure
#sudo make check
#sudo make install   
#probs done installing NMmatrix  

ascii_aquarium() {
  sudo apt -y --fix-missing install libcurses-perl
  cd /opt/ 
  sudo wget http://search.cpan.org/CPAN/authors/id/K/KB/KBAUCOM/Term-Animation-2.4.tar.gz
  sudo tar -zxvf Term-Animation-2.4.tar.gz
  sudo cd Term-Animation-2.4/
  sudo perl Makefile.PL &&  make &&   make test
  sudo make install
  cd /opt/
  sudo wget http://www.robobunny.com/projects/asciiquarium/asciiquarium.tar.gz
  sudo tar -zxvf asciiquarium.tar.gz
  sudo cd asciiquarium_1.1/
  sudo cp asciiquarium /usr/local/bin
  sudo chmod 0755 /usr/local/bin/asciiquarium
}

set_swapfile() {
  # Andreas Speiss recomends these swap file changes
  sudo sed -i '/CONF_SWAPFILE/c\CONF_SWAPFILE=/var/swap' /etc/dphys-swapfile 
  sudo sed -i '/CONF_SWAPFACTOR/c\CONF_SWAPFACTOR=2' /etc/dphys-swapfile 
  sudo sed -i '/CONF_SWAPSIZE/c\#CONF_SWAPSIZE=$SWAPSIZE' /etc/dphys-swapfile 
  sudo dphys-swapfile setup
  sudo dphys-swapfile swapon
  # Alternatively... Disable Swap 
  #sudo swapoff -a -v
}

auto_hotspot () {
  cd $(dirname "$0")
  curl "https://www.raspberryconnect.com/images/hsinstaller/AutoHotspot-Setup.tar.gz" -o AutoHotspot-Setup.tar.gz
  tar -xzvf AutoHotspot-Setup.tar.gz
  cd Autohotspot
  sudo ./autohotspot-setup.sh
  ### SOMETHING IS BROKEN AND THIS INSTALLER MENU FLASHES, THIS NEXT LINE MIGHT FIX
  read
}


log2Ram() {
  printf -- 'deb http://packages.azlux.fr/debian/ buster main' | sudo tee /etc/apt/sources.list.d/azlux.list
  wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
  apt update
  apt -y install log2ram
}

copy_dotfiles() {
  cd $(dirname "$0")
  sudo git clone http://github.com/ghostbusker/dotfiles
  cd dotfiles

  #THIS NEEDS TO BE FIXED SO THAT FILES ARE OVERWRITTEN IN CASE OF CONFLICT
  sudo mv -f .config /home/$TARGETUSER/
  sudo mv -f .bashrc /home/$TARGETUSER/
  sudo mv -f .conkyrc /home/$TARGETUSER/
  sudo mv -f .profile /home/$TARGETUSER/
  sudo mv -f .watermark /home/$TARGETUSER/
  sudo mv -f .Xresources /home/$TARGETUSER/

  # Not a dotfile but can be used to set local console fonts
  #sudo mv -f console-setup /etc/default/console-setup

  # this next part made all the difference, chome and a bunch of other apps were broken otherwise
  # take ownership and set permissions of user folder:
  sudo -u $TARGETUSER chmod 750 -R /home/$TARGETUSER/
  # AAAAAANNDDD ITS BROKEN
  sudo chown -R $TARGETUSER:$TARGETUSER /home/$TARGETUSER/
  #umask command not found according to lastest raspbian release
  sudo umask 0027
}

#delete_user_pi() {
#  sudo pkill -u pi
#  #sudo userdel --remove-all-files pi
## removed this line from MODULES menu list: "delete_user_pi" "Delete User Pi? *DANGEROUS*" OFF \
#}

show_helpfull_info() {
  printf "\nCurrent /boot/config.txt settings: \n"
  vcgencmd get_config int
  echo "showing directory tree"
  cd
  sudo tree
  echo "showing codec info"
  for codec in H264 MPG2 WVC1 MPG4 MJPG WMV9 ; do \
    echo "$codec:\t$(vcgencmd codec_enabled $codec)" ; \
  done
}
 

### Actual Script Time ### Actual Script Time ### Actual Script Time ### Actual Script Time ### Actual Script Time ### Actual Script Time ### 

# check for root
#if [ $(id -u) -ne 0 ]; then
#  printf "\nScript must be run as root. \n"
#  exit 1
#fi

# ask user which modules to run 
MODULES=$(whiptail \
  --backtitle "ghostbusker's dotfiles installer" \
  --title "Choose your own adventure" \
  --checklist "Modules:" 0 0 21\
  --notags \
  --fullbuttons \
  --nocancel \
  --separate-output \
  "new_encrypted_user" "New User with Encrypted home folder" ON \
  "set_localization" "Localize Keyboard, Wifi, timezone" OFF \
  "enable_SSH" "Enable SSH on boot" OFF \
  "enable_VNC" "Enable VNC on boot" OFF \
  "favorite_apps" "Favorite GUI + Terminal Apps" ON \
  "desktop_from_scratch" "Desktop Environment" ON \
  "make_common_folders" "Create Common Folders" ON \
  "scrape_wallpapers" "Scrape Wallpapers from Web" ON \
  "openVPN" "Install OpenVPN client" OFF \
  "fix_pi_groups" "Fix Pi Groups associations" ON \
  "power_button_LED" "Enalbe GPIO Power Button and LED" ON \
  "moonlight_stream" "Install moonlight for game streaming" ON \
  "retroPie" "Install RetroPie" OFF \
  "creative_suite" "Creative Suite Apps" OFF \
  "cool_retro_term" "CoolRetroTerm" ON \
  "terminal_pipes" "Pipes for terminal" ON \
  "ascii_aquarium" "ASCII Aquarium" ON \
  "set_swapfile" "Adjust Swapfile" OFF \
  "auto_hotspot" "Autohotspot" OFF \
  "log2Ram" "Install Log2RAM" OFF\
  "copy_dotfiles" "Copy dotfiles to target user home Directory" ON \
  3>&1 1>&2 2>&3)

### NOT WOKRING ### RUNS UNDER ALL CONDITIONS
# set a target user if not creating new user 
if [[ ! $MODULES  =~ *new_encrypted_user* ]]; then
  TARGETUSER=$(whiptail \
  --backtitle "ghostbusker's dotfiles installer" \
  --title "No New User, Select Target" \
  --inputbox "What user should these settings apply to?" \
  --fullbuttons --nocancel 0 0 $TARGETUSER 3>&1 1>&2 2>&3)
  export TARGETUSER=$TARGETUSER
fi

# start script timer
START=$SECONDS

# prepare apt and git for installing a bunch of apps
sudo apt update 
sudo apt -y --fix-missing install git
sudo git config --global color.ui auto

# magic loop that calls each fucntion, anounces its name, executes it, and logs the output
for module in $MODULES ; do \
  printf "\nINSTALLER: RUNNING MODULE $module \n" | tee -a -i $TEMPLOG
  $module | tee -a -i $TEMPLOG ; \
done

# stop script timer
STOP=$(($SECONDS-$START))

# display script and system info, add to log
printf 'script runtime %dh:%dm:%ds\n' $(($STOP/3600)) $(($STOP%3600/60)) $(($STOP%60)) | tee -a -i $TEMPLOG
show_helpfull_info | tee -a -i $TEMPLOG

# save log to same location as script
sudo mv $TEMPLOG $(dirname "$0")

exit


##notes
still doesnt pass username varialbe correcly or something in the first couple of interactions,
needs to have menus stremlined to take place before? modules run?

still asked me to enter password 2x AFTER the whiptail menu when setting new encrypted user pass

