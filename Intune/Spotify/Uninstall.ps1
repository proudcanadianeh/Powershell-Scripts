Stop-Process Spotify -ErrorAction SilentlyContinue

$path = "C:\Program Files\Spotify\Spotify.exe"
$args = "/uninstall /silent"
Start-Process $path $args -wait