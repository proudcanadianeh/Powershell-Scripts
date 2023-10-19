$path = "$env:ProgramFiles\Spotify\Spotify.exe"
$args = "/uninstall /silent"
Start-Process $path $args -wait