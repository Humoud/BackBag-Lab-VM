# Purpose: Sets timezone to UTC, sets hostname, creates/joins domain.
# Source: https://github.com/StefanScherer/adfs2

param ([String] $joinDomain, [String] $ad_ip, [String] $domain, [String] $netbiosName, [String] $isDC)

$ProfilePath = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
$box = Get-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name "ComputerName"
$box = $box.ComputerName.ToString().ToLower()

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting timezone to UTC..."
c:\windows\system32\tzutil.exe /s "UTC"

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Checking if Windows evaluation is expiring soon or expired..."
. c:\vagrant\scripts\fix-windows-expiration.ps1

If (!(Test-Path $ProfilePath)) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling the Invoke-WebRequest download progress bar globally for speed improvements." 
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) See https://github.com/PowerShell/PowerShell/issues/2138 for more info"
  New-Item -Path $ProfilePath | Out-Null
  If (!(Get-Content $Profilepath| % { $_ -match "SilentlyContinue" } )) {
    Add-Content -Path $ProfilePath -Value "$ProgressPreference = 'SilentlyContinue'"
  }
}

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling IPv6 on all network adatpers..."
Get-NetAdapterBinding -ComponentID ms_tcpip6 | ForEach-Object {Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6}
Get-NetAdapterBinding -ComponentID ms_tcpip6 
# https://support.microsoft.com/en-gb/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f

# AD Setup: Create/Join Domain
if ((gwmi win32_computersystem).partofdomain -eq $false) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Current domain is set to 'workgroup'. Time to join the domain!"
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) My hostname is $env:COMPUTERNAME"
  if ($isDC -eq '1') {
    . c:\vagrant\scripts\create-domain.ps1 -ip $ad_ip -domain $domain -netbiosName $netbiosName
  }
  elseif ($joinDomain -eq '1') {
    . c:\vagrant\scripts\join-domain.ps1 -ad_ip $ad_ip -domain $domain
  }
}

# Add cmd\powershell here to right click context menu with 
regedit /s c:\vagrant\scripts\rightclick.reg