#!/bin/bash
#
# Run like a regular old script, no args needed:
#
# ./set_machine_name.sh
#
# It will prompt you for the hostname you want to set.

# darwin
echo "The current hostname is ${HOSTNAME}"
echo "Type the new hostname you want for your machine, then press [ENTER]:"
read newhostname

sudo scutil --set ComputerName    "${newhostname}"
sudo scutil --set HostName        "${newhostname}"
sudo scutil --set LocalHostName	  "${newhostname}"

sudo echo "127.0.0.1 ${newhostname}" >> /etc/hosts

echo "The new hostname is ${newhostname}"
echo "Try logging out and back in."

