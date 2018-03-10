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
echo "please define the destination device or partition to burn to e.g. /dev/sdXY"
read device
echo "Burning $dest/$dest.img to $device."
(unzip -p $dest/$dest.zip $file | sudo dd of=$device bs=1M status=progress) 2>&1 | whiptail --gauge && sync #new way of showing status
#(unzip -p $dest/$dest.zip $file | pv | sudo dd of=$device bs=1M) 2>&1 | whiptail --gauge && sync #old way of showing status
echo "Done burning $dest/$dest.img to $device..."
}

dljessie(){
dest="Jessie"
file="2017-07-05-raspbian-jessie.img"
echo "Downloading Raspbian $dest from $jessieurl"
mkdir -P $dest
wget -c $jessieurl -O $dest/$dest.zip
echo "Done downloading Raspbian $dest..."
burn
}

dlstretch(){
dest="Stretch"
file="Stretch.img"
echo "Downloading Raspbian $dest from $jessieurl"
mkdir -P $dest
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
mkdir -p Backups
dest="Backups/Backup.img"
sudo dd if=/dev/$inputfile of=$dest
#sudo dd if=$dest/$dest.img of=$device bs=1m && sync

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

menudriven(){
echo "installer.sh menu"
echo "STIL W.I.P."
}


### This is where the functions get executed: ###
simple
#backup
#restore
#menudriven
### This is where the functions stop getting executed: ###