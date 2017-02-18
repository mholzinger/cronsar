#!/bin/bash

mydate=`date +"%Y-%m-%d"`

currentuser=$( whoami )
LOGDIR=/home/$currentuser/log/pimon

if [ ! -d $LOGDIR ];then
    mkdir -p $LOGDIR
fi

VERSION="V1"

SEND=0
export LC_TIME="POSIX"

# Get basic stats for the device
timestamp=`sar -p | grep -v Average | tail -1 | awk ' { print $1 } '`
uptime=`cat /proc/uptime | cut -d" " -f1`
temp=`cat /sys/class/thermal/thermal_zone0/temp | awk -v FS=" " '{print $1/1000""}'`
cpu=`sar -p | grep $timestamp | grep -v Average | awk ' { print 100-$8 } '`
load=`sar -p -q | grep $timestamp | grep -v Average | awk ' { print $4";"$5";"$6 } '`
mem=`sar -p -r | grep $timestamp | grep -v Average  | awk ' { print $4 } '`
network=`sar -p -n DEV | grep $timestamp | grep eth0 | grep -v Average | awk ' { print $3";"$4 } '`

printf "timestamp=$timestamp\nuptime=$uptime\ntemp=$temp\ncpu=$cpu\nload=$load\nmem=$mem\nnetwork=$network\n"

#Get volume stats
# set a volume path
le_volume=boot

DATAdev=`mount | grep $le_volume | cut -d " " -f 1 | cut -b 6-8`
DATAload=`sar -p -d | grep $timestamp | grep $DATAdev | grep -v Average | awk ' { print $10 } '`
DATA=`df -lh | awk '{if ($6 == "/$le_volume") { print $5 }}' | head -1 | cut -d'%' -f1`

printf "DATAdev=$DATAdev\nDATAload=$DATAload\n$DATA\n"

ROOTFS=`df -lh | awk '{if ($1 == "/dev/root") { print $5 }}' | head -1 | cut -d'%' -f1`

pingRTT=`sudo ping -c 1 -q google.com | grep rtt | cut -d " " -f 4 | cut -d "/" -f 1`


# Let's write a csv table to our log (if not exist)
if [ ! -f "$LOGDIR/pimon-$datestamp.send.$VERSION" ];
then
    echo "Date,Timestamp,Uptime,Temp,CPU,Load,Memory,Network,Boot Drive,SD,SD Load,/boot,/root,rootFS,pingRTT," >> $LOGDIR/pimon-$datestamp.send.$VERSION
fi

echo "$mydate $timestamp,$uptime,$temp,$cpu,$load,$mem,$network,boot_drive,$DATAdev,$DATAload,$DATA,rootfs,$ROOTFS,$pingRTT," >> $LOGDIR/pimon-$datestamp.send.$VERSION

