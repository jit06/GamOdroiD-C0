#!/bin/bash

PIN=75
GPIO=/sys/class/gpio
ACCESS=$GPIO/gpio$PIN
LOWBAT=780
CHARGING=1020

if [ ! -d $ACCESS ] ; then
	echo $PIN > $GPIO/export
	echo out > $ACCESS/direction
	echo 0 > $ACCESS/value
fi

while true
do
	ADCVAL=$(cat /sys/class/saradc/saradc_ch0)
#	echo "value : $ADCVAL"	
	# charging
	if [ $ADCVAL -gt $CHARGING ]; then
		echo 1 > $ACCESS/value
	else
		# low bat
		if [ $ADCVAL -lt $LOWBAT ]; then
			echo 1 > $ACCESS/value
			sleep 1
			echo 0 > $ACCESS/value
		else
			echo 0 > $ACCESS/value
		fi
	fi
 
	sleep 2
done
