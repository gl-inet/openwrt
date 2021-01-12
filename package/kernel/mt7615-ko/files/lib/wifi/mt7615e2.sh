#!/bin/sh
append DRIVERS "mt7615e2"

. /lib/wifi/mt7615e.inc

# Hua Shao : This script assumes that:
# 1. 7615 is the only wifi device.
# 2. DBDC=1
# 3. MULTI_PROFILE=1
# 4. DEFAULT_5G=1, which means ra0/rai0/rae0 -> 5G, rax0/ray0/raz0 -> 2G
# If your product is not exactly the same as above, then some minor fixes are necessary.

prepare_mt7615e2() {
	#prepare_ralink_wifi mt7615e
	:
}

scan_mt7615e2() {
	#scan_ralink_wifi mt7615e mt7615e
	:
}

disable_mt7615e2() {
	uci2dat -d mt7615e2 -f /etc/Wireless/RT2860/RT2860_2G.dat > /tmp/uci2dat.log
	# unregister hwnat hook.
	# iwpriv rax0 set hw_nat_register=0 2>/dev/null || true

	cd /sys/class/net/
	for vif in apcli*; do
		if echo "$vif" | grep -q -e "apclix[0-9]" ; then
			ifconfig $vif down;
		fi
	done
	for vif in ra*; do
		if echo "$vif" | grep -q -e "rax[0-9]" ; then
			ifconfig $vif down;
			if [ "$vif" = "rax1" ];then
				ubus call network.interface.guest remove_device "{\"name\":\"$vif\"}" 2>/dev/null
			else
				ubus call network.interface.lan remove_device "{\"name\":\"$vif\"}" 2>/dev/null
			fi
		fi
	done
}

check_guest_device() {
	config_get network $1 network
	[ "$network" != "guest" ] && return

	config_get disabled $1 disabled "0"
	[ "$disabled" == "1" ] && return

	ifconfig br-guest up
	ifup_guest=1
}

br_guest() {
	ifup_guest=0
	config_load wireless
	config_foreach check_guest_device wifi-iface
	[ "$ifup_guest" == "0" ] && ifconfig br-guest down
}

enable_mt7615e2() {
	br_guest

	cd /sys/class/net/
	for vif in ra*; do
		uci_node=$(uci show wireless | grep "wireless..*.ifname='$vif'" | sed s/.ifname.*//g 2>/dev/null)
		disabled=$(uci get $uci_node.disabled 2>/dev/null)
		[ -z "$uci_node" -o "$disabled" == "1" ] && continue
		
		if echo "$vif" | grep -q -e "rax[0-9]" ; then
			ifconfig $vif up;
			network=`uci get $uci_node.network`
			[ -z "$network" ] && continue
			ubus call network.interface.$network add_device "{\"name\":\"$vif\"}"
			
			local tmp=$(brctl show | grep $vif)   
			if [ x"$tmp" == x"" ]
			then
				echo "add $vif to br-$network" >> /tmp/wifi.log                 
				for i in `seq 1 10`
				do
					local status=`brctl show br-$network`
					[ -n "$status" ] && break
					sleep 1
				done
				brctl addif br-$network $vif 2 >> /tmp/wifi.log
			fi
		fi
	done
	for vif in apcli*; do
		uci_node=$(uci show wireless | grep "wireless.sta.ifname='$vif'" | sed s/.ifname.*//g 2>/dev/null)
                disabled=$(uci get $uci_node.disabled 2>/dev/null)
                [ -z "$uci_node" -o "$disabled" == "1" ] && continue

		if echo "$vif" | grep -q -e "apclix[0-9]" ; then
			ifconfig $vif up;
			network=$(uci get $uci_node.network 2>/dev/null)
			ifconfig | grep -E "rax0|rax1" || $(ifconfig rax0 up && ifconfig rax0 down)
			[ -n "$network" ] && ubus call network.interface.$network add_device "{\"name\":\"$vif\"}"
			[ -n "$network" ] && ubus call network.interface.$network add_device "{\"name\":\"$vif\"}"

			mode=`uci get glconfig.bridge.mode 2>/dev/null`
			[ "$mode" == "relay" -o "$mode" == "wds" ] && $(sleep 4;ubus call network.interface.$network add_device "{\"name\":\"$vif\"}") &
		fi
	done

	if [ "$ifup_guest" == "1" ];then
		ubus call network.interface.guest down
		ubus call network.interface.guest up
	fi
	ra0_disabled=`uci get wireless.@wifi-iface[0].disabled 2>/dev/null`
	[ "$ra0_disabled" = "1" ] && ifconfig ra0 down

	# register hwnat hook.
	# iwpriv rax0 set hw_nat_register=1 2>/dev/null || true
}

detect_mt7615e2() {
	ssid2g=mt7615e-2g-`ifconfig eth0 | grep HWaddr | cut -c 51- | sed 's/://g'`
    [ -e /etc/config/wireless ] && return
         cat <<EOF
config wifi-device      mt7615e2
        option type     mt7615e2
        option vendor   ralink
        option band     2.4g
        option channel  0
        option autoch   2
        option g256qam  1
        option e2paccmode 2

config wifi-iface
        option device   mt7615e2
        option ifname   rax0
        option network  lan
        option mode     ap
        option ssid     $ssid2g
        option encryption psk2
        option key      12345678

EOF
}


