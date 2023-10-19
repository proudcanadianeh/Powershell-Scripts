# Define the URL for the Spotify installer
$url = "http://download.spotify.com/SpotifyFullSetup.exe"

# Define the path where the installer will be saved
$outfile = "$env:TEMP\SpotifyFullSetup.exe"

# Download the Spotify installer
Invoke-WebRequest -Uri $url -OutFile $outfile

# Run the Spotify installer
Start-Process -FilePath $outfile -ArgumentList "/extract `"C:\Program Files\Spotify`"" -wait


$TargetFile = "$env:ProgramFiles\Spotify\Spotify.exe"
$ShortcutFile = "$env:AllUsersProfile\Microsoft\Windows\Start Menu\Programs\Spotify.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()