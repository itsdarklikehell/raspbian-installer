#!/bin/bash
source installer.config
sudo apt-get install $depends
whiptail --textbox README.MD 12 80

simple(){
echo "Running simple installer."


extract(){
echo "Extracting $dest.zip to folder $dest"
unzip $dest.zip -d $dest
cd $dest
}

burn(){
echo "STILL W.I.P."
echo "Burning FILE to DEVICE."
}

dljessie(){
dest="Jessie"
echo "Downloading Raspbian $dest from $jessieurl"
mkdir $dest
wget $jessieurl -O $dest/$dest.zip
echo "Done downloading Raspbian $dest..."
extract
cd $dest
burn
}

dlstretch(){
dest="Stretch"
echo "Downloading Raspbian $dest from $jessieurl"
mkdir $dest
wget $jessieurl -O $dest/$dest.zip
echo "Done downloading Raspbian $dest..."
extract
cd $dest
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