#!/bin/bash

#New Dotfiles setup for minimalist i3 desktop
sudo apt update -y && sudo apt dist-upgrade -y
sudo apt install -y tmux git bpytop nmap nethogs wpagui
sudo apt install -y xorg xinit i3-wm i3blocks parcellite volumeicon-alsa compton feh nm-tray pavucontrol alsa-tools dmenu
sudo apt install -y firefox-esr remmina thonny
sudo apt install -y arandr mpv florence xterm locate tilda neovim ranger trash-cli neofetch figlet lolcat cmatrix pi-bluetooth blueman bluealsa network-manager nm-tray wireguard-tools

echo "installing vanity fonts"
sudo apt -y --fix-missing install fonts-ocr-a
sudo fc-cache -f -v 

TARGETUSER=$(whiptail \
  --title "New Encrypted User"  \
  --backtitle "ghostbusker's dotfiles installer" \
  --inputbox "Enter user name." \
  --fullbuttons --nocancel 10 40 username 3>&1 1>&2 2>&3)
export TARGETUSER=$TARGETUSER

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
