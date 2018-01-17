#!/bin/bash

if [ "$(id -u)" == "0" ]; then
    echo "DO NOT RUN THIS AS ROOT" 1>&2
    exit 1;
fi

pip2 install -U --user numpy scipy pandas
pip3 install -U --user numpy scipy pandas
                
pip2 install -U --user matplotlib seaborn
pip3 install -U --user matplotlib seaborn
                
pip2 install -U --user jupyter ipython
pip3 install -U --user jupyter ipython
                
pip2 install -U --user tornado pyzmq pygments
pip3 install -U --user tornado pyzmq pygments
                
pip2 install -U --user pygments pillow pelican
pip3 install -U --user pygments pillow pelican

