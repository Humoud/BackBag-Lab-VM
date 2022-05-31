# BackBag Lab\VM

BackBag Lab\VM, small enough to carry on your back (Back**pack**) 🎒💻

## Background & Purpose
I needed a way to quickly setup a small environment that allows me to test both, blue and red teaming related stuff on my laptop 💻. There are also times where I just need an ubuntu server or a win10 instance with a specific set of tools and not a whole environment. This project caters for such cases. 

## Wiki
Refer to the [Wiki](https://github.com/Humoud/BackBag-Lab-VM/wiki/1.-Home) for more details:
- [Design](https://github.com/Humoud/BackBag-Lab-VM/wiki/2.-Design)
- [Configuration](https://github.com/Humoud/BackBag-Lab-VM/wiki/3.-Configuration)
- [Usage](https://github.com/Humoud/BackBag-Lab-VM/wiki/4.-Usage)
    - [Important Note](https://github.com/Humoud/BackBag-Lab-VM/wiki/4.-Usage#important-note)
- [Tools](https://github.com/Humoud/BackBag-Lab-VM/wiki/5.-Tools)

## Design
This project uses Vagrant and a collection of powershell\bash scripts to provision and configure VMs.

#### VMs

Windows base images are from [DetectionLab](https://github.com/clong/DetectionLab). Many thanks to them ♥.

| VM Name  | OS                  |
| -------- | ------------------- |
| WINSRV01 | Windows Server 2016 |
| WINSRV02 | Windows Server 2016 |
| WIN01    | Windows 10          |
| NIX01    | Ubuntu 20.04        |


#### Available Environment Configurations

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


## Credits
MacOS testing and troubleshooting:
 - Taylor Parizo:
     - https://twitter.com/TaylorParizo | https://github.com/axelarator

This project is heavily inspired by [DetectionLab](https://github.com/clong/DetectionLab) ♥. I built upon and modified it, this work was not from scratch:
- Vagrantfile and Provisioning Scripts:
  - DetectionLab
    - https://github.com/clong/DetectionLab
- Vagrant Boxes:
  - DetectionLab
    - https://github.com/clong/DetectionLab
