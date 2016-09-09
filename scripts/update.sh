echo ""
echo "--------------------Checking for updates--------------------" &&
echo ""
sudo apt-get -y update &&
sudo apt-get -y upgrade &&
sudo apt-get -y dist-upgrade

echo ""
echo "--------------------Cleaning Up--------------------" &&
echo ""
sudo apt-get -f -y install &&
sudo apt-get -y autoremove --purge &&
sudo apt-get -y autoclean 
