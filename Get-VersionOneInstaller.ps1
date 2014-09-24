$localPath = "Temp - $($env:computername)"
$tempPath = "C:\$localPath"
if(-not (Test-Path $tempPath)) { mkdir $tempPath }
$v1url = "https://s3.amazonaws.com/versionone-chocolatey/VersionOne.Setup-Ultimate-14.3.0.18.cs.exe"
$installerPath = "$tempPath\VersionOne.Setup-Ultimate-14.3.0.18-cs.exe"
Invoke-WebRequest $v1url -OutFile $installerPath
iex "& '$installerPath' -Quiet:2 -LogFile:C:\\log\\log.log"
