#boot config functions
disable_raspi_config_at_boot() {
  if [ -e /etc/profile.d/raspi-config.sh ]; then
    rm -f /etc/profile.d/raspi-config.sh
    sed -i /etc/inittab \
      -e "s/^#\(.*\)#\s*RPICFG_TO_ENABLE\s*/\1/" \
      -e "/#\s*RPICFG_TO_DISABLE/d"
    telinit q
  fi
}

disable_boot_to_scratch() {
  if [ -e /etc/profile.d/boottoscratch.sh ]; then
    rm -f /etc/profile.d/boottoscratch.sh
    sed -i /etc/inittab \
      -e "s/^#\(.*\)#\s*BTS_TO_ENABLE\s*/\1/" \
      -e "/#\s*BTS_TO_DISABLE/d"
    telinit q
  fi
}

WHOME=`whoami`
if [ "$WHOME" != "root" ]
then
  echo "Please run installation as root."
  exit 1
fi

curl http://www.google.com &> /dev/null
if [ $? -ne 0 ]
then
  echo "Please connect to the internet."
  exit 1
fi



#set boot to desktop
update-rc.d lightdm enable 2
sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=.*/autologin-user=pi/"
disable_boot_to_scratch
disable_raspi_config_at_boot

#save working directory and change to /home/pi
working=`pwd`
cd /home/pi

#get necessary dependencies
apt-get update
apt-get upgrade
apt-get install chromium
apt-get install python-dev

#get our directories
git clone https://github.com/ModPi/minecraftModChooser.git
git clone https://github.com/ModPi/piblockly.git

cat /etc/rc.local | grep -v exit > /etc/rc.local
echo "/home/pi/minecraftModChooser/daemon/mcmonitor" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

echo "@chromium /home/pi/piblockly/blockly/apps/code/index.html" >> /etc/xdg/lxsession/LXDE-pi/autostart
echo "@minecraft-pi" >> /etc/xdg/lxsession/LXDE-pi/autostart
echo "@/home/pi/configScripts/fullscreen.sh" >> /etc/xdg/lxsession/LXDE-pi/autostart

cd $working
echo "Pi must be restarted for changes to take effect. Restart now? (y/n)"
read input
if [ input == "y" ]
then
  reboot
fi

exit 0
