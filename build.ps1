Param(
    [string]$vm_username,
    [string]$vm_password,
    [string]$vm_name = 'v1CommitStream',
    [string]$azure_service_name = 'v1CommitStream',
    [string]$scriptPath = 'Install-V1.ps1' )
    
cd $Env:WORKSPACE 
write-Host ("winRMCert- "+[System.DateTime]::Now.ToString("hh:mm:ss"))
$winRMCert = (Get-AzureVM -ServiceName $azure_service_name -Name $vm_name | select -ExpandProperty vm).DefaultWinRMCertificateThumbprint
$azureX509cert = Get-AzureCertificate -ServiceName $azure_service_name -Thumbprint $winRMCert -ThumbprintAlgorithm sha1

$certTempFile = [IO.Path]::GetTempFileName()
$azureX509cert.Data | Out-File $certTempFile
write-Host ("certToImport- "+[System.DateTime]::Now.ToString("hh:mm:ss"))

$certToImport = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $certTempFile

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
$store.Certificates.Count
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$store.Add($certToImport)
$store.Close()

write-Host ("Cleanup cert file- "+[System.DateTime]::Now.ToString("hh:mm:ss"))
Remove-Item $certTempFile

rm -re -fo VersionOne.ChocolateyPackage
git clone git@github.com:versionone/VersionOne.ChocolateyPackage.git --branch S-47665_FeaturePackage --single-branch

$version=gc VERSION

$fileName="VersionOne.Setup-Ultimate-$version.cs.exe"
echo "Uploading $fileName to S3"
Write-S3Object -BucketName versionone-chocolatey -File $fileName -Key $fileName -PublicReadOnly

cd VersionOne.ChocolateyPackage

$url="https://s3.amazonaws.com/versionone-chocolatey/VersionOne.Setup-Ultimate-#version#.cs.exe"
$feature="CommitStreamVersionOne"

.\build.ps1 $version $url $feature

cd $Env:WORKSPACE
echo "Inside: $Env:WORKSPACE"
pwd

$uri = Get-AzureWinRMUri -ServiceName $azure_service_name -Name $vm_name

$secpwd = ConvertTo-SecureString $vm_password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($vm_username, $secpwd)

echo "Connecting to $uri"

Invoke-Command `
-ConnectionUri $uri.ToString() `
-Credential $credential `
-FilePath $scriptPath
-ArgumentList 'http://v1commitstream.cloudapp.net/VersionOne/rest-1.v1/Data/Story/'

