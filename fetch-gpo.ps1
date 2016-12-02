########## Download latest zip from github ##########
$url = "https://github.com/iadgov/Secure-Host-Baseline/archive/master.zip"
$output = "$env:USERPROFILE\Downloads\master.zip"
$start_time = Get-Date

Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $output
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

########## Download lgpo.exe from microsoft ##########
$url = "https://msdnshared.blob.core.windows.net/media/TNBlogsFS/prod.evol.blogs.technet.com/telligent.evolution.components.attachments/01/4062/00/00/03/65/94/11/LGPO.zip"
$output = "$env:USERPROFILE\Downloads\lgpo.zip"
$start_time = Get-Date
Start-BitsTransfer -Source $url -Destination $output
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

########## Change execution policy for this session only ##########
Set-ExecutionPolicy Unrestricted -Scope Process

########## Unblock downloaded zip files ##########
Unblock-File -Path "$env:USERPROFILE\Downloads\master.zip"
Unblock-File -Path "$env:USERPROFILE\Downloads\lgpo.zip"

########## Extract and rename ##########
$shell = new-object -com shell.application
$zip = $shell.NameSpace("$env:USERPROFILE\Downloads\lgpo.zip")
foreach($item in $zip.items())
{
$shell.Namespace("$env:USERPROFILE\Downloads").copyhere($item)
}
$zip = $shell.NameSpace("$env:USERPROFILE\Downloads\master.zip")
foreach($item in $zip.items())
{
$shell.Namespace("$env:USERPROFILE\Downloads").copyhere($item)
}

Rename-Item $env:USERPROFILE\Downloads\Secure-Host-Baseline-master Secure-Host-Baseline
Remove-Item $env:USERPROFILE\Downloads\LGPO.pdf
Remove-Item $env:USERPROFILE\Downloads\master.zip
Remove-Item $env:USERPROFILE\Downloads\lgpo.zip

########## Load downloaded script ##########
Set-ExecutionPolicy Unrestricted -Scope Process
cd $env:USERPROFILE\Downloads\
. .\Secure-Host-Baseline\Scripts\GroupPolicy.ps1

########## Apply the policies ##########
Invoke-ApplySecureHostBaseline -Path "$env:USERPROFILE\Downloads\Secure-Host-Baseline" -PolicyNames 'Adobe Reader','AppLocker','Certificates','Chrome','EMET','Internet Explorer','Office 2013','Windows','Windows Firewall' -ToolPath "$env:USERPROFILE\Downloads\LGPO.exe"

Remove-Item $env:USERPROFILE\Downloads\Secure-Host-Baseline -Force -Recurse
Remove-Item $env:USERPROFILE\Downloads\LGPO.exe
