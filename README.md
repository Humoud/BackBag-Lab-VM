# BackBag Lab\VM

BackBag Lab\VM, small enough to carry on your back (Back**pack**) 🎒💻

## Contents
- [BackBag Lab\VM](#backbag-labvm)
  - [Contents](#contents)
  - [Background & Purpose](#background--purpose)
  - [Design](#design)
    - [VMs](#vms)
    - [Available Environment Configurations](#available-environment-configurations)
    - [Configuration](#configuration)
      - [Provisioning](#provisioning)
      - [Tool Install Scripts](#tool-install-scripts)
- [Usage](#usage)
  - [Requirements](#requirements)
  - [Spin Up The Whole Lab](#spin-up-the-whole-lab)
    - [Lab VM Selection](#lab-vm-selection)
  - [Spin Up Only The Windows Analyst VM](#spin-up-only-the-windows-analyst-vm)
- [Example Setups](#example-setups)
    - [1: Ubuntu Server + IIS Server](#1-ubuntu-server--iis-server)
    - [2: Win10 + IIS Server](#2-win10--iis-server)
    - [3: AD + IIS Server (Joined to domain)](#3-ad--iis-server-joined-to-domain)
- [Tools](#tools)
- [Credits](#credits)

## Background & Purpose
I needed a way to quickly setup a small environment that allows me to test both, blue and red teaming related stuff on my laptop 💻. There are also times where I just need an ubuntu server or a win10 instance with a specific set of tools and not a whole environment. This project caters for such cases. 

## Design
### VMs

Windows base images are from [DetectionLab](https://github.com/clong/DetectionLab). Many thanks to them ♥.

| VM Name  | OS                  |
| -------- | ------------------- |
| WINSRV01 | Windows Server 2016 |
| WINSRV02 | Windows Server 2016 |
| WIN01    | Windows 10          |
| NIX01    | Ubuntu 20.04        |


**Resource Utilization:**
Note that you can decrease\increase the specs below (it's really easy) based on your needs. 

| VM       | CPU | RAM |
| -------- | --- | --- |
| NIX01    | 1   | 1GB |
| WIN01    | 2   | 4GB |
| WINSRV01 | 1   | 2GB |
| WINSRV02 | 1   | 2GB |

I would set the `WIN01` VM to 1 cpu core if I am not running Visual Studio or analyzing malware:

I rarely run all VMs at the same time. If you want to, you can.

Utilization based on setups (quick maths):
- AD + WIN setup = 3 cores, 6GB ram
- NIX + WIN setup = 3 cores, 5GB ram
- AD + NIX setup = 3 cores, 3GB ram
- IIS + NIX setup = 3 cores, 3GB ram
- AD + IIS + NIX setup = 3 cores, 5GB ram

When running **all VMs**: 5 cores, 9GB ram.

### Available Environment Configurations

| VM       | AD Server | Join to Domain | IIS Web Server | Standalone |
| -------- | --------- | -------------- | -------------- | ---------- |
| WINSRV01 | ✅        | ❌             | ❌             | ✅         |
| WINSRV02 | ❌        | ✅             | ✅             | ✅         |
| WIN01    | ❌        | ✅             | ❌             | ✅         |
| NIX01    | ❌        | ❌             | ❌             | ✅         |

✅ = You can enable this setup for the VM.
❌ = Setup not available.

**AD Server:** VM can be promoted to a Domain Controller.

**Join to Domain:** VM can be joined to domain. Requires a machine with setup "AD Server" to be available.

**IIS Web Server:** IIS Web Server can be installed on the VM.

**Standalone:** VM can be created and used without requiring any other VM to exist. Note that "Join to Domain" feature can not be used when using a VM in standalone setup.

### Configuration
#### Provisioning
Configuration is mainly done via the [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile). You will notice that at the top of the Vagrantfile there is a section in which variables are being defined and that is the configuration section. In other words, the Vagratfile is also BackBag's main config file and you are expected to modify it to suit your needs.

The following settings can be configured via the Vagrantfile:
- VM selection
- VM specs (CPU, RAM)
- IP addresses
- Active Directory:
  - Setup Domain (Yes/No)
  - Domain Name
- Setup IIS (Yes/No)
- Join Machine to Domain (Yes/No)

#### Tool Install Scripts
The scripts below contain install scripts for the corresponding VMs:

1. WINSRV01 AD Mode: `scripts\install-ad-utils.ps1`
2. WINSRV02 IIS Mode: `scripts\install-iis-utils.ps1`
3. WIN01: `scripts\install-analyst-utils.ps1`
4. NIX01: `scripts\nix_bootstrap.sh`

At the end of each script you can comment/uncomment what packages you want installed.

**NIX01 example:**
```sh
main() {
  modify_motd
  apt_install_prerequisites
  apt_install_docker
  # apt_install_scanners
  # apt_install_zeek
  install_metasploit
  install_sliverc2
  install_radare2
  # install_yara
  # install_pywhat
  # install_spiderfoot
  # docker_evilwinrm
  docker_powershell_empire
  # docker_crackmapexec
  # docker_clamav
  ### clean up
  apt -y autoremove
}
```


**WIN01 example:**
```sh
Install-Choco # Needed by other functions
Install-ChocoEssentials
Install-ChocoAnalysisPackages
Get-PEStudio
# Install-ZimmermanTools
# Get-CyberChef
# Get-CorkamiPosters
Get-Ghostpack
Get-SysInternals
# Get-Nim
# Install-GoLang
Install-Bloodhound
Install-CommunityVS2022
```
Note that these are the packages that `Install-ChocoAnalysisPackages` will install:
```powershell
$pkgs = 'wireshark',
        # 'burp-suite-free-edition',
        'processhacker',
        'resourcehacker.portable',
        'network-miner',
        'ghidra',
        'x64dbg.portable',
        'pebear',
        'pesieve',
        'hollowshunter',
        'yara',
        'die',
        'dnspy'
```

You can comment/uncomment whatever package you want, just like how I commented out burp in that example.

`Install-CommunityVS2022` Will install packages for C# and C++ development. Check the function definition if you want to add more packages, it is well documented.

# Usage

## Requirements

- Virtualbox or VMware Workstation
- Vagrant [download here](https://www.vagrantup.com/docs/installation)

For VMWare Workstation & Fusion:
- Install vagrant plugin: [vagrant-vmware-desktop](https://www.vagrantup.com/docs/providers/vmware/installation)

First, clone the repo or download it.

```
git clone https://github.com/Humoud/BackBag-Lab-VM.git
cd BackBag-Lab-VM
```

**Then proceed to one of the sections below. It is best to pick a section which suits your needs:**
- [BackBag Lab\VM](#backbag-labvm)
  - [Contents](#contents)
  - [Background & Purpose](#background--purpose)
  - [Design](#design)
    - [VMs](#vms)
    - [Available Environment Configurations](#available-environment-configurations)
    - [Configuration](#configuration)
      - [Provisioning](#provisioning)
      - [Tool Install Scripts](#tool-install-scripts)
- [Usage](#usage)
  - [Requirements](#requirements)
  - [Spin Up The Whole Lab](#spin-up-the-whole-lab)
    - [Lab VM Selection](#lab-vm-selection)
  - [Spin Up Only The Windows Analyst VM](#spin-up-only-the-windows-analyst-vm)
- [Example Setups](#example-setups)
    - [1: Ubuntu Server + IIS Server](#1-ubuntu-server--iis-server)
    - [2: Win10 + IIS Server](#2-win10--iis-server)
    - [3: AD + IIS Server (Joined to domain)](#3-ad--iis-server-joined-to-domain)
- [Tools](#tools)
- [Credits](#credits)


## Spin Up The Whole Lab
### Lab VM Selection
At the very top of the `Vagrantfile` file, make sure that all vm name variables are set to `true`:

```ruby
NIX01    = true
WINSRV01 = true
WINSRV02 = true
WIN01    = true
```

Those variables will affect the `vagrant up --provider=vmware_desktop` command which spins up the lab, one VM at a time. 

Note that based on your internet connection, these the command might take a long time on the first run. This is because Vagrant boxes will be downloaded.

To speed up the provisioning process, you can provision WINSRV01 and NIX01 in parallel. Once WINSRV01 is done, you can proceed with provisioning WINSRV02.

```
# In parallel
vagrant up winsrv01 --provider=vmware_desktop
vagrant up nix01 --provider=vmware_desktop
# Once winsrv01 is done, run the below in parallel
vagrant up winsrv02 --provider=vmware_desktop
vagrant up win01 --provider=vmware_desktop
```

## Spin Up Only The Windows Analyst VM
Set config variable `AD_DOMAIN` under the "WIN01 Config" section in the Vagrantfile to `0`, like so:
```ruby
# WIN01 Config
###
# Join WIN01 to domain
AD_DOMAIN = 0
```

Spin up the VM:
```
vagrant up win01 --provider=vmware_desktop
```

If you find yourself only using this VM, you can change the config at the top of the Vagrantfile to disable other VMs:
```ruby
NIX01    = false
WINSRV01 = false
WINSRV02 = false
WIN01    = true
```

This makes life easier ☕ when running vagrant commands as you dont need to specify the VM name:
```
vagrant up --provider=vmware_desktop
vagrant halt
vagrant destroy
vagrant rdp
# etc etc
```

Of course, this can be applied to all other VMs and you can enable\disable more than one VM.

# Example Setups
### 1: Ubuntu Server + IIS Server

```ruby
###### CONFIG VARIABLES ###########################################################

# Lab VM Selection
NIX01    = true
WINSRV01 = false
WINSRV02 = true
WIN01    = false

######################################################
# IPs
WINSRV01_IP = "192.168.56.5"
WINSRV02_IP = "192.168.56.10"
WIN01_IP    = "192.168.56.20"
NIX01_IP    = "192.168.56.30"
#----------
# VM Specs
NIX01_CPU = 1
NIX01_RAM = 1024
#
WINSRV01_CPU  = 1
WINSRV01_RAM  = 2048
#
WINSRV02_CPU  = 1
WINSRV02_RAM  = 2048
#
WIN01_CPU = 2
WIN01_RAM = 4096
#---------------------------------------------------------------------------------
######################################################
# WINSRV01 Config
###
IS_DC = 1
DOMAIN = "backbag.local"
NETBIOS_NAME = "BACKBAG"
SRV01_ARGS  = "-ad_ip #{WINSRV01_IP} -domain #{DOMAIN} -netbiosName #{NETBIOS_NAME} -isDC #{IS_DC}"
######################################################
# WINSRV02 Config
###
AD_DOMAIN = 0            #<<<<MUST BE DISABLED>>>>
SETUP_IIS = 1            #<<<<MUST BE ENABLED>>>>
SRV02_ARGS  = "-joinDomain #{AD_DOMAIN} -ad_ip #{WINSRV01_IP} -domain #{DOMAIN}"
######################################################
# WIN01 Config
###
AD_DOMAIN = 1
WIN10_ARGS = "-joinDomain #{AD_DOMAIN} -ad_ip #{WINSRV01_IP} -domain #{DOMAIN}"
###### /CONFIG VARIABLES ##########################################################
```

Run `vagrant up --provider=vmware_desktop`

### 2: Win10 + IIS Server

```ruby
###### CONFIG VARIABLES ###########################################################

# Lab VM Selection
NIX01    = false
WINSRV01 = false
WINSRV02 = true
WIN01    = true

######################################################
# IPs
WINSRV01_IP = "192.168.56.5"
WINSRV02_IP = "192.168.56.10"
WIN01_IP    = "192.168.56.20"
NIX01_IP    = "192.168.56.30"
#----------
# VM Specs
NIX01_CPU = 1
NIX01_RAM = 1024
#
WINSRV01_CPU  = 1
WINSRV01_RAM  = 2048
#
WINSRV02_CPU  = 1
WINSRV02_RAM  = 2048
#
WIN01_CPU = 2
WIN01_RAM = 4096
#---------------------------------------------------------------------------------
######################################################
# WINSRV01 Config
###
IS_DC = 1
DOMAIN = "backbag.local"
NETBIOS_NAME = "BACKBAG"
SRV01_ARGS  = "-ad_ip #{WINSRV01_IP} -domain #{DOMAIN} -netbiosName #{NETBIOS_NAME} -isDC #{IS_DC}"
######################################################
# WINSRV02 Config
###
AD_DOMAIN = 0            #<<<<MUST BE DISABLED>>>>
SETUP_IIS = 1            #<<<<MUST BE ENABLED>>>>
SRV02_ARGS  = "-joinDomain #{AD_DOMAIN} -ad_ip #{WINSRV01_IP} -domain #{DOMAIN}"
######################################################
# WIN01 Config
###
AD_DOMAIN = 0           #<<<<MUST BE DISABLED>>>>
WIN10_ARGS = "-joinDomain #{AD_DOMAIN} -ad_ip #{WINSRV01_IP} -domain #{DOMAIN}"
###### /CONFIG VARIABLES ##########################################################
```

Run `vagrant up --provider=vmware_desktop`

### 3: AD + IIS Server (Joined to domain)

```ruby
###### CONFIG VARIABLES ###########################################################

# Lab VM Selection
NIX01    = false
WINSRV01 = true
WINSRV02 = true
WIN01    = false

######################################################
# IPs
WINSRV01_IP = "192.168.56.5"
WINSRV02_IP = "192.168.56.10"
WIN01_IP    = "192.168.56.20"
NIX01_IP    = "192.168.56.30"
#----------
# VM Specs
NIX01_CPU = 1
NIX01_RAM = 1024
#
WINSRV01_CPU  = 1
WINSRV01_RAM  = 2048
#
WINSRV02_CPU  = 1
WINSRV02_RAM  = 2048
#
WIN01_CPU = 2
WIN01_RAM = 4096
#---------------------------------------------------------------------------------
######################################################
# WINSRV01 Config
###
IS_DC = 1               #<<<<MUST BE ENABLED>>>>
DOMAIN = "backbag.local"
NETBIOS_NAME = "BACKBAG"
SRV01_ARGS  = "-ad_ip #{WINSRV01_IP} -domain #{DOMAIN} -netbiosName #{NETBIOS_NAME} -isDC #{IS_DC}"
######################################################
# WINSRV02 Config
###
AD_DOMAIN = 1            #<<<<MUST BE ENABLED>>>>
SETUP_IIS = 1            #<<<<MUST BE ENABLED>>>>
SRV02_ARGS  = "-joinDomain #{AD_DOMAIN} -ad_ip #{WINSRV01_IP} -domain #{DOMAIN}"
######################################################
# WIN01 Config
###
# Join WIN01 to domain
AD_DOMAIN = 0           
WIN10_ARGS = "-joinDomain #{AD_DOMAIN} -ad_ip #{WINSRV01_IP} -domain #{DOMAIN}"
###### /CONFIG VARIABLES ##########################################################
```

Run `vagrant up --provider=vmware_desktop`


# Tools
Many thanks to the creators of the tools ♥

Windows 10 Machine:
Found in `install-analyst-utils.ps1` script:
- via [chocolatey](https://chocolatey.org/)
  - [NotepadPlusPlus](https://notepad-plus-plus.org/downloads/)
  - [7zip](https://www.7-zip.org/)
  - [git](https://git-scm.com/)
  - [GoogleChrome](https://www.google.com/chrome/)
  - [vscode.portable](https://code.visualstudio.com/)
  - [wireshark](https://www.wireshark.org/)
  - [burp-suite-free-edition](https://portswigger.net/burp)
  - [processhacker](https://github.com/processhacker/processhacker)
  - resourcehacker.portable
  - [network-miner](https://www.netresec.com/?page=NetworkMiner)
  - [ghidra](https://github.com/NationalSecurityAgency/ghidra)
  - [x64dbg.portable](https://x64dbg.com/)
  - [pebear](https://github.com/hasherezade/pe-bear-releases)
  - [pesieve](https://github.com/hasherezade/pe-sieve)
  - [hollowshunter](https://github.com/hasherezade/hollows_hunter)
  - [yara](https://virustotal.github.io/yara/)
  - [die (Detect It Easy)](https://github.com/horsicq/Detect-It-Easy)
  - [dnspy](https://github.com/dnSpy/dnSpy)
- [PEStudio](https://www.winitor.com/)
- [Eric Zimmerman Tools](https://github.com/EricZimmerman/Get-ZimmermanTools)
- [CyberChef](https://gchq.github.io/CyberChef/)
- [Corkami Posters (References)](https://github.com/corkami/pics)
- [Ghostpack](https://github.com/r3motecontrol/Ghostpack-CompiledBinaries)
- [SysInternals](https://docs.microsoft.com/en-us/sysinternals/)
- [Nim](https://github.com/dom96/choosenim)
- [GoLang](https://go.dev/)
- [Bloodhound](https://github.com/BloodHoundAD/BloodHound)
- [Visual Studio Community 2022](https://visualstudio.microsoft.com/vs/community/):
  - Microsoft.VisualStudio.Component.CoreEditor
  - Microsoft.VisualStudio.Workload.ManagedDesktop # For C#
  - Microsoft.Net.Component.4.7.2.SDK
  - Microsoft.Net.Component.4.7.2.TargetingPack
  - Microsoft.VisualStudio.Workload.NativeDesktop  # For C++

Windows Server 2016:
- [Badblood](https://github.com/davidprowe/BadBlood)
- [Antak-WebShell](https://github.com/samratashok/nishang/tree/master/Antak-WebShell)
- via [chocolatey](https://chocolatey.org/)
  - [NotepadPlusPlus](https://notepad-plus-plus.org/downloads/)
  - [7zip](https://www.7-zip.org/)
  - [git](https://git-scm.com/)
  - [GoogleChrome](https://www.google.com/chrome/)
  - [vscode.portable](https://code.visualstudio.com/)

Ubuntu Server 20.04:
- docker & docker-compose
- [nmap](https://nmap.org/) & [masscan](https://github.com/robertdavidgraham/masscan)
- [zeek](https://zeek.org/)
- [metasploit](https://www.metasploit.com/)
- [sliverc2](https://github.com/BishopFox/sliver)
- [radare2](https://rada.re/n/)
- [yara](https://virustotal.github.io/yara/)
- [pywhat](https://github.com/bee-san/pyWhat)
- [spiderfoot](https://www.spiderfoot.net/)
- Docker Containers
  - [evilwinrm](https://github.com/Hackplayers/evil-winrm)
  - [powershell_empire](https://github.com/BC-SECURITY/Empire)
  - [crackmapexec](https://github.com/byt3bl33d3r/CrackMapExec)
  - [clamav](https://www.clamav.net/)


# Credits
This project is heavily inspired by [DetectionLab](https://github.com/clong/DetectionLab) ♥

I built upon and modified DetectionLab, this work was not from scratch:
- Vagrantfile and Provisioning Scripts:
  - DetectionLab
    - https://github.com/clong/DetectionLab
- Vagrant Boxes:
  - DetectionLab
    - https://github.com/clong/DetectionLab