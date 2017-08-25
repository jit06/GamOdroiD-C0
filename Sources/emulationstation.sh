#/bin/bash

emulationstation

if [ -f /tmp/es-shutdown ]; then
	poweroff
fi

if [ -f /tmp/es-sysrestart ]; then
	reboot
fi
