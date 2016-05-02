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
sudo apt-get -y autoremove &&
sudo apt-get -y autoclean 

#echo ""
#echo "--------------------Installing Google Chrome--------------------" &&
#echo ""
#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
#sudo dpkg -i google-chrome-stable_current_amd64.deb &&
#rm -f google-chrome-stable_current_amd64.deb

echo ""
echo "--------------------Installing latest linux kernel, shutter, oracle-java, serial-term, vim, \
	xcompmgr for ToS and fastboot, gvfs (mtp mount of android devices)--------------------" &&
echo "--------------------Compiz to Slide Windows CPU_INDICATOR Guake, git, gParted, eclipse cdt, \
avr-gcc, preload, cutecom, vlc, nmap (ip scanning)--------------------" &&
echo ""
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test # latest gcc-g++
sudo add-apt-repository -y ppa:neovim-ppa/unstable # neovim 
sudo add-apt-repository -y ppa:shutter/ppa 
sudo add-apt-repository -y ppa:webupd8team/java #java ppa
sudo add-apt-repository -y ppa:nilarimogard/webupd8 #grive ppa
sudo add-apt-repository -y ppa:thefanclub/grive-tools #grive-gui ppa
sudo add-apt-repository -y ppa:libreoffice/ppa
sudo add-apt-repository -y ppa:ubuntu-wine/ppa
sudo add-apt-repository -y ppa:pi-rho/dev # tmux ppa
sudo apt-get -y update &&
sudo apt-get dist-upgrade &&
sudo apt-get -y install python-software-properties software-properties-common \
mesa-utils build-essential linux-headers-$(uname -r) \
oracle-java7-installer gtkterm xcompmgr xscreensaver xscreensaver-data-extra \
xscreensaver-gl grive grive-tools shutter android-tools-adb android-tools-fastboot \
git gparted g++ gcc-avr binutils-avr gdb-avr avr-libc avrdude preload nmap arandr \
corefonts VideoDriver vcrun2005 python-dev python-pip python3-dev \
python3-pip neovim tilda tmux g++-5 autoconf chromium-browser curl
sudo pip3 install neovim
# not in this list wine1.7 winetricks guake libreOffice
# see install_vim.sh if you want vim.

# kernel dev
sudo apt-get install libncurses5-dev gcc make git exuberant-ctags bc libssl-dev
 
#rm /usr/lib/gvfs/gvfsd-smb-browse
#download git
#git clone vimrc
#update
#copy fixed sources.list
#also on sources.list remove cannonical partners
#download chromium-browser
#download tilda
#g++6
#purge firefox
#run vim_source_install.sh
#download vim curl
#download vim plugins
#curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	#https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#copy .profile
#copy .vimrc
#add stty -ixon to bashrc
#download tmux, autoconf
#additional drivers
#autostart tilda, chrome
#associate text editor with vim
#sudo apt install libboost-all-dev


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
sudo apt-get -y autoremove &&
sudo apt-get -y autoclean 

#echo ""
#echo "--------------------Downloading Google Drive------------------------------------------"
#echo ""
#mkdir ~/Google_Drive
#cd ~/Google_Drive
#grive -a

#Also go to ~/.config/lxsession/Lubuntu and modify autostart <@sh /address/of/autostart.sh> remember to \
	#make autostart executable and that is in drive
#also go to run the hplip from drive to install printer drivers
#also download arduino from website repository version is too old
#also download .inputrc and .vimrc and copy both to ~/
#also go to ~/.config/openbox/lubuntu-rc.xml and find the line command>lxpanelctl menu</command> \
	#substitute key bind with "Super_L"
#also install thinkorswim 
#also add the cpu monitor to to task bar
