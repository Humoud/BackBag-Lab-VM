###################################################################################
# ______            _   ______             
# | ___ \          | |  | ___ \            
# | |_/ / __ _  ___| | _| |_/ / __ _  __ _ 
# | ___ \/ _` |/ __| |/ / ___ \/ _` |/ _` |
# | |_/ / (_| | (__|   <| |_/ / (_| | (_| |
# \____/ \__,_|\___|_|\_\____/ \__,_|\__, |
#                                     __/ |
#                                    |___/ 
#
# Special thanks to https://github.com/clong/DetectionLab for creating & maintaining the Windows Vagrant Boxes <3

###### CONFIG VARIABLES ###########################################################

# Lab VM Selection
NIX01    = true
WINSRV01 = true
WINSRV02 = true
WIN01    = true

######################################################
# IPs
# Ensure ips are in the 192.168.56.x/24 range for the project to work
# Might work on removing this restriction if there are requests for it
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
# Promote to Domain Controller
IS_DC = 1
# Will only be relevant if you are promoting WINSRV01 to a Domain Controller
# if u want to modify the domain name, ensure it is in SOMETHING.SOMETHING format
DOMAIN = "backbag.local"
NETBIOS_NAME = "BACKBAG"
# No need to modify the below, its taking the values above to build provisioning params
SRV01_ARGS  = "-ad_ip #{WINSRV01_IP} -domain #{DOMAIN} -netbiosName #{NETBIOS_NAME} -isDC #{IS_DC}"
######################################################
# WINSRV02 Config
###
# Join WINSRV02 to domain
AD_DOMAIN = 1
# Install IIS on WINSRV02
SETUP_IIS = 1
SRV02_ARGS  = "-joinDomain #{AD_DOMAIN} -ad_ip #{WINSRV01_IP} -domain #{DOMAIN}"
######################################################
# WIN01 Config
###
# Join WIN01 to domain
AD_DOMAIN = 1
WIN10_ARGS = "-joinDomain #{AD_DOMAIN} -ad_ip #{WINSRV01_IP} -domain #{DOMAIN}"
######################################################
# Mounts 2 folders on the Windows VMs
# This is needed when provisioning on macOS using VBox
# Make sure you set it to `false` before analyzing malware after you
# finish provisioning the VMs
MOUNT = true
###### /CONFIG VARIABLES ##########################################################

Vagrant.configure("2") do |config|
  if NIX01
    config.vm.define "nix01" do |cfg|
      cfg.vm.box = "bento/ubuntu-20.04"
      cfg.vm.hostname = "bb-nix01"
      cfg.vm.provision :shell, path: "scripts/nix_bootstrap.sh"
      cfg.vm.network :private_network, ip: NIX01_IP, gateway: "192.168.56.1", dns: "8.8.8.8"

      cfg.vm.provider "vmware_desktop" do |v, override|
        v.vmx["displayname"] = "backbag-nix01"
        v.vmx["virtualhw.version"] = 16
        v.memory = NIX01_RAM
        v.cpus = NIX01_CPU
        v.gui = true
      end
      cfg.vm.provider "virtualbox" do |v, override|
        v.gui = true
        v.name = "backbag-nix01"
        v.customize ["modifyvm", :id, "--memory", NIX01_RAM]
        v.customize ["modifyvm", :id, "--cpus", NIX01_CPU]
        v.customize ["modifyvm", :id, "--vram", "32"]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
      end
    end
  end
  #-------------------------------------------------------------------------------------------
  if WINSRV01
    config.vm.define "winsrv01" do |cfg|
      cfg.vm.box = "detectionlab/win2016"
      cfg.vm.box_version = "1.9"
      cfg.vm.hostname = "bb-winsrv01"

      cfg.vm.boot_timeout = 600
      cfg.winrm.transport = :plaintext
      cfg.vm.communicator = "winrm"
      cfg.winrm.basic_auth_only = true
      cfg.winrm.timeout = 300
      cfg.winrm.retry_limit = 20

      cfg.vm.network :private_network, ip: WINSRV01_IP, gateway: "192.168.56.1", dns: "8.8.8.8"
      # rdp access
      cfg.vm.network "forwarded_port", guest: 3389, host: 63389, auto_correct: true
      #

      if MOUNT
      # https://www.vagrantup.com/docs/synced-folders
      # solves: Enabling and configuring shared folders timeout
      cfg.vm.synced_folder '.', '/vagrant', disabled: true
      # solve vbox issue on macos when provisioning
      cfg.vm.provision "file", source: "scripts", destination: "c:/vagrant/"
      cfg.vm.provision "file", source: "resources", destination: "c:/vagrant/"
      #
      end

      cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: true, args: "-ip #{WINSRV01_IP} -dns 8.8.8.8 -gateway 192.168.56.1" 
      cfg.vm.provision "shell", path: "scripts/MakeWindows10GreatAgain.ps1", privileged: false
      cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false, args: SRV01_ARGS
      cfg.vm.provision "reload"
      cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false, args: SRV01_ARGS
      if IS_DC == 1
        cfg.vm.provision "shell", path: "scripts/install-ad-utils.ps1", privileged: false
      end
      cfg.vm.provision "shell", path: "scripts/install-sysmon.ps1", privileged: false


      cfg.vm.provider "vmware_desktop" do |v, override|
        v.vmx["ethernet1.pcislotnumber"] = "33"
        v.vmx["displayname"] = "backbag-winsrv01"
        v.memory = WINSRV01_RAM
        v.cpus = WINSRV01_CPU
        v.gui = true
      end
      cfg.vm.provider "virtualbox" do |v, override|
        v.gui = true
        v.name = "backbag-winsrv01"
        v.default_nic_type = "82545EM"
        v.customize ["modifyvm", :id, "--memory", WINSRV01_RAM]
        v.customize ["modifyvm", :id, "--cpus", WINSRV01_CPU]
        v.customize ["modifyvm", :id, "--vram", "32"]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
      end
    end
  end
  #-------------------------------------------------------------------------------------------
  if WINSRV02
    config.vm.define "winsrv02" do |cfg|
      cfg.vm.box = "detectionlab/win2016"
      cfg.vm.box_version = "1.9"
      cfg.vm.hostname = "bb-winsrv02"

      cfg.vm.boot_timeout = 600
      cfg.winrm.transport = :plaintext
      cfg.vm.communicator = "winrm"
      cfg.winrm.basic_auth_only = true
      cfg.winrm.timeout = 300
      cfg.winrm.retry_limit = 20

      cfg.vm.network :private_network, ip: WINSRV02_IP, gateway: "192.168.56.1", dns: "8.8.8.8"
      
      # rdp access
      cfg.vm.network "forwarded_port", guest: 3389, host: 53389, auto_correct: true
      #
      
      if MOUNT
      # https://www.vagrantup.com/docs/synced-folders
      # solves: Enabling and configuring shared folders timeout
      cfg.vm.synced_folder '.', '/vagrant', disabled: true
      # solve vbox issue on macos when provisioning
      cfg.vm.provision "file", source: "scripts", destination: "c:/vagrant/"
      cfg.vm.provision "file", source: "resources", destination: "c:/vagrant/"
      #
      end

      cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: true, args: "-ip #{WINSRV02_IP} -dns 8.8.8.8 -gateway 192.168.56.1" 
      cfg.vm.provision "shell", path: "scripts/MakeWindows10GreatAgain.ps1", privileged: false
      cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false, args: SRV02_ARGS
      cfg.vm.provision "reload"
      cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false, args: SRV02_ARGS
      if SETUP_IIS == 1
        cfg.vm.provision "shell", path: "scripts/install-iis-utils.ps1", privileged: false
      end
      cfg.vm.provision "shell", path: "scripts/install-sysmon.ps1", privileged: false


      cfg.vm.provider "vmware_desktop" do |v, override|
        v.vmx["ethernet1.pcislotnumber"] = "33"
        v.vmx["displayname"] = "backbag-winsrv02"
        v.memory = WINSRV01_RAM
        v.cpus = WINSRV01_CPU
        v.gui = true
      end
      cfg.vm.provider "virtualbox" do |v, override|
        v.gui = true
        v.name = "backbag-winsrv02"
        v.default_nic_type = "82545EM"
        v.customize ["modifyvm", :id, "--memory", WINSRV02_RAM]
        v.customize ["modifyvm", :id, "--cpus", WINSRV02_CPU]
        v.customize ["modifyvm", :id, "--vram", "32"]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
      end
      cfg.vm.synced_folder '.', '/vagrant', disabled: true
    end
  end
  #-------------------------------------------------------------------------------------------
  if WIN01
    config.vm.define "win01" do |cfg|
      cfg.vm.box = "detectionlab/win10"
      cfg.vm.box_version = "1.8"
      cfg.vm.hostname = "bb-win01"
      
      cfg.vm.boot_timeout = 600
      cfg.winrm.transport = :plaintext
      cfg.vm.communicator = "winrm"
      cfg.winrm.basic_auth_only = true
      cfg.winrm.timeout = 300
      cfg.winrm.retry_limit = 20

      cfg.vm.network :private_network, ip: WIN01_IP, gateway: "192.168.56.1", dns: "8.8.8.8"
      # rdp access
      cfg.vm.network "forwarded_port", guest: 3389, host: 43389, auto_correct: true
      #

      if MOUNT # TODO add to other win based machines
      # https://www.vagrantup.com/docs/synced-folders
      # solves: Enabling and configuring shared folders timeout
      cfg.vm.synced_folder '.', '/vagrant', disabled: true
      # solves: vbox issue on macos when provisioning
      cfg.vm.provision "file", source: "scripts", destination: "c:/vagrant/"
      cfg.vm.provision "file", source: "resources", destination: "c:/vagrant/"
      #
      end

      cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: true, args: "-ip #{WIN01_IP} -dns 8.8.8.8 -gateway 192.168.56.1" 
      # cfg.vm.provision "shell", path: "scripts/MakeWindows10GreatAgain.ps1", privileged: false
      cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false, args: WIN10_ARGS
      cfg.vm.provision "reload"
      cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false, args: WIN10_ARGS
      # #############################################################################################
      # Script below contains Win tools and dev env setup
      cfg.vm.provision "shell", path: "scripts/install-analyst-utils.ps1", privileged: false
      # ##############################################################################################
      # cfg.vm.provision "shell", path: "scripts/install-sysmon.ps1", privileged: false
      # ##############################################################################################

      cfg.vm.provider "vmware_desktop" do |v, override|
        v.vmx["ethernet1.pcislotnumber"] = "33"
        v.vmx["displayname"] = "backbag-win01"
        v.memory = WIN01_RAM
        v.cpus = WIN01_CPU
        v.gui = true
      end
      cfg.vm.provider "virtualbox" do |v, override|
        v.gui = true
        v.name = "backbag-win01"
        v.default_nic_type = "82545EM"
        v.customize ["modifyvm", :id, "--memory", WIN01_RAM]
        v.customize ["modifyvm", :id, "--cpus", WIN01_CPU]
        v.customize ["modifyvm", :id, "--vram", "32"]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
      end
    end
  end
end
