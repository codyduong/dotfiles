# unistalls bloat from w11
Write-Host "Configuring Default Windows Applications..." -ForegroundColor "Yellow"

# Uninstall 3D Builder
Get-AppxPackage "Microsoft.3DBuilder" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.3DBuilder" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Adobe Creative Cloud Express
Get-AppxPackage "AdobeSystemsIncorporated.AdobeCreativeCloudExpress" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "AdobeSystemsIncorporated.AdobeCreativeCloudExpress" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Alarms and Clock
# Get-AppxPackage "Microsoft.WindowsAlarms" -AllUsers | Remove-AppxPackage -AllUsers
# Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.WindowsAlarms" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Amazon Prime Video
Get-AppxPackage "AmazonVideo.PrimeVideo" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "AmazonVideo.PrimeVideo" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Autodesk Sketchbook
Get-AppxPackage "*.AutodeskSketchBook" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "*.AutodeskSketchBook" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Finance
Get-AppxPackage "Microsoft.BingFinance" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.BingFinance" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing News
Get-AppxPackage "Microsoft.BingNews" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.BingNews" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Sports
Get-AppxPackage "Microsoft.BingSports" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.BingSports" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Weather
Get-AppxPackage "Microsoft.BingWeather" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.BingWeather" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bubble Witch 3 Saga
Get-AppxPackage "king.com.BubbleWitch3Saga" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "king.com.BubbleWitch3Saga" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Calendar and Mail
# Get-AppxPackage "Microsoft.WindowsCommunicationsApps" -AllUsers | Remove-AppxPackage -AllUsers
# Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.WindowsCommunicationsApps" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Candy Crush Soda Saga
Get-AppxPackage "king.com.CandyCrushSodaSaga" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "king.com.CandyCrushSodaSaga" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall ClipChamp Video Editor
Get-AppxPackage "Clipchamp.Clipchamp" -AllUsers | Remove-AppxPackage
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Clipchamp.Clipchamp" | Remove-AppxProvisionedPackage -Online

# Uninstall Cortana
Get-AppxPackage "Microsoft.549981C3F5F10" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.549981C3F5F10" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Disney+
Get-AppxPackage "Disney.37853FC22B2CE" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Disney.37853FC22B2CE" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Disney Magic Kingdoms
Get-AppxPackage "*.DisneyMagicKingdoms" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "*.DisneyMagicKingdoms" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Dolby
Get-AppxPackage "DolbyLaboratories.DolbyAccess" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "DolbyLaboratories.DolbyAccess" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Facebook
Get-AppxPackage "Facebook.Facebook*" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Facebook.Facebook*" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Get Office, and it's "Get Office365" notifications
Get-AppxPackage "Microsoft.MicrosoftOfficeHub" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.MicrosoftOfficeHub" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Instagram
Get-AppxPackage "Facebook.Instagram*" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Facebook.Instagram*" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Maps
Get-AppxPackage "Microsoft.WindowsMaps" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.WindowsMaps" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall March of Empires
Get-AppxPackage "*.MarchofEmpires" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "*.MarchofEmpires" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Messaging
# Get-AppxPackage "Microsoft.Messaging" -AllUsers | Remove-AppxPackage -AllUsers
# Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.Messaging" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Mobile Plans
Get-AppxPackage "Microsoft.OneConnect" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.OneConnect" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall OneNote
# Get-AppxPackage "Microsoft.Office.OneNote" -AllUsers | Remove-AppxPackage -AllUsers
# Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.Office.OneNote" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Paint
# Get-AppxPackage "Microsoft.Paint" -AllUsers | Remove-AppxPackage -AllUsers
# Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.Paint" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall People
Get-AppxPackage "Microsoft.People" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.People" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Photos
# Get-AppxPackage "Microsoft.Windows.Photos" -AllUsers | Remove-AppxPackage -AllUsers
# Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.Windows.Photos" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Print3D
Get-AppxPackage "Microsoft.Print3D" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.Print3D" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Skype
Get-AppxPackage "Microsoft.SkypeApp" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.SkypeApp" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall SlingTV
Get-AppxPackage "*.SlingTV" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "*.SlingTV" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Solitaire
Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Spotify
Get-AppxPackage "SpotifyAB.SpotifyMusic" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "SpotifyAB.SpotifyMusic" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall StickyNotes
Get-AppxPackage "Microsoft.MicrosoftStickyNotes" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.MicrosoftStickyNotes" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Sway
Get-AppxPackage "Microsoft.Office.Sway" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.Office.Sway" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall TikTok
Get-AppxPackage "*.TikTok" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "*.TikTok" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Microsoft ToDos
Get-AppxPackage "Microsoft.ToDos" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.ToDos" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Twitter
Get-AppxPackage "*.Twitter" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "*.Twitter" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Voice Recorder
Get-AppxPackage "Microsoft.WindowsSoundRecorder" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.WindowsSoundRecorder" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall XBox
Get-AppxPackage "Microsoft.XboxGamingOverlay" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppxPackage "Microsoft.GamingApp" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.XboxGamingOverlay" | Remove-AppxProvisionedPackage -Online -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.GamingApp" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Your Phone
# Get-AppxPackage "Microsoft.YourPhone" -AllUsers | Remove-AppxPackage -AllUsers
# Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.YourPhone" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Zune Music (Groove)
Get-AppxPackage "Microsoft.ZuneMusic" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.ZuneMusic" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Zune Video
Get-AppxPackage "Microsoft.ZuneVideo" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like "Microsoft.ZuneVideo" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Windows Media Player
# Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null