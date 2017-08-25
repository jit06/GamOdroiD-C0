#/bin/bash

sed -i -e "s/# setenv m \"vga\"/setenv m \"vga\"/g" /boot/boot.ini
sed -i -e "s/setenv m \"480cvbs\"/# setenv m \"480cvbs\"/g" /boot/boot.ini
sed -i -e "s/setenv hdmioutput \"0\"/setenv hdmioutput \"1\"/g" /boot/boot.ini
reboot
