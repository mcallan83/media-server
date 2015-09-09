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

# Install Jackett
sudo apt-get install libcurl4-openssl-dev bzip2 -y
wget https://jackett.net/Download/v0.6.4/Jackett.Mono.v0.6.4.tar.bz2
tar -xvf Jackett.Mono.v0.6.4.tar.bz2
sudo mkdir /opt/jackett
sudo chown -R $UNAME:$UNAME /opt/jackett

sudo cp templates/jackett/jackett-init /etc/init.d/jackett
sudo sed -i 's/RUN_AS=USERNAME/RUN_AS='$UNAME'/g' /etc/init.d/jackett
sudo chmod +x /etc/init.d/jackett
sudo update-rc.d jackett defaults
sudo service jackett start
