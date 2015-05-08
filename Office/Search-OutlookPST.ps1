#Searches the registery and returns the file path of all PST files attached to an Outlook profile on the computer.
Try
{
    Write-Host "Looking for PST Files attached to Outlook profiles"
    $pstRegKey = Get-ChildItem HKCU:\software\microsoft\office -rec -ea SilentlyContinue | 
    Where-Object {(Get-ItemProperty -path $_.PSPath) -match "001f6700"} |
    select -Property PSPath
    $pstValue = Get-ItemPropertyValue -Path $pstRegKey.PSPath -Name 001f6700

    if($pstRegKey.Count -lt 1)
    {
        Write-Host "Found 1 PST File"
        [Text.Encoding]::Unicode.GetString($pstValue)
    }
    else
    {
        Write-Host "Found" $pstValue.Count "PST Files"
        for($i = 0; $i -lt $pstValue.Count; $i++)
        {
            [Text.Encoding]::unicode.getString($pstValue[$i])
        }
    }
}
Catch
{
    Write-Host "No PST Files were found"
}