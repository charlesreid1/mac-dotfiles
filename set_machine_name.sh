#!/bin/bash
#
# Run like a regular old script, no args needed:
#
# ./set_machine_name.sh
#
# It will prompt you for the hostname you want to set.

if [ "$(id -u)" != "0" ]; then
    echo ""
    echo ""
    echo "This script should be run as root!"
    echo ""
    echo ""
    exit 1;
fi

# darwin
echo "The current hostname is ${HOSTNAME}"
echo "Type the new hostname you want for your machine, then press [ENTER]:"
read newhostname

scutil --set ComputerName    "${newhostname}"
scutil --set HostName        "${newhostname}"
scutil --set LocalHostName	  "${newhostname}"

echo "127.0.0.1 ${newhostname}" >> /etc/hosts

echo "The new hostname is ${newhostname}"
echo "Try logging out and back in."

