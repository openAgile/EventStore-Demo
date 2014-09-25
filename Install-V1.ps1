Param(
    [string]$uri)

cuninst CommitStreamVersionOne
cinst CommitStreamVersionOne -source https://www.myget.org/F/versionone/
sqlcmd -Q "use VersionOne; DBCC CHECKIDENT(NumberSource_Story, RESEED, 47665)"
copy -force c:\versionone\user.config c:\inetpub\wwwroot\VersionOne
iisreset


Invoke-WebRequest `
		    -Uri $uri `
		    -Headers @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($staging.username+":"+$staging.password ))} `
		    -Method Put `
		    -InFile $productFile `
		    -Body '<Asset><Attribute name="Name" act="set">Hello world!</Attribute></Asset>'
