########## Download latest zip from github ##########
$url = "https://github.com/iadgov/Secure-Host-Baseline/archive/master.zip"
$output = "$env:USERPROFILE\Downloads\master.zip"
$start_time = Get-Date

Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $output
#OR
Start-BitsTransfer -Source $url -Destination $output -Asynchronous

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

########## Change execution policy for this session only ##########
Set-ExecutionPolicy Unrestricted -Scope Process

########## Unblock downloaded zip file ##########
Unblock-File -Path "$env:USERPROFILE\Downloads\master.zip"

########## Extract and rename ##########
$shell = new-object -com shell.application
$zip = $shell.NameSpace("$env:USERPROFILE\Downloads\master.zip")
foreach($item in $zip.items())
{
$shell.Namespace("$env:USERPROFILE\Downloads").copyhere($item)
}

Rename-Item $env:USERPROFILE\Downloads\Secure-Host-Baseline-master Secure-Host-Baseline

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator

   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
   }

########## Load downloaded script ##########
cd $env:USERPROFILE\Downloads\
. .\Secure-Host-Baseline\Scripts\GroupPolicy.ps1

########## Apply the policies ##########
Invoke-ApplySecureHostBaseline -Path '.\Secure-Host-Baseline' -PolicyNames 'Adobe Reader','AppLocker','Certificates','Chrome','EMET','Internet Explorer','Office 2013','Windows','Windows Firewall' -ToolPath '$env:USERPROFILE\Downloads\LGPO.exe'
