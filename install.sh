UNAME=$(whoami)
UGROUP=$(id -gn $UNAME)

sudo -v

sudo apt-get update
sudo apt-get upgrade

# Install Avahi
sudo apt-get install avahi-daemon -y
sudo cp ~/templates/avahi/ssh.service /etc/avahi/services/ssh.service
sudo service avahi-daemon restart
