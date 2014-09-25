

cuninst CommitStreamVersionOne
cinst CommitStreamVersionOne -source https://www.myget.org/F/versionone/
sqlcmd -Q "use VersionOne; DBCC CHECKIDENT(NumberSource_Story, RESEED, 47665)"
copy -force c:\versionone\user.config c:\inetpub\wwwroot\VersionOne
iisreset


Invoke-WebRequest `
		    -Uri "http://v1commitstream.cloudapp.net/VersionOne/rest-1.v1/Data/Story" `
		    -Headers @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("admin:admin" ))} `
		    -Method Post `
		    -Body '<Asset><Attribute name="Name" act="set">Hello world!</Attribute></Asset>'
