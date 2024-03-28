# PowerToys Run
komorebic.exe float-rule exe "PowerToys.PowerLauncher.exe"

# Disable steamwebhelper, this is a background process which sometimes gets tiled
komorebic.exe float-rule exe "steamwebhelper.exe"

# hizashi
komorebic.exe float-rule exe "hizashi.exe"

# git-credential-manager popup
komorebic.exe float-rule exe "git-credential-manager.exe"

# fusion 360
# komorebic.exe float-rule title "Save"
komorebic.exe float-rule class "Qt624QWindowIcon"

# ultimaker cura
komorebic.exe float-rule title "Abort print"
komorebic.exe float-rule class "Qt5152QWindowIcon"

# snip
komorebic.exe float-rule exe "SnippingTool.exe"

