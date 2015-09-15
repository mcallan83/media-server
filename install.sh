SCRIPTPATH=$(pwd)

echo -n 'Provide a default password: '
read UPASS

UNAME=$(whoami)
UGROUP=$(id -gn $UNAME)

sudo -v

sudo apt-get update && sudo apt-get upgrade -y

# Base Packages
sudo apt-get install apache2-utils -y
sudo apt-get install apt-transport-https -y
sudo apt-get install avahi-daemon -y
sudo apt-get install bzip2 -y
sudo apt-get install curl -y 
sudo apt-get install libcurl4-openssl-dev -y 
sudo apt-get install nginx -y
sudo apt-get install upstart -y

# Avahi
sudo service avahi-daemon restart

# Sonarr
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb https://apt.sonarr.tv/ master main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install nzbdrone -y

sudo cp $SCRIPTPATH/templates/sonarr/sonarr.conf /etc/init/sonarr.conf
sudo sed -i 's/env uid=USER/env uid='$UNAME'/g' /etc/init/sonarr.conf
sudo sed -i 's/env gid=GROUP/env gid='$UGROUP'/g' /etc/init/sonarr.conf
sudo chmod +x /etc/init/sonarr.conf

sudo sed -i 's/<Port>8989<\/Port>/<Port>8989<\/Port>\n  <UrlBase>sonarr<\/UrlBase>/g' /home/$UNAME/.config/NzbDrone/config.xml

sudo start sonarr

# Jackett
sudo wget http://jackett.net/Download/v0.6.4/Jackett.Mono.v0.6.4.tar.bz2
sudo tar -xvf Jackett.Mono.v0.6.4.tar.bz2
sudo mkdir /opt/jackett
sudo mv Jackett/* /opt/jackett
sudo chown -R $UNAME: /opt/jackett

sudo cp $SCRIPTPATH/templates/jackett/jackett.conf /etc/init/jackett.conf
sudo sed -i 's/env uid=USER/env uid='$UNAME'/g' /etc/init/jackett.conf
sudo sed -i 's/env gid=GROUP/env gid='$UGROUP'/g' /etc/init/jackett.conf
sudo chmod +x /etc/init/jackett.conf

sudo start jackett

# Deluge
sudo add-apt-repository -y ppa:deluge-team/ppa
sudo apt-get update -y
sudo apt-get install deluged deluge-webui -y 

sudo cp $SCRIPTPATH/templates/deluge/deluge.conf /etc/init/deluge.conf
sudo sed -i 's/env uid=USER/env uid='$UNAME'/g' /etc/init/deluge.conf
sudo sed -i 's/env gid=GROUP/env gid='$UGROUP'/g' /etc/init/deluge.conf

sudo cp $SCRIPTPATH/templates/deluge/deluge-web.conf /etc/init/deluge-web.conf
sudo sed -i 's/env uid=USER/env uid='$UNAME'/g' /etc/init/deluge-web.conf
sudo sed -i 's/env gid=GROUP/env gid='$UGROUP'/g' /etc/init/deluge-web.conf

sudo start deluge
sudo start deluge-web

# Plex
sudo curl http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key | sudo apt-key add -
echo "deb http://www.deb-multimedia.org wheezy main non-free" | sudo tee -a /etc/apt/sources.list.d/deb-multimedia.list
echo "deb http://shell.ninthgate.se/packages/debian wheezy main" | sudo tee -a /etc/apt/sources.list.d/plex.list
sudo apt-get update -y
sudo apt-get install deb-multimedia-keyring plexmediaserver -y

sudo sed -i 's/PLEX_MEDIA_SERVER_USER=plex/PLEX_MEDIA_SERVER_USER='$UNAME'/g' /etc/default/plexmediaserver

sudo service plexmediaserver restart

# Nginx
sudo update-rc.d nginx defaults

sudo cp $SCRIPTPATH/templates/nginx/proxy.conf /etc/nginx/proxy.conf
sudo cp $SCRIPTPATH/templates/nginx/auth.conf /etc/nginx/auth.conf

sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

sudo cp $SCRIPTPATH/templates/nginx/media /etc/nginx/sites-available/media
cd /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/media media
cd $SCRIPTPATH

sudo htpasswd -b -c /etc/nginx/htpasswd media $UPASS

sudo service nginx restart
