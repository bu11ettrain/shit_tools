#!/bin/bash
#bash -i <(curl -s https://raw.githubusercontent.com/bu11ettrain/shit_tools/main/xrdp.sh)

sudo apt update
sudo apt install xfce4 xfce4-goodies xrdp -y
cd ~ && echo "xfce4-session" | tee .xsession
sudo systemctl restart xrdp
