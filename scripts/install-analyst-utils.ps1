# Purpose: Install tools on the Windows Analyst machine.
# At the bottom of this script you can see which functions will be executed.
# Modify to fit your needs.

# Paths below are used for packages that are installed manually by the script
$pestudioPath     = "C:\Tools\pestudio.zip"
$zimmermanPath    = "C:\Tools\Get-ZimmermanTools.zip"
$cyberChefPath    = "C:\Tools\CyberChef.zip"
$vsCommunityPath  = "C:\Tools\vs_community.exe"
$corkamiPath      = "C:\users\vagrant\desktop\corkami.zip"
$ghostpackPath    = "C:\Tools\ghostpack.zip"
$sysInternalsPath = "C:\Tools\SysInternals.zip"
$bloodhoundPath   = "C:\Tools\Bloodhound.zip"
$neo4jPath        = "C:\Tools\neo4j.zip"
$pythonPath       = "C:\Python310"
mkdir C:\Tools\
#############################################################################################
#############################################################################################
# Helper functions

# Helper function to create shortcuts
function Set-Shortcut([String] $src, [String] $dst) {
  $WshShell = New-Object -comObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($dst)
  $Shortcut.TargetPath = $src
  $Shortcut.Save()
}

# Helper function to update PATH env var
function Update-PathEnvVar([String] $path){
  $mOldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
  $mNewPath = "$mOldPath;$path"
  Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $mNewPath
  $uOldPath = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path
  $uNewPath = "$uOldPath;$path"
  Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH -Value $uNewPath
}

#############################################################################################
# Install Choco
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
# Choco packages to install
# Add or Remove packages as you like
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
function Install-Python {
  # https://docs.python.org/3/using/windows.html#installing-without-ui
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing Python..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.10.4/python-3.10.4-amd64.exe',
      'C:\Users\vagrant\Downloads\python.exe')

    Start-Process -FilePath "C:\Users\vagrant\Downloads\python.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 TargetDir=$pythonPath Include_doc=0 Include_test=0" -Wait -NoNewWindow
    del C:\Users\vagrant\Downloads\python.exe
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Python installation successful!"
  } Catch {
    Write-Host "Python download failed :("
  }
}
#############################################################################################
function Install-AnalysisMiscTools {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing analysis misc tools..."
  ##########################################################
  $pkgs = 'processhacker',
          'resourcehacker.portable',
          'yara',
          'die'
          # 'dotpeek' Exception of type 'System.OutOfMemoryException' was thrown.
  #########################################################
  ForEach ($pkgName in $pkgs)
  {
    choco install -y --limit-output --ignore-checksums --no-progress $pkgName
  }
}
#############################################################################################
function Install-Burp {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing Burp..."
  ##########################################################
  $pkgs = 'burp-suite-free-edition'
  #########################################################
  ForEach ($pkgName in $pkgs)
  {
    choco install -y --limit-output --ignore-checksums --no-progress $pkgName
  }
}
#############################################################################################
function Install-NetworkAnalysisTools {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing Network Analysis Tools..."
  ##########################################################
  $pkgs = 'wireshark',
          'network-miner'
  #########################################################
  ForEach ($pkgName in $pkgs)
  {
    choco install -y --limit-output --ignore-checksums --no-progress $pkgName
  }
}
#############################################################################################
function Install-DebuggerDisassembler {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing Debuggers and Disassemblers..."
  ##########################################################
  $pkgs = 'ghidra',
          'x64dbg.portable',
          'dnspy'
          # 'dotpeek' Exception of type 'System.OutOfMemoryException' was thrown.
  #########################################################
  ForEach ($pkgName in $pkgs)
  {
    choco install -y --limit-output --ignore-checksums --no-progress $pkgName
  }
}
#############################################################################################
function Install-HasherezadeTools {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing Hasherezade Tools..."
  ##########################################################
  $pkgs = 'pebear',
          'pesieve',
          'hollowshunter'
  #########################################################
  ForEach ($pkgName in $pkgs)
  {
    choco install -y --limit-output --ignore-checksums --no-progress $pkgName
  }
}
#############################################################################################
# Download PEStudio
function Get-PEStudio {
  # https://www.winitor.com/
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading pestudio.zip..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile('https://www.winitor.com/tools/pestudio/current/pestudio.zip', $pestudioPath)
  } Catch { 
    Write-Host "HTTPS connection failed. Switching to HTTP :("
    (New-Object System.Net.WebClient).DownloadFile('http://www.winitor.com/tools/pestudio/current/pestudio.zip', $pestudioPath)
  }
  Expand-Archive -LiteralPath $pestudioPath -DestinationPath 'C:\Tools'
  del $pestudioPath
  $desk = 'C:\users\vagrant\desktop\'
  Set-Shortcut -src 'C:\Tools\pestudio\pestudio.exe' -dst $desk'pestudio.lnk'
}
#############################################################################################
# Download and Run Get-ZimmermanTools
Function Install-ZimmermanTools {
  # https://github.com/EricZimmerman/Get-ZimmermanTools
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Get-ZimmermanTools.zip..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile('https://f001.backblazeb2.com/file/EricZimmermanTools/Get-ZimmermanTools.zip', $zimmermanPath)
    Expand-Archive -LiteralPath $zimmermanPath -DestinationPath 'C:\Tools\ZimmermanTools'
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Running Get-ZimmermanTools.ps1..."
    . c:\tools\ZimmermanTools\Get-ZimmermanTools.ps1 -Dest C:\Tools\ZimmermanTools
    Update-PathEnvVar -path "C:\Tools\ZimmermanTools"
    Update-PathEnvVar -path "C:\Tools\ZimmermanTools\EvtxECmd"
    Update-PathEnvVar -path "C:\Tools\ZimmermanTools\RECmd"
    Update-PathEnvVar -path "C:\Tools\ZimmermanTools\SQLECmd"
  } Catch {
    Write-Host "HTTPS connection failed. Switching to HTTP :("
    (New-Object System.Net.WebClient).DownloadFile('http://f001.backblazeb2.com/file/EricZimmermanTools/Get-ZimmermanTools.zip', $zimmermanPath)
  }
}
#############################################################################################
function Get-CyberChef {
  # https://github.com/gchq/CyberChef
  # Download for offline usage
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading CyberChef.zip..."
  Try {
    # TODO implement functionality to update hardcoded version to latest release
    # Get latest version of Cyberchef
    $latestUri = Invoke-WebRequest -UseBasicParsing -Method Get -Uri ('https://github.com/gchq/CyberChef/releases/latest') -MaximumRedirection 0 -ErrorAction SilentlyContinue
      if ($latestUri.StatusCode -eq 302) 
      {
          $latestUri = $latestUri.Headers.Location 
      } 
      $latestVersion = $latestUri.split("/")[-1]
      $cyberChefLatest = 'https://github.com/gchq/CyberChef/releases/download/'+ $latestVersion +'/CyberChef_'+ $latestVersion +'.zip'
      
    (New-Object System.Net.WebClient).DownloadFile('https://github.com/gchq/CyberChef/releases/download/v9.37.3/CyberChef_v9.37.3.zip', $cyberChefPath)
    Expand-Archive -LiteralPath $cyberChefPath -DestinationPath 'C:\Tools\CyberChef'
    del $cyberChefPath
  } Catch {
    Write-Host "CyberChef download failed..."
  }
}
#############################################################################################
function Get-Ghostpack {
  # https://github.com/r3motecontrol/Ghostpack-CompiledBinaries
  # https://github.com/GhostPack
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Ghostpack.zip..."
  Try {
    (New-Object System.Net.WebClient).DownloadFile('https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/archive/refs/heads/master.zip', $ghostpackPath)
    Expand-Archive -LiteralPath $ghostpackPath 'C:\Tools\'
    del $ghostpackPath
  } Catch {
    Write-Host "Ghostpack download failed..."
  }
}
#############################################################################################
function Get-CorkamiPosters {
  # https://github.com/corkami/pics
  # Beautiful reference
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Corkami Posters..."
  Try {
    (New-Object System.Net.WebClient).DownloadFile('https://github.com/corkami/pics/archive/refs/heads/master.zip', $corkamiPath)
    Expand-Archive -LiteralPath $corkamiPath -DestinationPath 'C:\users\vagrant\desktop\Corkami'
    del $corkamiPath
  } Catch {
    Write-Host "Corkami Posters download failed..."
  }
}
#############################################################################################
function Get-SysInternals {
  # https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading SysInternals..."
  Try {
    (New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SysinternalsSuite.zip', $sysInternalsPath)
    Expand-Archive -LiteralPath $sysInternalsPath -DestinationPath 'C:\Tools\SysInternals'
    del $sysInternalsPath
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating shortcuts for SysInternals..."
    $desk = 'C:\users\vagrant\desktop\'
    Set-Shortcut -src 'C:\Tools\SysInternals\Autoruns64.exe'     -dst $desk'Autoruns64.lnk'
    Set-Shortcut -src 'C:\Tools\SysInternals\procexp64.exe'      -dst $desk'procexp64.lnk'
    Set-Shortcut -src 'C:\Tools\SysInternals\tcpview64.exe'      -dst $desk'tcpview64.lnk'
    Set-Shortcut -src 'C:\Tools\SysInternals\strings64.exe'      -dst $desk'strings64.lnk'
    Set-Shortcut -src 'C:\Tools\SysInternals\Procmon64.exe'      -dst $desk'Procmon64.lnk'
  } Catch {
    Write-Host "SysInternals download failed..."
  }
}
#############################################################################################
function Get-Nim {
  # https://github.com/dom96/choosenim
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Nim..."
  Try {
    mkdir C:\Tools\nim
    # # TODO implement functionality to update hardcoded version to latest release
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/dom96/choosenim/releases/download/v0.8.2/choosenim-0.8.2_windows_amd64.exe',
      'C:\Tools\nim\choosenim.exe')
      # cmd /c C:\Tools\nim\choosenim.exe stable -y --firstInstall --noColor # TODO causes powershell.exe : out of memory error, fix it
  } Catch {
    Write-Host "Choosenim download failed..."
  }
}
#############################################################################################
function Install-CommunityVS2022 {
  # Prepare machine for C# and C++ development
  # https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022
  # https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?view=vs-2022&preserve-view=true
  # https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/versions-and-dependencies
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading and installing Visual Studio..."
  Try {
    (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vs_community.exe', $vsCommunityPath)
    Start-Process -FilePath $vsCommunityPath -ArgumentList (
      '--wait','--passive','--norestart', '--installWhileDownloading',
      '--installPath', 'C:\Tools\VS2022',
      '--add', 'Microsoft.VisualStudio.Component.CoreEditor',
      '--add', 'Microsoft.VisualStudio.Workload.ManagedDesktop', # C#
      '--add', 'Microsoft.Net.Component.4.7.2.SDK',
      '--add', 'Microsoft.Net.Component.4.7.2.TargetingPack',
      '--add', 'Microsoft.VisualStudio.Workload.NativeDesktop',  # C++
      '--includeRecommended'
      ) -Wait
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating shortcut for Visual Studio..."
    $desk = 'C:\users\vagrant\desktop\'
    Set-Shortcust -src 'C:\Tools\VS2022\Common7\IDE\devenv.exe'  -dst $desk'Visual Studio 2022.lnk'
  } Catch {
    Write-Host "VS Community bootstraper Download failed..."
  }
}
#############################################################################################
function Install-GoLang {
  # https://go.dev/doc/install
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading GoLang..."
  Try {
    mkdir C:\Tools\golang
    # # TODO implement functionality to update hardcoded version to latest release
    (New-Object System.Net.WebClient).DownloadFile(
      'https://go.dev/dl/go1.18.1.windows-amd64.msi',
      'C:\Tools\golang\go.msi')
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing GoLang..."
    MsiExec.exe /i C:\Tools\golang\go.msi /qn
  } Catch {
    Write-Host "GoLang download failed..."
  }
}
#############################################################################################
function Install-Bloodhound {
  # https://bloodhound.readthedocs.io/en/latest/installation/windows.html
  # https://community.chocolatey.org/packages/openjdk
  # https://neo4j.com/download-center/#community
  # http://localhost:7474/browser/
  # neo4j: Default login is username 'neo4j' and password 'neo4j'
  Try {
    $wc = New-Object System.Net.WebClient
    #---
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading & installing Bloodhound dependencies: OpenJDK..."
    # TODO set JDK 11 version in a better way 
    choco install -y --limit-output --ignore-checksums --no-progress openjdk11 --version=11.0.15_10
    #--------------------------------------------------------------------------------------
    # Update env vars manually to solve 'Unable to determine the path to java.exe' error
    # TODO did mass update of env vars to solve the issue, maybe there is a better way
    $env:JAVA_HOME = 'C:\Program Files\OpenJDK\openjdk-11.0.15_10' 
    $env:Path += 'C:\Program Files\OpenJDK\openjdk-11.0.15_10\bin'
    [System.Environment]::SetEnvironmentVariable('JAVA_HOME','C:\Program Files\OpenJDK\openjdk-11.0.15_10',
      [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('JAVA_HOME','C:\Program Files\OpenJDK\openjdk-11.0.15_10',
      [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable('Path',$Env:Path+';C:\Program Files\OpenJDK\openjdk-11.0.15_10\bin',
      [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('Path',$Env:Path+';C:\Program Files\OpenJDK\openjdk-11.0.15_10\bin',
      [System.EnvironmentVariableTarget]::User)
    # refreshenv
    #---
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Bloodhound dependencies: Neo4J..."
    $wc.DownloadFile(
      'https://neo4j.com/artifact.php?name=neo4j-community-4.4.6-windows.zip', $neo4jPath)
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Bloodhound dependencies: Neo4J..."
    Expand-Archive -LiteralPath $neo4jPath -DestinationPath 'C:\Tools\'
    cmd /c c:\tools\neo4j-community-4.4.6\bin\neo4j.bat install-service
    cmd /c net start neo4j
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Neo4j: http://localhost:7474/browser/"
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Neo4j: Default creds are: neo4j\neo4j"
    #---
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Bloodhound..."
    $wc.DownloadFile(
      'https://github.com/BloodHoundAD/BloodHound/releases/download/4.1.0/BloodHound-win32-x64.zip',
      $bloodhoundPath)
    Expand-Archive -LiteralPath $bloodhoundPath -DestinationPath 'C:\Tools\'
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Creating shortcut for Bloodhound..."
    Set-Shortcut -src 'c:\Tools\BloodHound-win32-x64\BloodHound.exe' -dst 'c:\users\vagrant\desktop\Bloodhound.lnk'    
    Set-Shortcut -src 'http://localhost:7474/browser/' -dst 'c:\users\vagrant\desktop\Neo4j Setup.lnk'
    # clean up
    del $bloodhoundPath
    del $neo4jPath
  } Catch {
    Write-Host "GoLang download failed..."
  }
}
#############################################################################################
function Install-AtomicRedTeam {
  # https://github.com/redcanaryco/invoke-atomicredteam/wiki/Installing-Atomic-Red-Team
  # https://github.com/redcanaryco/invoke-atomicredteam/wiki/Import-the-Module
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Atomic Red Team..."
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
  Install-AtomicRedTeam -getAtomics -InstallPath "C:\Tools\AtomicRedTeam"
  Set-Shortcut -src 'C:\Tools\AtomicRedTeam' -dst 'C:\users\vagrant\desktop\AtomicRedTeam.lnk'
}
#############################################################################################
function Install-Kansa {
  # https://github.com/davehull/Kansa
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Kansa..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/davehull/Kansa/archive/refs/heads/master.zip',
      'C:\Tools\Kansa.zip')

      Expand-Archive -LiteralPath 'C:\Tools\Kansa.zip' -DestinationPath 'C:\Tools\'
      del 'C:\Tools\Kansa.zip'
      Set-Shortcut -src 'C:\Tools\Kansa-master' -dst 'C:\users\vagrant\desktop\Kansa.lnk'
  } Catch {
    Write-Host "Kansa Download failed"
  }
}
#############################################################################################
function Install-Chainsaw {
  # https://github.com/countercept/chainsaw
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Chainsaw..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/countercept/chainsaw/releases/download/v1.1.7/chainsaw_x86_64-pc-windows-msvc.zip',
      'C:\Tools\chainsaw.zip')

      Expand-Archive -LiteralPath 'C:\Tools\chainsaw.zip' -DestinationPath 'C:\Tools\'
      del 'C:\Tools\chainsaw.zip'
      Set-Shortcut -src 'C:\Tools\chainsaw' -dst 'C:\users\vagrant\desktop\chainsaw.lnk'
  } Catch {
    Write-Host "Chainsaw Download failed"
  }
}
#############################################################################################
function Install-DeepBlueCLI {
  # https://github.com/sans-blue-team/DeepBlueCLI.git
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading DeepBlueCLI..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/sans-blue-team/DeepBlueCLI/archive/refs/heads/master.zip',
      'C:\Tools\DeepBlueCLI.zip')

      Expand-Archive -LiteralPath 'C:\Tools\DeepBlueCLI.zip' -DestinationPath 'C:\Tools\'
      del 'C:\Tools\DeepBlueCLI.zip'
      Set-Shortcut -src 'C:\Tools\DeepBlueCLI-master' -dst 'C:\users\vagrant\desktop\DeepBlueCLI.lnk'
  } Catch {
    Write-Host "DeepBlueCLI Download failed"
  }
}
#############################################################################################
function Install-Jadx {
  # https://github.com/skylot/jadx
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Jadx..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/skylot/jadx/releases/download/v1.4.0/jadx-gui-1.4.0-with-jre-win.zip',
      'C:\Tools\jadx.zip')

    Expand-Archive -LiteralPath 'C:\Tools\jadx.zip' -DestinationPath 'C:\Tools\'
    del 'C:\Tools\jadx.zip'
    Set-Shortcut -src 'C:\Tools\jadx-gui-1.4.0.exe' -dst 'C:\users\vagrant\desktop\jadx-gui.lnk'
  } Catch {
    Write-Host "Jadx Download failed"
  }
}
#############################################################################################
function Install-Frida {
  # https://frida.re/docs/installation/
  # Check dependency
  if (Test-Path -Path $pythonPath) {
    write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Python is already installed..."
  } else {
    write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Python not installed..."
    Install-Python
  }
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing Frida..."
  Start-Process -FilePath "c:\Python310\Scripts\pip.exe" -ArgumentList "install -q frida-tools" -Wait -NoNewWindow
}
#############################################################################################
function Install-HxD {
  # https://mh-nexus.de/en/hxd/
  # https://forum.mh-nexus.de/viewtopic.php?t=885
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading HxD..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'https://mh-nexus.de/downloads/HxDPortableSetup.zip',
      'C:\Tools\hxd.zip')

    Expand-Archive -LiteralPath 'C:\Tools\hxd.zip' -DestinationPath 'C:\Tools\'
    Start-Process -FilePath "C:\Tools\HxDPortableSetup.exe" -ArgumentList '/Silent /ALLUSERS /LANG=English /DIR="C:\Tools\HxD"' -Wait -NoNewWindow
    del 'C:\Tools\hxd.zip'
    del 'C:\Tools\HxDPortableSetup.exe'
  } Catch {
    Write-Host "HxD Download failed"
  }
}
#############################################################################################
function Install-PEFile {
  # https://pypi.org/project/pefile/
  # Check dependency
  if (Test-Path -Path $pythonPath) {
    write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Python is already installed..."
  } else {
    write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Python not installed..."
    Install-Python
  }
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing PEFile..."
  Start-Process -FilePath "c:\Python310\Scripts\pip.exe" -ArgumentList "install -q pefile" -Wait -NoNewWindow
}
#############################################################################################
function Install-APIMonitor {
  # http://www.rohitab.com/downloads
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading API Monitor..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'http://www.rohitab.com/download/api-monitor-v2r13-x86-x64.zip',
      'C:\Tools\api-monitor.zip')

    Expand-Archive -LiteralPath 'C:\Tools\api-monitor.zip' -DestinationPath 'C:\Tools\'
    del 'C:\Tools\api-monitor.zip'
  } Catch {
    Write-Host "HxD Download failed"
  }
}
#############################################################################################
function Install-MalcodeAnalystPack {
  # https://github.com/dzzie/MAP
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Malcode Analyst Pack..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/dzzie/MAP/releases/download/current/map_setup.exe',
      'C:\Tools\map_setup.exe')
    Start-Process -FilePath "C:\Tools\map_setup.exe" -ArgumentList '/Silent /ALLUSERS /DIR="C:\Tools\map"' -Wait -NoNewWindow
    del 'C:\Tools\map_setup.exe'
    # Update path env var
    [Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";C:\Tools\map", [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";C:\Tools\map", [EnvironmentVariableTarget]::User)
  } Catch {
    Write-Host "Malcode Analyst Pack Download failed"
  }
}
#############################################################################################
function Install-AndroidPlatformTools {
  # For ADB, fastboot, etc
  # https://developer.android.com/studio/releases/platform-tools
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Android Platform Tools..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'https://dl.google.com/android/repository/platform-tools-latest-windows.zip',
      'C:\Tools\platform-tools.zip')
    Expand-Archive -LiteralPath 'C:\Tools\platform-tools.zip' -DestinationPath 'C:\Tools\Android\'
    del 'C:\Tools\platform-tools.zip'
    Update-PathEnvVar -path "C:\Tools\Android\platform-tools"
  } Catch {
    Write-Host "Android Platform Tools Download failed"
  }
}
#############################################################################################
function Install-DummyFilesCreator {
  # https://github.com/Humoud/dummy-files-creator
  # Fork of https://github.com/matuzalemmuller/dummy-files-creator
  # Check dependency
  if (Test-Path -Path $pythonPath) {
    write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Python is already installed..."
  } else {
    write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Python not installed..."
    Install-Python
  }
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Downloading Dummy Files Creator..."
  Try { 
    (New-Object System.Net.WebClient).DownloadFile(
      'https://github.com/Humoud/dummy-files-creator/archive/refs/heads/master.zip',
      'C:\Tools\dummyfilescreator.zip')
    Expand-Archive -LiteralPath 'C:\Tools\dummyfilescreator.zip' -DestinationPath 'C:\Tools\'
    Start-Process -FilePath "cmd" -ArgumentList '/c cd C:\Tools\dummy-files-creator-master\spec && C:\Python310\Scripts\pip.exe install -q -r ..\requirements.txt && C:\Python310\Scripts\pyinstaller.exe --clean --windowed --onefile windows.spec' -Wait -NoNewWindow
    cp 'C:\tools\dummy-files-creator-master\spec\dist\Dummy Files Creator.exe' C:\Tools\
    Remove-Item C:\Tools\dummy-files-creator-master\ -Recurse
    del 'C:\Tools\dummyfilescreator.zip'
  } Catch {
    Write-Host "Dummy Files Creator Download failed"
  }
}
#############################################################################################
#############################################################################################
## Think of the below as "main"
## Include or exclude functions as you please
# Create shortcut for tools folder

Set-Shortcut -src 'C:\Tools' -dst 'C:\users\vagrant\desktop\Tools.lnk'


Install-Choco # Needed by other functions
Install-ChocoEssentials
###########
# Blue-ish
Install-AnalysisMiscTools
Install-ZimmermanTools
Install-Kansa
Install-Chainsaw
Install-DeepBlueCLI
Get-PEStudio
Install-NetworkAnalysisTools
Install-DebuggerDisassembler
Install-HasherezadeTools
Install-HxD
Install-Jadx
Install-PEFile
Install-APIMonitor
Install-MalcodeAnalystPack
###########
# Red-ish
Install-Burp
Get-Ghostpack
Get-Nim
Install-GoLang
Install-Bloodhound
Install-CommunityVS2022
Install-AtomicRedTeam

###########
# Misc
Get-CorkamiPosters
Get-CyberChef
Get-SysInternals
Install-Frida
Install-AndroidPlatformTools
Install-DummyFilesCreator


Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Utilities installation complete!"