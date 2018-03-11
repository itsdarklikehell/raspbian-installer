#!/bin/bash
source installer.config
sudo apt-get install $depends
whiptail --textbox README.MD 12 80

simple(){
echo "Running simple installer."


burn(){
device=0
#clear
df
echo "please define the destination device or partition to burn $dest.img from $dest/$dest.zip to e.g. /dev/sdXY"
read device
echo "Burning $dest/$dest.img to $device."
echo "Please note that this shows no status(for now(w.i.p.))"
echo "just be patient please.."
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
sudo apt-get install -y byobu
sudo apt-get install -y npm
sudo apt-get install -y wget
sudo apt-get install -y curl
sudo apt-get install -y modipy
sudo apt-get install -y lsb-release
sudo apt-get install -y git
sudo apt-get install -y python-pip
sudo apt-get install -y nodejs
sudo apt-get install -y npm
sudo apt-get install -y xrdp
sudo apt-get install -y quassel-core
sudo apt-get install -y quassel-client
sudo apt-get install -y aria2
}

retropie(){
echo "Cloning RetroPie-Setup git."
cd
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
chmod +x retropie_setup.sh
#sudo ./retropie_setup.sh
cd
}

aptget
#retropie
}


menudriven(){
echo "installer.sh menu"
echo "STIL W.I.P."
}


### This is where the functions get executed: ###
simple
#backup
#restore
modify

#menudriven

### This is where the functions stop getting executed: ###
