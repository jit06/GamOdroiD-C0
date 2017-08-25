#!/bin/bash

############## function ############
function fstab
{
    echo "fstab and filesystem"

    mkdir -p /mnt/states
    mkdir -p /mnt/ressources

    cp /root/GameOdroid/fstab /etc/fstab

    sed -i "s/#RAMLOCK=yes/RAMLOCK=yes/" /etc/default/tmpfs
    sed -i "s/#RAMSHM=yes/RAMSHM=yes/" /etc/default/tmpfs
}


function uptodate
{
    echo "update"
    apt-get update
    apt-get upgrade
    apt-get dist-upgrade
}


function syspackages
{
    echo "syspackages"

    apt-get install xorg \
                    xf86-video-mali-odroid \
                    libump-odroid \
                    mali450-odroid \
                    evilwm \
                    libgl-odroid \
                    libglew-odroid \
                    libdri2-odroid \
                    alsa-utils \
                    unzip \
                    git \
                    build-essential \
                    zlib1g-dev \
                    libpng12-0 \
                    libpng12-dev \
		    python \
		    python-dev \
		    python-pip \
		    psmisc \
		    antimicro-odroid \
		    sudo

    # custom X org conf
    wget http://oph.mdrjr.net/meveric/other/C1/xorg.conf -O /etc/X11/xorg.conf

    # evdev for python used by reicast-joyconfig
    pip install evdev
}

function emulators
{
    echo "emulators"
    apt-get install retroarch-odroid \
                    libretro-pcsx-rearmed \
                    libretro-fbalpha \
                    libretro-gambatte \
                    libretro-gpsp \
                    libretro-mednafen-pce-fast \
                    libretro-nestopia \
                    libretro-picodrive \
                    libretro-pocketnes \
                    libretro-genesis-plus-gx \
                    libretro-mednafen-ngp

    apt-get install reicast-odroid
}

function emulators_glupen64_compile
{
    echo "glupen 64"

    git clone --depth=1 -c http.sslVerify=false https://github.com/loganmc10/GLupeN64.git
    cd GLupeN64
    platform="odroid" make -j4
    cp glupen64_libretro.so /usr/local/share/retroarch/cores/
    cd ..
    rm -Rf GLupeN64
}

# slightly faster than building from source
function emulators_glupen64_meveric
{
    wget https://oph.mdrjr.net/meveric/other/C1/cores/glupen64_libretro.so -O /usr/local/share/retroarch/cores/glupen64_libretro.so
}


function nativegames
{
    echo "native games"
    apt-get install hurrican-odroid \
    		    hcraft-odroid \
    		    frogatto-odroid \
		    frogatto-odroid-data \
    	  	    smw-odroid \
    		    astromenace astromenace-odroid-launcher \
    		    neverball neverball-odroid-launcher \
    		    shmupacabra-odroid \
    	 	    aquaria-odroid \
		    rvgl-odroid \
		    jk3-odroid \
		    openjazz-odroid \
		    supertuxkart-odroid-launcher \
		    etr-odroid \
                    mars-odroid \
                    puzzlemoppet-odroid \
                    opentyrian-odroid

    wget http://oph.mdrjr.net/meveric/repository/all/pushover-odroid_0.0.5-1_armhf.deb
    sudo dpkg -i pushover-odroid_0.0.5-1_armhf.deb
}

# Attract mode does not work on C1 because of missing glBlendEquationSeparateOES and glBlendFuncSeparateOES in LibFSML
function userinterface_bad
{
    echo "user interface"

    apt-get install libfreetype6 \
                    libfreetype6-dev \
                    libavcodec57 \
                    libavcodec-dev \
                    libavformat57 \
                    libavformat-dev \
                    libswscale4 \
                    libswscale-dev \
                    libjpeg-dev \
                    libopenal1 \
                    libopenal-dev

    git clone --depth 1 -c http.sslVerify=false https://github.com/mickelson/attract attract
    cd attract
    # if make faile because of freetype, add the CFLAGS : -I/usr/include/freetype2
    make USE_GLES=1
    make install
    cd ..
    rm -Rf attract
}

# emulationstation from retropie so we have video support and custom splash screen
function userinterface
{
    # install deps
    apt-get install libboost-system-dev \
                    libboost-filesystem-dev \
                    libboost-date-time-dev \
                    libboost-locale-dev \
                    libfreeimage-dev \
                    libfreetype6 \
                    libfreetype6-dev \
                    libeigen3-dev \
                    libcurl4-openssl-dev \
                    libasound2-dev \
                    fonts-droid \
                    libvlc-dev \
                    libvlccore-dev \
                    vlc-nox\
                    libsdl2-2.0-0 \
                    libsdl2-dev \
                    libasound2 \
                    libasound2-dev \
                    cmake

    # retropie's emlationstation with video support and custom splash
    git clone -c http.sslVerify=false --recursive https://github.com/retropie/EmulationStation EmulationStation

    # custom svg file converted to c++ char array with with http://tools.garry.tv/bin2c/
    cp splash_svg.cpp EmulationStation/data/converted/

    cd EmulationStation
    cmake .
    make
    make install

    mkdir -p /root/.emulationstation/themes
    cd /root/.emulationstation/themes

    # download theme
    git clone --depth 1 -c http.sslVerify=false https://github.com/TMNTturtleguy/ComicBook_4-3 ComicBook
    git clone --depth 1 -c http.sslVerify=false https://github.com/RetroPie/es-theme-carbon-nometa CarbonNoMeta
    git clone --depth 1 -c http.sslVerify=false https://github.com/AmadhiX/es-theme-eudora-bigshot BigShot
    git clone --depth 1 -c http.sslVerify=false https://github.com/RetroPie/es-theme-pixel Pixel
    git clone --depth 1 -c http.sslVerify=false https://github.com/HerbFargus/es-theme-tronkyfran Tronkyfran

    mkdir -p /mnt/ressources/downloaded_images
    cd /root/.emulationstation
    ln -s /mnt/ressources/downloaded_images .
}


function localtools
{
    echo "local tools"

    cd /root/GameOdroid
    git clone https://github.com/hardkernel/wiringPi
    cd wiringPi
    ./build

    cd /root/GameOdroid
    # remove 1wire driver to free gpio pin 21
    echo "blacklist w1_gpio" >> /etc/modprobe.d/blacklist-odroid.conf

    # copy antimicro profiles for games that need mouse and/or Esc key
    cp *.joystick.amgp /root/

    git clone https://github.com/jit06/gpio_joypad
    cd gpio_joypad
    gcc -o gpio_joypad gpio_joypad.c -lwiringPi -lpthread
}

function bootini
{
    echo "boot ini"
    cp boot.ini /boot/boot.ini

}

function startup
{
    # add custom tools
    cp gpio_joypad /usr/local/bin
    cp battery.sh /usr/local/bin

    # handle auto-login to X
    mkdir /etc/systemd/system/getty@tty1.service.d
    cp systemd_autostart.conf /etc/systemd/system/getty@tty1.service.d/override.conf

    cp bash_profile /root/.profile
    cp xinitrc /root/.xinitrc

    systemctl set-default multi-user.target
}

function optimize_system
{
    echo "optimize system"

    # custom asound.conf with more buffer to limit sound stuttering in Reicast and glupen64
    cp asound.conf /etc/

    # remove text from bash login
    echo "" > /etc/motd

    # make journald log to ram
    cp journald.conf /etc/systemd/

    # free space
    apt-get clean
}
####################################


########## Install script ##########
# first step : prepare the system
fstab;reboot
uptodate;reboot
syspackages

# Games !!
emulators
emulators_glupen64_meveric
nativegames

# Game launcher
userinterface

# some specific tools
localtools

# Boot config file 
bootini

# launch everything at start
startup

# Finalize & clean up
optimize_system
