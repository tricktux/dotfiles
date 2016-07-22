#!/bin/sh
# Requirement 1 have downloaded jdk
# Requirement 2 set jdk folder name in var jdk
# uncomment this code below if you dont want to set up jdk8
jdk=jdk1.8.0_91
# sudo mkdir /usr/lib/jvm
# sudo mv $jdk /usr/lib/jvm/$jdk
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/$jdk/bin/java" 2
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/$jdk/bin/javac" 2
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/$jdk/bin/javaws" 2
sudo chmod a+x /usr/bin/java
sudo chmod a+x /usr/bin/javac
sudo chmod a+x /usr/bin/javaws
sudo chown -R root:root /usr/lib/jvm/$jdk
sudo update-alternatives --config java
sudo update-alternatives --config javac
sudo update-alternatives --config javaws

# Package dependencies
# sudo apt-get install lib32stdc++6 lib32ncurses5 lib32z1
