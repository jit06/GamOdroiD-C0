#/bin/bash

sed -i -e "s/setenv m \"vga\"/# setenv m \"vga\" /g" /boot/boot.ini
sed -i -e "s/# setenv m \"480cvbs\"/setenv m \"480cvbs\" /g" /boot/boot.ini
sed -i -e "s/setenv hdmioutput \"1\"/setenv hdmioutput \"0\"/g" /boot/boot.ini
reboot
