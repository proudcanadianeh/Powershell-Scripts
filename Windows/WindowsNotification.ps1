[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon

$objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$objNotifyIcon.BalloonTipIcon = "Info" 
$objNotifyIcon.BalloonTipText = "Notification Message" 
$objNotifyIcon.BalloonTipTitle = "Notification Title"
$objNotifyIcon.Visible = $True

$objNotifyIcon.ShowBalloonTip(10000)

Start-Sleep -Seconds 30  #This is because some remote management tools will end the process as soon as the script completes and kill the notification