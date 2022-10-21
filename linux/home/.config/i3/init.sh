xrandr --output DP-1 --primary --right-of DVI-D-0
xrandr --output HDMI-0 --below DP-1

i3-msg 'workspace "1"; exec /usr/bin/gnome-terminal'
i3-msg 'workspace "2"; exec code' && sleep 3
i3-msg 'workspace "5"; exec /usr/bin/discord' && sleep 3
i3-msg 'workspace "3"; exec firefox'
