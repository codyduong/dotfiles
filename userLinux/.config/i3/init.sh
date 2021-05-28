xrandr --output DP-0 --primary --right-of DVI-D-0
xrandr --output HDMI-0 --below DP-0

i3-msg 'workspace "1"; exec /usr/bin/gnome-terminal'
i3-msg 'workspace "1"; exec code' && sleep 1
i3-msg 'workspace "3"; exec /usr/bin/discord' && sleep 1
i3-msg 'workspace "2"; exec firefox'
