Param(
    [string]$vm_name = 'v1newvm',
    [string]$vm_username = 'azureuser',
    [string]$vm_password = 'Azureuser1',
    [string]$azure_service_name = ''
)

if ($azure_service_name -eq '') {
    $azure_service_name = $vm_name
}

echo $vm_name
echo $azure_service_name

$secpasswd = ConvertTo-SecureString $vm_password -AsPlainText -Force
$cred=New-Object System.Management.Automation.PSCredential ($vm_username, $secpasswd)

New-AzureQuickVM `
    -ServiceName $azure_service_name `
    -Windows `
    -Name $vm_name `
    -ImageName 3a50f22b388a4ff7ab41029918570fa6__Windows-Server-2012-Essentials-20131217-enus `
    -Password $cred.GetNetworkCredential().Password `
    -AdminUsername $cred.UserName `
    -InstanceSize Medium `
    -Location "South Central US" `
    -WaitForBoot