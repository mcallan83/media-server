SCRIPTPATH=$(pwd)

UNAME=$(whoami)
UGROUP=$(id -gn $UNAME)

echo -n 'Provide a default password: '
read UPASS

sudo -v

sudo apt-get update && sudo apt-get upgrade -y

################################################################################
# Base Directories
################################################################################

DIR = /home/$UNAME/Media

sudo mkdir -p $DIR
sudo mkdir -p $DIR/Movies
sudo mkdir -p $DIR/TVShows
sudo mkdir -p $DIR/Downloads
sudo mkdir -p $DIR/Downloads/Complete
sudo mkdir -p $DIR/Downloads/Incomplete
sudo mkdir -p $DIR/Downloads/Complete/Movies
sudo mkdir -p $DIR/Downloads/Complete/TV

sudo chown -R $UNAME:$UGROUP $DIR
sudo chmod -R 775 $DIR

################################################################################
# Base Packages
################################################################################

sudo apt-get install apache2-utils -y
sudo apt-get install apt-transport-https -y
sudo apt-get install avahi-daemon -y
sudo apt-get install bzip2 -y
sudo apt-get install curl -y
sudo apt-get install git-core -y
sudo apt-get install libcurl4-openssl-dev -y
sudo apt-get install nginx -y
sudo apt-get install python -y
sudo apt-get install python-software-properties -y
sudo apt-get install upstart -y


################################################################################
# Ajenti
################################################################################

wget http://repo.ajenti.org/debian/key -O- | sudo apt-key add -
echo "deb http://repo.ajenti.org/ng/debian main main ubuntu" | sudo tee -a /etc/apt/sources.list
sudo apt-get update -y
sudo apt-get install ajenti -y

sudo sed -i 's/"enable": true/"enable": false/g' /etc/ajenti/config.json

sudo service ajenti restart


################################################################################
# Avahi
################################################################################

sudo service avahi-daemon restart


################################################################################
# Couch Potato
################################################################################

cd /opt
sudo git clone https://github.com/RuudBurger/CouchPotatoServer.git couchpotato
cd $SCRIPTPATH

sudo chown -R $UNAME: /opt/couchpotato
sudo chmod -R 755 /opt/couchpotato

sudo tee "/etc/init/couchpotato.conf" > /dev/null <<EOF
description "Upstart Script: CouchPotato"
start on runlevel [2345]
stop on runlevel [016]
setuid $UNAME
setgid $UGROUP
exec python /opt/couchpotato/CouchPotato.py
EOF
sudo chmod +x /etc/init/couchpotato.conf

sudo service couchpotato start


################################################################################
# Deluge
################################################################################

sudo add-apt-repository -y ppa:deluge-team/ppa
sudo apt-get update -y
sudo apt-get install deluged deluge-webui -y

sudo tee "/etc/init/deluge.conf" > /dev/null <<EOF
description "Upstart Script: Deluge"
start on runlevel [2345]
stop on runlevel [016]
exec start-stop-daemon -S -c $UNAME:$UGROUP -k 022 -x /usr/bin/deluged -- -d
EOF
sudo chmod +x /etc/init/deluge.conf

sudo tee "/etc/init/deluge-web.conf" > /dev/null <<EOF
description "Upstart Script: Deluge Web"
start on started deluge
stop on stopping deluge
exec start-stop-daemon -S -c $UNAME:$UGROUP -k 027 -x /usr/bin/deluge-web
EOF
sudo chmod +x /etc/init/deluge-web.conf

sudo service deluge start
sudo service deluge-web start

################################################################################
# Jackett
################################################################################

sudo wget http://jackett.net/Download/v0.6.4/Jackett.Mono.v0.6.4.tar.bz2
sudo tar -xvf Jackett.Mono.v0.6.4.tar.bz2
sudo mkdir /opt/jackett
sudo mv Jackett/* /opt/jackett
sudo chown -R $UNAME: /opt/jackett

sudo tee "/etc/init/jackett.conf" > /dev/null <<EOF
description "Upstart Script: Jackett"
start on runlevel [2345]
stop on runlevel [016]
setuid $UNAME
setgid $UGROUP
exec mono /opt/jackett/JackettConsole.exe
EOF
sudo chmod +x /etc/init/jackett.conf

sudo service jackett start


################################################################################
# Plex
################################################################################

sudo curl http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key | sudo apt-key add -
echo "deb http://www.deb-multimedia.org wheezy main non-free" | sudo tee -a /etc/apt/sources.list.d/deb-multimedia.list
echo "deb http://shell.ninthgate.se/packages/debian wheezy main" | sudo tee -a /etc/apt/sources.list.d/plex.list
sudo apt-get update -y
sudo apt-get install deb-multimedia-keyring -y --force-yes
sudo apt-get update -y
sudo apt-get install plexmediaserver -y

sudo sed -i 's/PLEX_MEDIA_SERVER_USER=plex/PLEX_MEDIA_SERVER_USER='$UNAME'/g' /etc/default/plexmediaserver

sudo service plexmediaserver restart


################################################################################
# Sonarr
################################################################################

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb https://apt.sonarr.tv/ master main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install nzbdrone -y

sudo tee "/etc/init/sonarr.conf" > /dev/null <<EOF
description "Upstart Script: Sonarr"
start on runlevel [2345]
stop on runlevel [016]
setuid $UNAME
setgid $UGROUP
exec mono /opt/NzbDrone/NzbDrone.exe
EOF
sudo chmod +x /etc/init/sonarr.conf

#sudo sed -i 's/<Port>8989<\/Port>/<Port>8989<\/Port>\n  <UrlBase>sonarr<\/UrlBase>/g' /home/$UNAME/.config/NzbDrone/config.xml

sudo service sonarr start


################################################################################
# Nginx
################################################################################

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
