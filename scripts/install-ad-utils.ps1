# Purpose: Install tools on the Windows AD server.
# At the bottom of this script you can see which functions will be executed.
# Modify to fit your needs.

$badbloodPath = "C:\Tools\BadBlood.zip"
mkdir C:\Tools\
#############################################################################################
# Helper function to create shortcuts
function Set-Shortcut([String] $src, [String] $dst) {
  $WshShell = New-Object -comObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($dst)
  $Shortcut.TargetPath = $src
  $Shortcut.Save()
}
#############################################################################################
function Get-BadBlood {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading BadBlood.zip..."
  Try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/davidprowe/BadBlood/archive/refs/heads/master.zip',
      $badbloodPath
    )
    Expand-Archive -LiteralPath $badbloodPath -DestinationPath 'C:\Tools'
    del $badbloodPath
    # Create Shortcut
    Set-Shortcut -src 'C:\Tools\BadBlood-master' -dst 'C:\Users\vagrant\Desktop\BadBlood.lnk'
  } Catch { 
    Write-Host "Badblood Download failed"
  }
}

#############################################################################################
## Think of the below as "main"
## Include or exclude functions as you please

Get-BadBlood

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Utilties installation complete!"