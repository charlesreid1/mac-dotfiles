#!/bin/sh

echo "Type the email that you would like to associate with the SSH key, then press [ENTER]:"
read SSH_EMAIL

echo "About to generate SSH keys"
sleep 2
if [ -f "$HOME/.ssh/id_rsa" ]; then
    echo "Keys already exist"
else
    yes | ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -C "${SSH_EMAIL}" -N ''
    chmod 700 $HOME/.ssh
    touch $HOME/.ssh/authorized_keys
    chmod 600 $HOME/.ssh/authorized_keys
    echo "Done generating keys"
fi

echo "About to set up scripts directory."
sleep 2
./scripts_setup.sh

echo "About to set up vim."
sleep 2
./vim_setup.sh

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

echo "About to set shell to bash"
if [ -f "/usr/local/bin/bash" ]; then
    BASH="/usr/local/bin/bash"
else
    BASH="/bin/bash"
fi
echo "Found ${BASH}"
sleep 2
chsh -s ${BASH}

