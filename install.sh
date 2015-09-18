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
sudo apt-get install nginx-extras -y
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

sudo rm Jackett.Mono.v0.6.4.tar.bz2
sudo rm -rf Jackett

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

# sudo curl http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key | sudo apt-key add -
# echo "deb http://www.deb-multimedia.org wheezy main non-free" | sudo tee -a /etc/apt/sources.list.d/deb-multimedia.list
# echo "deb http://shell.ninthgate.se/packages/debian wheezy main" | sudo tee -a /etc/apt/sources.list.d/plex.list
# sudo apt-get update -y
# sudo apt-get install deb-multimedia-keyring -y --force-yes
# sudo apt-get update -y
# sudo apt-get install plexmediaserver -y
#
# sudo sed -i 's/PLEX_MEDIA_SERVER_USER=plex/PLEX_MEDIA_SERVER_USER='$UNAME'/g' /etc/default/plexmediaserver
#
# sudo service plexmediaserver restart


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

sudo tee "/etc/nginx/proxy.conf" > /dev/null <<"EOF"
proxy_connect_timeout   59s;
proxy_send_timeout      600;
proxy_read_timeout      36000s;
proxy_buffer_size       64k;
proxy_buffers           16 32k;
proxy_pass_header       Set-Cookie;
proxy_hide_header       Vary;
proxy_busy_buffers_size         64k;
proxy_temp_file_write_size      64k;
proxy_set_header        Accept-Encoding         '';
proxy_ignore_headers    Cache-Control           Expires;
proxy_set_header        Referer                 $http_referer;
proxy_set_header        Host                    $host;
proxy_set_header        Cookie                  $http_cookie;
proxy_set_header        X-Real-IP               $remote_addr;
proxy_set_header        X-Forwarded-Host        $host;
proxy_set_header        X-Forwarded-Server      $host;
proxy_set_header        X-Forwarded-For         $proxy_add_x_forwarded_for;
proxy_set_header        X-Forwarded-Port        '443';
proxy_set_header        X-Forwarded-Ssl         on;
proxy_set_header        X-Forwarded-Proto       https;
proxy_set_header        Authorization           '';
proxy_buffering         off;
proxy_redirect          off;
proxy_http_version      1.1;
proxy_set_header        Upgrade         $http_upgrade;
proxy_set_header        Connection      "upgrade"; 
EOF

sudo tee "/etc/nginx/auth.conf" > /dev/null <<EOF
satisfy any;
allow 127.0.0.1;
auth_basic "Restricted";
auth_basic_user_file /etc/nginx/htpasswd;
EOF

sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

sudo tee "/etc/nginx/sites-available/media" > /dev/null <<EOF
server {
  listen   80;
  server_name    _;
  access_log  /var/log/nginx/access.log;
  # jackett
  location /jackett {
    rewrite (/jackett)$ / break;
    rewrite /jackett/(.*) /$1 break;
    proxy_pass http://localhost:9177;
    proxy_redirect /        /jackett/;
    include /etc/nginx/proxy.conf;
    include /etc/nginx/auth.conf;
  }
  # ajenti
  location /ajenti {
    rewrite (/ajenti)$ / break;
    rewrite /ajenti/(.*) /$1 break;
    proxy_pass http://localhost:8000;
    proxy_redirect /        /ajenti/;
    include /etc/nginx/proxy.conf;
    include /etc/nginx/auth.conf;
  }
  # plex
  location / {
    proxy_pass http://127.0.0.1:32400;
    if ($http_x_plex_device_name = '') {
      rewrite ^/$ http://$http_host/web/index.html;
    }
    include /etc/nginx/proxy.conf;
    include /etc/nginx/auth.conf;
  }
  # deluge
  location /deluge {
    proxy_pass  http://127.0.0.1:8112/;
    proxy_set_header  X-Deluge-Base "/deluge/";
    proxy_cookie_path / /deluge;
    include /etc/nginx/proxy.conf;
    include /etc/nginx/auth.conf;
  }
  # sonarr
  location /sonarr {
      proxy_pass http://localhost:8989;
      include /etc/nginx/proxy.conf;
      include /etc/nginx/auth.conf;
  }
}
EOF

cd /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/media media
cd $SCRIPTPATH

sudo htpasswd -b -c /etc/nginx/htpasswd media $UPASS

sudo service nginx restart
