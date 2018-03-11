#!/bin/bash
source installer.config
$INSTLL $depends
whiptail --textbox README.md 12 80

simple(){
echo "Running simple installer."


burn(){
device=0
#clear
df
echo "please define the destination device or partition to burn $dest.img from $dest/$dest.zip to e.g. /dev/sdXY"
read device
clear
echo "Burning $dest/$dest.img to $device."
echo "Please note that this shows no status (for now.. thats still w.i.p.)"
echo "just be patient and wait until the writing is done please.."
unzip -p $dest/$dest.zip $file | sudo dd of=$device bs=1M && sync
#(unzip -p $dest/$dest.zip $file | sudo dd of=$device bs=1M) 2>&1 | whiptail --gauge && sync #old way of showing status
echo "Done burning $dest/$dest.img to $device..."
}

dljessie(){
dest="Jessie"
file="2017-07-05-raspbian-jessie.img"
echo "Downloading Raspbian $dest from $jessieurl"
mkdir $dest
wget -c $jessieurl -O $dest/$dest.zip
echo "Done downloading Raspbian $dest..."
burn
}

dlstretch(){
dest="Stretch"
file="Stretch.img"
echo "Downloading Raspbian $dest from $jessieurl"
mkdir $dest
wget -c $jessieurl -O $dest/$dest.zip
echo "Done downloading Raspbian $dest..."
burn
}

dljessie
#dlstretch
}

backup(){
echo "Create a backup image"
df
echo "Please specify the drive or partition to back up without `/dev/` e.g. like: sdXY"
read inputfile
mkdir Backups
dest="Backups/Backup.img"
sudo dd if=/dev/$inputfile of=$dest
}

restore(){
echo "Restore from a backup image"
df
echo "Please specify the drive or partition to restore to without `/dev/` e.g. like: sdXY"
read dest
inputfile="Backups/Backup.img"
sudo dd if=$inputfile of=/dev/$dest
#sudo dd if=$dest/$dest.img of=$device bs=1m && sync
}

modify(){
echo "Modidfy the currently running raspbian os."
sudo apt-get update && sudo apt-get upgrade -y

aptget(){
$INSTLL byobu
$INSTLL npm
$INSTLL wget
$INSTLL curl
$INSTLL modipy
$INSTLL lsb-release
$INSTLL git
#$INSTLL python-pip
#$INSTLL nodejs
#$INSTLL npm
#$INSTLL xrdp
$INSTLL quassel-core
$INSTLL quassel-client
$INSTLL aria2
$INSTLL openssh-sftp-server
}

vpnserver(){
pi-vpn(){
curl -L http://install.pivpn.io | bash
}
openvpn-install(){
wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh
}
pi-vpn
#openvpn-install
}

npem(){
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash
$INSTLL nodejs
sudo npm install npm@latest -g
}

NOTIFY-CLI(){
sudo npm install notify-cli
}

WEATHER-CLI(){
	sudo npm install weather-cli
}

ponysay(){
	cd
	git clone https://github.com/erkin/ponysay
	cd ponysay
	sudo ./setup.py --freedom=partial install
	ponysay "done"
}

retropie(){
echo "Cloning RetroPie-Setup git."
cd
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
chmod +x retropie_setup.sh
sudo ./retropie_setup.sh
cd
}

aptget
npem
NOTIFY-CLI
WEATHER-CLI
ponysay
#vpnserver
retropie
}


menudriven(){
choice=0
echo "installer.sh menu"
echo "STIL W.I.P."
choice = $(whiptail --title "Menu" --menu "Choose an option" 25 78 16 \
"BURN" "Download and burn a copy of Raspbian." \
"BACKUP" "Create a backup of a drive or partition." \
"RESTORE" "Restore a drive or partition from a backup.img." \
"MODIFY" "Install tools and modify current running system." )

if [ $choice = "BURN" ];
then
echo "you chose: " $choice
#simple
fi
if [ $choice = "BACKUP" ];
then
echo "you chose: " $choice
#backup
fi
if [ $choice = "RESTORE" ];
then
echo "you chose: " $choice
#restore
fi
if [ $choice = "MODIFY" ];
then
echo "you chose: " $choice
modify
fi
}


### This is where the functions get executed: ###
#menudriven
#simple
#backup
#restore
modify

#menudriven

### This is where the functions stop getting executed: ###
