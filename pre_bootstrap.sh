#!/bin/sh

echo "About to change Mac settings"
sleep 2
./mac_settings.sh

echo "About to install and set up python"
sleep 2
./python_install.sh
./python_setup.sh

echo "About to run brew installation script"
sleep 2
./brew_install.sh


# Change shell to bash
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
    BASH="/usr/local/bin/bash"
else
    BASH="/bin/bash"
fi
echo "About to set shell to ${BASH}"
sleep 2
chsh -s ${BASH}

