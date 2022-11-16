#!/bin/sh

get_distribution() {
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"
}

lsb_dist=$( get_distribution )
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

do_upgrade() {

    case "$lsb_dist" in

        debian|raspbian)
            if [ $1 == update ]; then
                apt-get update
            else
                apt-get update
                apt-get upgrade -y
            fi
        ;;
        centos|rhel|sles|almalinux)
            if [ $1 == update ]; then
                dnf check-update
            else
                dnf -y upgrade
            fi
        ;;
        
    esac
}
do_upgrade