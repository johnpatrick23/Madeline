#!/bin/sh

cd ~/..

currentPath=$(pwd)

git clone https://github.com/johnpatrick23/Madeline.git

sudo useradd --no-create-home --shell /bin/false Madeline
mv -f $currentPath/Madeline /etc/Madeline
sudo chown -R Madeline:Madeline /etc/Madeline
sudo chmod -R u+rw /etc/Madeline

cp $currentPath/service/guacchk.service /etc/systemd/system

sudo systemctl daemon-reload
sudo systemctl start guacchk.service
sudo systemctl status guacchk.service

sudo systemctl enable guacchk.service
