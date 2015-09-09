UNAME=$(whoami)
UGROUP=$(id -gn $UNAME)

sudo -v

sudo apt-get update
sudo apt-get upgrade

# Install Avahi
sudo apt-get install avahi-daemon -y
sudo service avahi-daemon restart

# Install Webmin
echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee -a /etc/apt/sources.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" | sudo tee -a /etc/apt/sources.list
wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -

sudo apt-get update
sudo apt-get install webmin -y
sudo sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
