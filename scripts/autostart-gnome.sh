xscreensaver -no-splash&
# Start vnc server service
x0vncserver -display :0 -passwordfile ~/.vnc/passwd&
# pcmanfm --daemon-mode
# Start cmus in "daemon" mode
tmux new-session -s cmus -d -n cmus -d "/usr/bin/cmus $@"&
sleep 10s
killall conky
conky -c "/home/reinaldo/.conky/Gotham/Gotham"&
sshfs odroid@copter-server:/ /home/reinaldo/.mnt/copter-server&
