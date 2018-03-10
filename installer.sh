#!/bin/bash
source installer.config
sudo apt-get install $depends
whiptail --textbox README.MD 12 80

simple(){
echo "Running simple installer."


extract(){
echo "Extracting $dest.img from $dest.zip to folder $dest"
unzip -j $dest.zip $file -d $dest/$dest.img
cd $dest
}

burn(){
clear
df
echo "please define the destination to burn to e.g. /dev/sdX"
read device

#dd if=$dest/$dest.img of=$device


echo "Burning $dest/$dest.img to $device."


}

dljessie(){
dest="Jessie"
file="Jessie.img"
echo "Downloading Raspbian $dest from $jessieurl"
mkdir $dest
wget $jessieurl -O $dest/$dest.zip
echo "Done downloading Raspbian $dest..."
extract
burn
}

dlstretch(){
dest="Stretch"
file="Stretch.img"
echo "Downloading Raspbian $dest from $jessieurl"
mkdir $dest
wget $jessieurl -O $dest/$dest.zip
echo "Done downloading Raspbian $dest..."
extract
burn
}

dljessie
#dlstretch
}

menudriven(){
echo "installer.sh menu"
echo "STIL W.I.P."
}


### This is where the functions get executed: ###

simple
#menudriven

### This is where the functions stop getting executed: ###