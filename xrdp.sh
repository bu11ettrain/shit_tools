#!/bin/bash

sudo apt update
sudo apt install xfce4 xfce4-goodies xrdp -y
cd ~ && echo "xfce4-session" | tee .xsession
