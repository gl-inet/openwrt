#!/bin/sh
# this file will be included into mt7615e2.sh and mt7615e5.sh

disable_mt7615e() {
	cd /sys/class/net/

	# disable apcli interfaces
	for vif in apcli*; do
			ifconfig $vif down;
	done
	# disable ap interfaces
	for vif in ra*; do
			ifconfig $vif down;
			ubus call network.interface.lan remove_device "{\"name\":\"$vif\"}"
	done

	cd -
}


enable_mt7615e() {
	cd /sys/class/net/
	uci2dat -d mt7615e2 -f /etc/Wireless/RT2860/RT2860_2G.dat > /tmp/uci2dat.log
	uci2dat -d mt7615e5 -f /etc/Wireless/RT2860/RT2860_5G.dat >> /tmp/uci2dat.log

	ifconfig ra0 up # ra0 is the root vif

	# enable ap interfaces
	for vif in ra*; do
		ifconfig $vif up;
		ubus call network.interface.lan add_device "{\"name\":\"$vif\"}"
		local tmp=$(brctl show | grep $vif)
		if [ x"$tmp" == x"" ]
		then
			echo "add $vif to br-lan" >> /tmp/wifi.log
			brctl addif br-lan $vif
		fi
	done

	# enable apcli interfaces
	for vif in apcli*; do
		ifconfig $vif up;
	done
	cd -
}
