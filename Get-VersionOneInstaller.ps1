cuninst CommitStreamVersionOne
cinst CommitStreamVersionOne -source https://www.myget.org/F/versionone/
sqlcmd -Q "use VersionOne; DBCC CHECKIDENT(NumberSource_Story, RESEED, 47665)"
copy -force c:\versionone\user.config c:\inetpub\wwwroot\VersionOne
iisreset
