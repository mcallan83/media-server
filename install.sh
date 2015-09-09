UNAME=$(whoami)
UGROUP=$(id -gn $UNAME)

sudo -v

sudo apt-get update -y
sudo apt-get upgrade -y

# Install Avahi
sudo apt-get install avahi-daemon -y
sudo service avahi-daemon restart

# Install Webmin
echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee -a /etc/apt/sources.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" | sudo tee -a /etc/apt/sources.list
wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -

sudo apt-get update -y
sudo apt-get install webmin -y
sudo sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
sudo /etc/init.d/webmin restart

# Install Sonarr
sudo add-apt-repository -y ppa:ermshiperete/monodevelop
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb http://update.nzbdrone.com/repos/apt/debian master main" | sudo tee -a /etc/apt/sources.list

sudo apt-get update -y
sudo apt-get -y install mono-complete nzbdrone

sudo cp templates/sonarr/sonarr-init /etc/init.d/nzbdrone
sudo chown $UNAME: /etc/init.d/nzbdrone
sudo chmod +x /etc/init.d/nzbdrone
if [ ! -d "/var/run/nzbdrone" ]; then
	sudo mkdir /var/run/nzbdrone
fi
sudo sed -i 's/RUN_AS=USERNAME/RUN_AS='$UNAME'/g' /etc/init.d/nzbdrone
sudo chmod +x /etc/init.d/nzbdrone
sudo update-rc.d nzbdrone defaults
sudo service nzbdrone start >/dev/null 2>&1

# Install Deluge
sudo add-apt-repository -y ppa:deluge-team/ppa
sudo apt-get update -y
sudo apt-get -y install deluged deluge-webui

sudo cp templates/deluge/deluge.conf /etc/init/deluge.conf
sudo sed -i 's/env uid=USER/env uid='$UNAME'/g' /etc/init/deluge.conf
sudo sed -i 's/env gid=GROUP/env gid='$UGROUP'/g' /etc/init/deluge.conf

sudo cp templates/deluge/deluge-web.conf /etc/init/deluge-web.conf
sudo sed -i 's/env uid=USER/env uid='$UNAME'/g' /etc/init/deluge-web.conf
sudo sed -i 's/env gid=GROUP/env gid='$UGROUP'/g' /etc/init/deluge-web.conf

sudo start deluge
sudo start deluge-web

# Install Plex
sudo apt-get install curl -y
sudo curl http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key | sudo apt-key add -
echo "deb http://www.deb-multimedia.org wheezy main non-free" | sudo tee -a /etc/apt/sources.list.d/deb-multimedia.list
echo "deb http://shell.ninthgate.se/packages/debian wheezy main" | sudo tee -a /etc/apt/sources.list.d/plex.list
sudo apt-get update -y
sudo apt-get install deb-multimedia-keyring -y --force-yes
sudo apt-get update -y
sudo apt-get install plexmediaserver -y
sudo sed -i 's/PLEX_MEDIA_SERVER_USER=plex/PLEX_MEDIA_SERVER_USER='$UNAME'/g' /etc/default/plexmediaserver
sudo service plexmediaserver restart

# Install Nginx
sudo apt-get update -y
sudo apt-get install -y nginx
sudo update-rc.d nginx defaults

