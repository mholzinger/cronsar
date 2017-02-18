#!/bin/bash

# TODO: Write check to look for installed service

# Install sar
sudo apt-get install sysstat
# TODO: Change install command to check for deb/rpm


# Manually edit the sertvice or change with sed
# sudo vi /etc/default/sysstat
# edit ENABLED="false" to ENABLED="true"

sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat 

sudo /etc/init.d/sysstat start

sudo crontab -e
# 
# Collect measurements at 10-minute intervals
#5,15,25,35,45,55   * * * *   /usr/lib/sa/sa1

# run crontab next as non root user
crontab -e
 
# m h  dom mon dow   command
#7,17,27,37,47,57 * * * * /home/bin/pimon.sh
