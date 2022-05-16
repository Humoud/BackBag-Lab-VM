# IIS Server setups. Installs tools as well.

mkdir C:\Tools\

function Set-Shortcut([String] $src, [String] $dst) {
  $WshShell = New-Object -comObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($dst)
  $Shortcut.TargetPath = $src
  $Shortcut.Save()
}
#############################################################################################
function Install-Choco {
  If (-not (Test-Path "C:\ProgramData\chocolatey")) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Chocolatey"
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
  } else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Chocolatey is already installed."
  }
}
#############################################################################################
function Install-ChocoEssentials {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing essential choco packages..."
  ##########################################################
  $pkgs = 'NotepadPlusPlus',
          '7zip',
          'git',
          'GoogleChrome',
          'vscode.portable'
  ForEach ($pkgName in $pkgs)
  {
    choco install -y --limit-output --ignore-checksums --no-progress $pkgName
  }
  RefreshEnv
  $desk = 'C:\users\vagrant\desktop\'
  Set-Shortcut -src 'C:\ProgramData\chocolatey\bin' -dst $desk'ChocoBins.lnk'
}
#############################################################################################
function Install-IIS {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing IIS..."
  # Get-WindowsFeature -Name Web-*
  # Get-WindowsOptionalFeature -Online -FeatureName "IIS-*" | findstr "FeatureName"
  dism /online /enable-feature /featurename:IIS-WebServer /all
  dism /online /enable-feature /featurename:IIS-HttpRedirect /all
  dism /online /enable-feature /featurename:IIS-WebDAV /all
  dism /online /enable-feature /featurename:IIS-WebSockets /all
  dism /online /enable-feature /featurename:IIS-ApplicationInit /all
  dism /online /enable-feature /featurename:IIS-NetFxExtensibility /all
  dism /online /enable-feature /featurename:IIS-NetFxExtensibility45 /all
  dism /online /enable-feature /featurename:IIS-ISAPIExtensions /all
  dism /online /enable-feature /featurename:IIS-ISAPIFilter /all
  dism /online /enable-feature /featurename:IIS-ASPNET /all
  dism /online /enable-feature /featurename:IIS-ASPNET45 /all
  dism /online /enable-feature /featurename:IIS-ASP /all
  dism /online /enable-feature /featurename:IIS-CGI /all
  dism /online /enable-feature /featurename:IIS-CertProvider /all
  dism /online /enable-feature /featurename:IIS-BasicAuthentication /all
  dism /online /enable-feature /featurename:IIS-WindowsAuthentication /all
  dism /online /enable-feature /featurename:IIS-DigestAuthentication /all
  dism /online /enable-feature /featurename:IIS-ClientCertificateMappingAuthentication /all
  dism /online /enable-feature /featurename:IIS-IISCertificateMappingAuthentication /all
  dism /online /enable-feature /featurename:IIS-URLAuthorization /all
  dism /online /enable-feature /featurename:IIS-ManagementConsole /all
  dism /online /enable-feature /featurename:IIS-IPSecurity /all
  dism /online /enable-feature /featurename:IIS-ServerSideIncludes /all
  dism /online /enable-feature /featurename:IIS-FTPServer /all
  dism /online /enable-feature /featurename:IIS-FTPSvc /all
}
#############################################################################################
function Get-WebShells {
  mkdir C:\Tools\webshells

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading webshells..."
  Try {
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/samratashok/nishang/raw/master/Antak-WebShell/antak.aspx',
      'C:\Tools\webshells\antak.aspx')
    
  } Catch {
    Write-Host "Webshells download failed..."
  }
  $desk = 'C:\users\vagrant\desktop\'
  Set-Shortcut -src 'C:\Tools\' -dst $desk'Tools.lnk'
}

################################################################################################

Install-Choco
Install-ChocoEssentials
Install-IIS
Get-WebShells