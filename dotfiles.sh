#!/bin/bash

# Detect screen size, default to 80x24
screen_size=$(stty size 2>/dev/null || echo 24 80)
rows=$(echo $screen_size | awk '{print $1}')
columns=$(echo $screen_size | awk '{print $2}')

#create (r)ow and (c)olumn vairables for whiptail menus
r=$(( rows / 2 ))
c=$(( columns / 2 ))
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))

#set whiptail colors
export NEWT_COLORS="
root=,red
roottext=white,red"

#inform user and prompt for consent
whiptail --backtitle "ghostbusker's dotfiles installer" \
--title "This is the script you are about to install:" \
--textbox --scrolltext $0 ${r} ${c}

####FUCNTIONS#####

chooseModules(){
  echo "let user choose which modules to run"
  MODULES=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
    --title "Choose your own adventure" \
    --checklist --separate-output "Modules:" ${r} ${c} 20 \
    "newEncryptedUser" "New Encrypted User" ON \
    "favoriteApps" "Install Favorite GUI + Terminal Apps" ON \
    "desktopFromScratch" "Install Destop Environment" ON \
    "makeFolders" "Make Default folders" ON \
    "scrapeWallpapers" "Scrape Wallpapers from Web" ON \
    "openVPN" "Install OpenVPN client" OFF \
    "fixPiGroups" "Fix Pi Groups associations" ON \
    "powerButtonLED" "Enalbe GPIO Power Button and LED" ON \
    "localizeEasternUS" "Localize to Eastern US" OFF \
    "enableSSH" "Enable SSH on boot" OFF \
    "enableVNC" "Enable VNC on boot" OFF \
    "retroPie" "Install RetroPie" OFF \
    "creativeSuite" "Install Creative Suite" OFF \
    "coolRetroTerm" "Install CoolRetroTerm" ON \
    "termnialPipes" "Install Pipes for terminal" ON \
    "asciiAquarium" "Install ASCII Aquarium" ON \
    "swapfileChange" "Change Swapfile" OFF \
    "log2Ram" "Install Log2RAM" OFF\
    "copyDotfiles" "Copy dotfiles to $USER home Directory" ON \
    "deletUserPi" "Delete User Pi? *DANGEROUS*" OFF 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    whiptail --backtitle "ghostbusker's dotfiles installer" \
    --title "Setup dotfiles" \
    --infobox "Modules selected: $MODULES" ${r} ${c}
  else
    whiptail --backtitle "ghostbusker's dotfiles installer" \
    --title "Setup dotfiles" \
    --infobox "Cancelled" ${r} ${c}
    exit
  fi
}

checkRoot(){
  echo "Checkinging for root..."
  if [[ $EUID -eq 0 ]]; then
      echo "You are root."
  else
      echo "Please install sudo or run this as root."
      exit 1
  fi
}

checkHelp(){
  echo "checking for --help or -h flags"
  if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
    echo "there is no help."
    sleep 3
    echo "only zuul."
    exit 0
  fi
}

newEncryptedUser(){
  echo "creating new encrypted user"
  USER=username
  USER=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
  --title "New Encrypted User"  \
  --inputbox "Enter new user name. User 'pi' should be deleted for security reasons. No spaces please." \
  ${r} ${c} $USER 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    whiptail --backtitle "ghostbusker's dotfiles installer" \
    --title "New Encrypted User" \
    --infobox "New User: $username" ${r} ${c}
  else
    whiptail --backtitle "ghostbusker's dotfiles installer" \
    --title "New Encrypted User" --infobox "Cancelled" ${r} ${c}
    exit
  fi
  PASS=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
  --title "New Encrypted User"  \
  --passwordbox "Enter password for new user: " ${r} ${c} 3>&1 1>&2 2>&3)

  #create new user and add them to the sudo group
  echo -e "$PASS\n$PASS\n" | sudo adduser --gecos "" $USER
  sudo usermod -a -G sudo $USER

  #install apps needed to encrypt the user folder
  sudo apt install -y ecryptfs-utils lsof cryptsetup

  #encrypt new user home directory
  sudo ecryptfs-migrate-home -u $USER

  #show encryption password with command: ecryptfs-unwrap-passphrase
}

favoriteApps(){
  #This is going to get an implementation and organization overhaul
  echo "installing favorite apps and tools"
  echo "installing termnial upgrade + terminal candy"
  sudo apt install -y terminator locate tilda neovim ranger trash-cli neofetch figlet \
  lolcat cmatrix hollywood funny-manpages caca-utils libaa-bin thefuck howdoi cowsay fortune
  echo "installing system utilities and monitors"
  sudo apt install -y	glances nmon htop
  echo "installing media apps"
  sudo apt install -y cmus vis playerctl vlc
  echo "installing apps for stress testing and benchmarks"
  sudo apt install -y stress sysbench
  echo "installing network info tools"
  sudo apt install -y nmap macchanger tshark zenmap wireshark
  echo "installing more common apps"
  sudo apt install -y screenkey ttyrec realvnc-vnc-server realvnc-vnc-viewer chromium-browser
  echo "installing productivity apps"
  sudo apt install -y geany neovim
}

desktopFromScratch (){
  echo "installing graphical desktop environment"
  sudo apt install -y xorg xserver-xorg xinit git cmake lxappearance
  echo "installing i3-gaps window manager from source"
  cd /opt/ 
  sudo apt install -y i3 gcc make autoconf dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev \
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
  echo "installing apps that will be part of desktop composition and daily use"
  sudo apt install -y i3blocks feh compton clipit arandr mpv florence dunst nemo conky dhcpcd-gtk wpagui
  echo "installing wifi and bluetooth tools"
  sudo apt install -y pi-bluetooth blueman bluealsa network-manager
}

makeFolders() {
  echo "make folders in home directory"
  sudo mkdir /home/$USER/Documents
  sudo mkdir /home/$USER/Downloads
  sudo mkdir /home/$USER/Music
  sudo mkdir /home/$USER/Videos
  sudo mkdir /home/$USER/Pictures
}

scrapeWallpapers() {
  echo "scraping wallpapers from the web" #shamelessly
  sudo mkdir /home/$USER/Pictures/Wallpapers
  cd /home/$USER/Pictures/Wallpapers
  sudo wget http://getwallpapers.com/wallpaper/full/2/2/3/702223-free-rainforest-backgrounds-2560x1440.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/9/d/6/702176-rainforest-backgrounds-1920x1080-for-mac.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/8/0/e/702147-rainforest-backgrounds-2560x1600-images.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/e/8/7/702136-rainforest-backgrounds-1920x1080-for-mobile.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/a/6/e/702131-beautiful-rainforest-backgrounds-1920x1080-for-iphone-6.jpg
  sudo wget http://getwallpapers.com/wallpaper/full/a/a/9/702126-rainforest-backgrounds-2560x1600-for-computer.jpg
}

openVPN() {
  echo "installing openvpn for tunneling back to home network"
  sudo apt install -y openvpn
  #runs with: sudo openvpn ~./location/of/ovpn-file.ovpn
  #launched by i3, see ~/.config/i3/config
}

fixPiGroups() {
  echo "adding user to all the groups that user pi was a part of"
  sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio $USER
}

powerButtonLED() {
  echo "adding GPIO pin3 shutdown to /boot/config.txt AND enabling UART so that pin 8 acts as power LED" 
  sudo sed -i '$a dtoverlay=gpio-shutdown,gpio_pin=3,active_low=1,gpio_pull=up\' /boot/config.txt
  sudo sed -i '$a enable_uart=1\' /boot/config.txt
}

localizeEasternUS() {
  echo "setting localization for keyboard, clock, and wifi"
  sudo sed -i 's/gb/us/g' /etc/default/keyboard
  sudo timedatectl set-timezone US/Eastern
  sudo raspi-config nonint do_wifi_country US
}

enableSSH() {
  echo "enabling ssh as a service"
  sudo raspi-config nonint do_ssh 0
}

enableVNC() {
  echo "enabling vnc"
  sudo raspi-config nonint do_vnc 0
}

retroPie() {
  echo "installing retropie"
  cd /opt/
  sudo git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
  cd RetroPie-Setup
  sudo ./retropie_setup.sh
}

creativeSuite() {
  echo "installing ghostbusker's creative suite"
  sudo apt install -y mixxx kdenlive blender audacity gimp
}

coolRetroTerm() {
  echo "installing cool retro terminal"
  cd /opt/ 
  sudo apt install -y build-essential qmlscene qt5-qmake qt5-default qtdeclarative5-dev qml-module-qtquick-controls \
  qml-module-qtgraphicaleffects qml-module-qtquick-dialogs qml-module-qtquick-localstorage qml-module-qtquick-window2 \
  qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel
  git clone --recursive https://github.com/Swordfish90/cool-retro-term.git
  cd cool-retro-term
  qmake && make
  sudo cp cool-retro-term.desktop /usr/share/applications
  sudo ln -s /opt/cool-retro-term/cool-retro-term /usr/local/bin/cool-retro-term
}

terminalPipes() {
  echo "installing pipeseroni's pipes.sh from source"
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

asciiAquarium(){
  echo "installing ascii aquarium"
  sudo apt-get install libcurses-perl
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

swapfileChange(){
  echo "adjusting sawp file size"
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
}

log2Ram() {
  echo "installing log2ram" #must be done last and requires reboot
  printf -- 'deb http://packages.azlux.fr/debian/ buster main'| sudo tee /etc/apt/sources.list.d/azlux.list
  wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
  apt update
  apt install log2ram
}

copyDotfiles (){
  echo "copying dotfiles into place"
  sudo cp -r .config/ /home/$USER/
  sudo cp -r .bashrc /home/$USER/

  #this next part made all the difference, chome and a bunch of other apps were broken otherwise
  #take ownership and set permissions of user folder:
  sudo -u $USER chmod 750 -R /home/$USER/
  sudo chown -R $USER:$USER /home/$USER/
  sudo umask 0027
}

deleteUserPi(){
  echo "deleting pi user and removing all files"
  sudo pkill -u pi
  sudo userdel --remove-all-files pi
}

pepareInstall(){
  echo "preparing to run modules"
  sudo git config --global color.ui auto
  echo "updating package list"
  sudo apt update || sudo apt-get -o Acquire::ForceIPv4=true update
  echo "starting script timer"
  STOPWATCH=0
  echo "creating install log"
  tmpLog="/tmp/dotfiles-install.log"

  #backup then temporarily change terminal colors
  #TEMP1=$PS1
  #export PS1="\e[0;32m\]"
}

runModules(){
  echo "running each module in sequence"
  for module in $MODULES ; do \
    $module | tee -a -i $tmpLog ; \
  done
}

exportLog(){
  echo "exporting log to currrent working directory"
  sudo mv $tmpLog $(pwd)
}

showInfo(){
  echo "showing some helpful info"
  echo "Current /boot/config.txt settings: "
  vcgencmd get_config int
  echo "showing directory tree"
  sudo tree
  echo "showing codec info"
  for codec in H264 MPG2 WVC1 MPG4 MJPG WMV9 ; do \
    echo "$codec:\t$(vcgencmd codec_enabled $codec)" ; \
  done
  echo "script runtime"
  ELAPSED="Elapsed: $(($STOPWATCH / 3600))hrs $((($STOPWATCH / 60) % 60))min $(($STOPWATCH % 60))sec"
  echo "$ELAPSED" #| lolcat

  #return terminal colors to normal
  #PS1=$TEMP1

  #alternatley/additionally, reload bash?
  bash
}

################# ACTUAL run scrip, do all the stuff in the modules above ########################

checkRoot
checkHelp
chooseModules
prepareInstall
runModules
exportLog
echo "installer script finished"
echo "reboot may be needed"
showInfo
exit 0

#just a little section to layout my thougts on this config.
#try putting 'pi' as the new user name and see if anything breaks, or if the home folder gets encrypted
#try putting in a username with a space as well, i bet it breaks things
#ask for keyword for system theme and auto generate background, motd, colors?

#I want this pi to have as many use-cases as possible. 
#-provide wifi hotspot if plugged into internet via ethernet
#-provide internet via ethernet port if connected to wifi
#-provide filesharing in both use-cases
#-provide vnc desktop for access via phone/tablet/laptop/fredidgerator

#new user first login script?
#Update list of default apps (terminal, browser, etc.): update-alternatives --all

#maybe try the following line to intsall apps 1 by 1 for testing
#for i in package1 package2 package3; do sudo apt-get install -y $i; done
