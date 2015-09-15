mediaUNAME=$(whoami)
UGROUP=$(id -gn $UNAME)

sudo -v

sudo apt-get update -y
sudo apt-get upgrade -y

echo -n 'Choose a password that will be used to secure various servers:'
read UPASS

# Install Avahi
sudo apt-get install avahi-daemon -y
sudo service avahi-daemon restart

# Install Webmin
# echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee -a /etc/apt/sources.list
# echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" | sudo tee -a /etc/apt/sources.list
# wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -

# sudo apt-get update -y
# sudo apt-get install webmin -y
# sudo sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf

# # diabled until webmin works under nginx reverse proxy
# # echo "webprefix=/webmin" | sudo tee -a /etc/webmin/config
# # echo "webprefixnoredir=1" | sudo tee -a /etc/webmin/config

# sudo /etc/init.d/webmin restart

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

sudo sed -i 's/<Port>8989<\/Port>/<Port>8989<\/Port>\n  <UrlBase>sonarr<\/UrlBase>/g' /home/media/.config/NzbDrone/config.xml

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
sudo apt-get install -y nginx apache2-utils
sudo update-rc.d nginx defaults

sudo rm /etc/nginx/sites-enabled/default
sudo cp templates/nginx/proxy.conf /etc/nginx/proxy.conf
sudo cp templates/nginx/auth.conf /etc/nginx/auth.conf
sudo cp templates/nginx/media /etc/nginx/sites-available/media
cd /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/media media
cd -
sudo service nginx restart

sudo htpasswd -b -c /etc/nginx/htpasswd media $UPASS


# Install Jackett
sudo apt-get install libcurl4-openssl-dev bzip2 -y
sudo wget http://jackett.net/Download/v0.6.4/Jackett.Mono.v0.6.4.tar.bz2
sudo tar -xvf Jackett.Mono.v0.6.4.tar.bz2
sudo mkdir /opt/jackett
sudo mv Jackett/* /opt/jackett
sudo chown -R $UNAME: /opt/jackett

sudo cp templates/jackett/jackett /etc/init.d/jackett
sudo sed -i 's/RUN_AS=username/RUN_AS='$UNAME'/g' /etc/init.d/jackett
sudo chmod +x /etc/init.d/jackett
sudo update-rc.d jackett defaults
sudo service jackett start

