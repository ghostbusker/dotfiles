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
root=,green
roottext=green,black
"
#textbox=,
#listbox=,

#inform user and prompt for consent
whiptail --backtitle "ghostbusker's dotfiles installer" \
--title "This is the script you are about to install:" \
--textbox --scrolltext $0 ${r} ${c}

#create a reference to where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#set apt to be less noisy
#export DEBIAN_FRONTEND=noninteractive

####FUCNTIONS#####

chooseModules() {
  echo "installer: let user choose which modules to run"
  MODULES=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
    --title "Choose your own adventure" \
    --checklist --separate-output "Modules:" ${r} ${c} 21 \
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
    "moonlightStream" "Install moonlight for game streaming" ON \
    "retroPie" "Install RetroPie" OFF \
    "creativeSuite" "Install Creative Suite" OFF \
    "coolRetroTerm" "Install CoolRetroTerm" ON \
    "terminalPipes" "Install Pipes for terminal" ON \
    "asciiAquarium" "Install ASCII Aquarium" ON \
    "swapfileChange" "Change Swapfile" OFF \
    "log2Ram" "Install Log2RAM" OFF\
    "copyDotfiles" "Copy dotfiles to $targetUser home Directory" ON \
    "deleteUserPi" "Delete User Pi? *DANGEROUS*" OFF 3>&1 1>&2 2>&3)
  #exitstatus=$?
  #if [ $exitstatus = 0 ]; then
  #  whiptail --backtitle "ghostbusker's dotfiles installer" \
  #  --title "Setup dotfiles" \
  #  --msgbox "Modules selected: \n$MODULES" ${r} ${c}
  #else
  #  whiptail --backtitle "ghostbusker's dotfiles installer" \
  #  --title "Setup dotfiles" \
  #  --msgbox "Cancelled" ${r} ${c}
  #  exit
  #fi

  #pass MODULES list to other modules
  #NOT WORKING
  echo "MODULES="
  echo $MODULES
  export MODULES="$MODULES"
}

#checkRoot() {
#  echo "installer: checkinging for root..."
#  if [[ $EUID -eq 0 ]]; then
#      echo "you are root."
#  else
#      echo "please install sudo or run this as root."
#      exit 1
#  fi
#}

#checkHelp() {
#  echo "installer: checking for --help or -h flags"
#  if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
#    echo "there is no help."
#    sleep 3
#    echo "only zuul."
#    exit 0
#  fi
#}

newEncryptedUser() {
  echo "installer: creating new encrypted user"
  targetUser=username
  targetUser=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
  --title "New Encrypted User"  \
  --inputbox "Enter new user name. User 'pi' should be deleted for security reasons. No spaces please." \
  ${r} ${c} $targetUser 3>&1 1>&2 2>&3)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    whiptail --backtitle "ghostbusker's dotfiles installer" \
    --title "New Encrypted User" \
    --msgbox "New User: $targetUser" ${r} ${c}
  else
    whiptail --backtitle "ghostbusker's dotfiles installer" \
    --title "New Encrypted User" \
    --msgbox "Cancelled" ${r} ${c}
    exit
  fi
#  echo "requesting password"
#  while [ "$userPass" != "$passRepeat" ]; do
#    userPass=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
#    --title "New Encrypted User" \
#    --passwordbox "$passWrong Enter password for new user: " \
#    ${r} ${c} 3>&1 1>&2 2>&3)
#    passRepeat=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
#    --title "New Encrypted User" \
#    --passwordbox "Re-Enter password: " \
#    ${r} ${c} 3>&1 1>&2 2>&3)
#    passWrong="Passwords don't match! Re-"
#  done

  #create new user and add them to the sudo group
  echo -e "$userPass\n$userPass\n" | sudo adduser --gecos "" $targetUser
  sudo usermod -a -G sudo $targetUser

  #install apps needed to encrypt the user folder
  sudo apt -yq install ecryptfs-utils lsof cryptsetup

  #encrypt new user home directory
  sudo ecryptfs-migrate-home -u $targetUser

  #show encryption password with command: ecryptfs-unwrap-passphrase
  #pass the targetUser variable so it can be used in other modules
  #NOT WORKING
  echo "targetUser=$targetUser"
  export targetUser="$targetUser"
}

favoriteApps() {
  #This is going to get an implementation and organization overhaul
  echo "installer: installing favorite apps and tools"
  echo "installing termnial upgrade + terminal candy"
  sudo apt -yq install terminator xterm locate tilda neovim ranger trash-cli neofetch figlet \
  lolcat cmatrix hollywood funny-manpages caca-utils libaa-bin thefuck howdoi cowsay fortune
  echo "installing vanity fonts"
  sudo apt -yq install fonts-ocr-a
  sudo fc-cache -f -v 
  echo "installing system utilities and monitors"
  sudo apt -yq install glances nmon htop # this line not working
  echo "installing media apps"
  sudo apt -yq install cmus vis playerctl vlc fswebcam
  echo "installing apps for stress testing and benchmarks"
  sudo apt -yq install stress sysbench
  echo "installing network info tools"
  sudo apt -yq install nmap tshark zenmap 
  sudo export DEBIAN_FRONTEND=noninteractive apt -yq install macchanger wireshark #still prompting for user input
  echo "installing more common apps"
  sudo apt -yq install screenkey ttyrec realvnc-vnc-server realvnc-vnc-viewer chromium-browser # this line not working
  echo "installing productivity apps"
  sudo apt -yq install geany neovim
}

desktopFromScratch () {
  echo "installer: installing graphical desktop environment"
  sudo apt -yq install xorg xserver-xorg xinit git cmake lxappearance
  echo "installing i3-gaps window manager from source"
  cd /opt/ 
  sudo apt -yq install i3 gcc make autoconf dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev \
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
  sudo apt -yq install i3blocks feh compton clipit arandr mpv florence dunst nemo conky dhcpcd-gtk wpagui
  echo "installing wifi and bluetooth tools"
  sudo apt -yq install pi-bluetooth blueman bluealsa network-manager
}

makeFolders() { # this whole module not working
  echo "installer: make folders in home directory" 
  sudo mkdir /home/$targetUser/Documents
  sudo mkdir /home/$targetUser/Downloads
  sudo mkdir /home/$targetUser/Music
  sudo mkdir /home/$targetUser/Videos
  sudo mkdir /home/$targetUser/Pictures
}

scrapeWallpapers() { # this whole module not working
  echo "installer: scraping wallpapers from the web" #shamelessly
  sudo mkdir /home/$targetUser/Pictures/Wallpapers
  cd /home/$targetUser/Pictures/Wallpapers
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
  echo "installer: installing openvpn for tunneling back to home network"
  sudo apt -yq install openvpn
  #runs with: sudo openvpn ~./location/of/ovpn-file.ovpn
  #launched by i3, see ~/.config/i3/config
}

fixPiGroups() {
  echo "installer: adding user to all the groups that user pi was a part of"
  sudo usermod -a -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio $targetUser
}

powerButtonLED() {
  echo "installer: adding GPIO pin3 shutdown to /boot/config.txt AND enabling UART so that pin 8 acts as power LED" 
  sudo sed -i '$a dtoverlay=gpio-shutdown,gpio_pin=3,active_low=1,gpio_pull=up\' /boot/config.txt
  sudo sed -i '$a enable_uart=1\' /boot/config.txt
}

localizeEasternUS() {
  echo "installer: setting localization for keyboard, clock, and wifi"
  sudo sed -i 's/gb/us/g' /etc/default/keyboard
  sudo timedatectl set-timezone US/Eastern
  sudo raspi-config nonint do_wifi_country US
}

enableSSH() {
  echo "installer: enabling ssh as a service"
  sudo raspi-config nonint do_ssh 0
}

enableVNC() {
  echo "installer: enabling vnc"
  sudo apt -yq install realvnc-vnc-server realvncv-nc-viewer
  sudo raspi-config nonint do_vnc 0
}

moonlightStream() {
  echo "installing: setting up Moonlight nvidia Shield game streaming"
  sudo bash -c 'printf "deb http://archive.itimmer.nl/raspbian/moonlight buster main\n" >> /etc/apt/sources.list'
  wget http://archive.itimmer.nl/itimmer.gpg
  sudo apt-key add itimmer.gpg
  sudo apt-get update
  sudo apt-get install moonlight-embedded
  # don't forget to pair with target IP then stream using $:moonlight stream -1080 -30fps -app Steam
}

retroPie() {
  echo "installer: installing retropie"
  cd /opt/
  sudo git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
  cd RetroPie-Setup
  sudo ./retropie_setup.sh
}

creativeSuite() {
  echo "installer: installing ghostbusker's creative suite"
  sudo apt -yq install mixxx kdenlive blender audacity gimp fswebcam
}

coolRetroTerm() {
  echo "installer: installing cool retro terminal"
  cd /opt/ 
  sudo apt -yq install build-essential qmlscene qt5-qmake qt5-default qtdeclarative5-dev qml-module-qtquick-controls \
  qml-module-qtgraphicaleffects qml-module-qtquick-dialogs qml-module-qtquick-localstorage qml-module-qtquick-window2 \
  qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel
  git clone --recursive https://github.com/Swordfish90/cool-retro-term.git
  cd cool-retro-term
  qmake && make
  sudo cp cool-retro-term.desktop /usr/share/applications
  sudo ln -s /opt/cool-retro-term/cool-retro-term /usr/local/bin/cool-retro-term
}

terminalPipes() {
  echo "installer: installing pipeseroni's pipes.sh from source"
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

asciiAquarium() {
  echo "installer: installing ascii aquarium"
  sudo apt-get install -y libcurses-perl
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

swapfileChange() {
  echo "installer: adjusting sawp file size"
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
  echo "installer: installing log2ram" #must be done last and requires reboot
  printf -- 'deb http://packages.azlux.fr/debian/ buster main'| sudo tee /etc/apt/sources.list.d/azlux.list
  wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
  apt update
  apt -yq install log2ram
}

copyDotfiles() {
  echo "installer: copying dotfiles into place"
  cd $DIR
  sudo cp -r .config/ /home/$targetUser/
  sudo cp -r .bashrc /home/$targetUser/
  sudo cp -r .conkyrc /home/$targetUser/
  sudo cp -r .profile /home/$targetUser/

  #this next part made all the difference, chome and a bunch of other apps were broken otherwise
  #take ownership and set permissions of user folder:
  sudo -u $targetUser chmod 750 -R /home/$targetUser/
  sudo chown -R $targetUser:$targetUser /home/$targetUser/
  sudo umask 0027
}

deleteUserPi() {
  echo "installer: deleting pi user and removing all files"
  sudo pkill -u pi
  #sudo userdel --remove-all-files pi
}

prepareInstall() {
  echo "installer: preparing to run modules"
  echo "updating package list"
  sudo apt update || sudo apt-get -o Acquire::ForceIPv4=true update
  echo "updating git"
  sudo apt -yq install git
  sudo git config --global color.ui auto
 # echo "check for targetUser"
 # if [[ $MODULES == *"newEncryptedUser"* ]]; then
 #   echo "targetUser will be selected durring newEncryptedUser setup"
 # else
 #   #setup target
 #   targetUser=username
 #   targetUser=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
 #   --title "Prepare Install"  \
 #   --inputbox "Enter the target user name where files and permissions should be applied. " \
 #   ${r} ${c} $targetUser 3>&1 1>&2 2>&3)
 #   exitstatus=$?
 #   if [ $exitstatus = 0 ]; then
 #     whiptail --backtitle "ghostbusker's dotfiles installer" \
 #     --title "Prepare Install" \
 #     --msgbox "Target User: $targetUser" ${r} ${c}
 #   else
 #     whiptail --backtitle "ghostbusker's dotfiles installer" \
 #     --title "Prepare Install" \
 #     --msgbox "Cancelled" ${r} ${c}
 #     exit                               #DOESNT EXIT
 #   fi
 # fi

 #if [[ !  =~ "newEncryptedUser" ]] ; then
 #   targetUser=username
 #   targetUser=$(whiptail --backtitle "ghostbusker's dotfiles installer" \
 #   --title "Prepare Install"  \
 #   --inputbox "Enter the target user name where files and permissions should be applied. " \
 #   ${r} ${c} $targetUser 3>&1 1>&2 2>&3)
 #   exitstatus=$?
 #   if [ $exitstatus = 0 ]; then
 #     whiptail --backtitle "ghostbusker's dotfiles installer" \
 #     --title "Prepare Install" \
 #     --msgbox "Target User: $targetUser" ${r} ${c}
 #   else
 #     whiptail --backtitle "ghostbusker's dotfiles installer" \
 #     --title "Prepare Install" \
 #     --msgbox "Cancelled" ${r} ${c}
 #     exit
 #   fi
 # fi


  echo "selected Modules:"
  echo $MODULES
  echo "run installer with these settings? (y/n)"
  echo "this is broken so your choice matters libstartup-notification0-dev"
  read answer
  #if [ "$answer" != "${answer#[Yy]}" ]; then           #TOTOTES BROKOKES
  #  echo "running..."
  #else
  #  exit
  #fi

  #stopWatch=$(date +%s)
  #echo "stopWatch=$stopWatch"

  #backup then temporarily change terminal colors
  #TEMP1=$PS1
  #export PS1="\e[0;32m\]"
}

runModules() {

  echo "installer: running each module in sequence"
  start=$seconds   # start script timer
  # magic loop that calls each fucntion and executes it
  for module in $MODULES ; do \
    $module ; \
  done
  duration=$(( SECONDS - start ))   # stop script timer
  echo "installer: showing some helpful info"
  echo "Current /boot/config.txt settings: "
  vcgencmd get_config int
  echo "showing directory tree"
  sudo tree
  echo "showing codec info"
  for codec in H264 MPG2 WVC1 MPG4 MJPG WMV9 ; do \
    echo "$codec:\t$(vcgencmd codec_enabled $codec)" ; \
  done
  echo "script runtime $duration seconds" #| lolcat
  duration=$(( SECONDS - start ))   # stop script timer

  #return terminal colors to normal
  #PS1=$TEMP1
}

################# ACTUAL run scrip, do all the stuff in the modules above ########################

echo "creating install log"
tmpLog="/tmp/dotfiles-install.log"
#checkRoot | tee -a -i $tmpLog
#checkHelp | tee -a -i $tmpLog
chooseModules | tee -a -i $tmpLog
prepareInstall | tee -a -i $tmpLog
runModules | tee -a -i $tmpLog
echo "installer: exporting log to currrent working directory"
sudo mv $tmpLog $DIR/
echo "installer script finished"
echo "reboot may be needed"
exit

#just a little section to layout my thougts on this config.
#try putting 'pi' as the new user name and see if anything breaks, or if the home folder gets encrypted
#try putting in a username with a space as well, i bet it breaks things
#ask for keyword for system theme and auto generate background, motd, colors?

#count number of lines in output log file and create a "loading" animation that uses the live line-count
#to "calculate" percent finished.

#demonstrate better control over the terminal colors

#I want this pi to have as many use-cases as possible. 
#-provide wifi hotspot if plugged into internet via ethernet
#-provide internet via ethernet port if connected to wifi
#-provide filesharing / streaming in both use-cases (Samba share + miniDLNA)
#-provide vnc desktop for access via phone/tablet/laptop/fredidgerator

#new user first login script?
#Update list of default apps (terminal, browser, etc.): update-alternatives --all

#maybe try the following line to intsall apps 1 by 1 for testing
#for i in package1 package2 package3; do sudo apt-get install -y $i; done

#fix .bashrc and add scrits folder to .bash_aliases or whatever
