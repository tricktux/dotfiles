#!/usr/bin/env sh

# File:           aws_arch_ami_setup.sh
# Description:    Setup an Amazon Web Services archlinux virtual machine
# Author:		    Reinaldo Molina
# Email:          rmolin88 at gmail dot com
# Revision:	    0.0.0
# Created:        Wed Jun 12 2019 06:40
# Last Modified:  Wed Jun 12 2019 06:40

# update
sudo pacman -Syu

# mariadb
sudo pacman -S mariadb
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb
mysqladmin -u root password 'root'
mysql -u root -p
CREATE DATABASE patientdocconnect;
USE patientdocconnect;

# java
sudo pacman -S j{re,re8,dk,dk8}-openjdk

# gradle
sudo pacman -S gradle

# install tmux
sudo pacman -S tmux
