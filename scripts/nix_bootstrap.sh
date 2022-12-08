SPIDERFOOT_VERSION=4.0
YARA_VERSION=4.2.1
COMPOSE_VERSION=2.5.0
FENNEC_VERSION=0.3.3
#########################################################################################################
modify_motd() {
  echo "[$(date +%H:%M:%S)]: Updating the MOTD..."
  # Force color terminal
  sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc
  sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc
  # Remove some stock Ubuntu MOTD content
  chmod -x /etc/update-motd.d/10-help-text
  # Copy the DetectionLab MOTD
  cp /vagrant/resources/nixbox/20-backbag /etc/update-motd.d/
  chmod +x /etc/update-motd.d/20-backbag
  rm /etc/update-motd.d/50-landscape-sysinfo
}
#########################################################################################################
apt_install_prerequisites() {
  echo "[$(date +%H:%M:%S)]: Adding apt repositories..."
  # Add repository for docker
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  apt-cache policy docker-ce
  # Add repository for apt-fast
  add-apt-repository -y -n ppa:apt-fast/stable
  echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/security:zeek.list
  curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null
  echo "[$(date +%H:%M:%S)]: Running apt-get clean..."
  apt clean
  echo "[$(date +%H:%M:%S)]: Running apt-get update..."
  apt -qq update
  echo "[$(date +%H:%M:%S)]: Installing apt-fast..."
  # https://github.com/ilikenwf/apt-fast#interaction-free-installation
  echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
  echo debconf apt-fast/dlflag boolean true | debconf-set-selections
  echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections
  apt -qq install -y apt-fast
  echo "[$(date +%H:%M:%S)]: Using apt-fast to install packages..."
  apt-fast install -y wget net-tools apt-transport-https ca-certificates curl software-properties-common build-essential libssl-dev libffi-dev python3-dev python3-pip python3-venv automake libtool make gcc pkg-config
}
#########################################################################################################
apt_install_docker(){
  # Install docker
  apt -y install docker-ce
  # Install docker compose
  # check https://github.com/docker/compose/releases for version
  curl -L "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&\
  chmod +x /usr/local/bin/docker-compose
}
#########################################################################################################
apt_install_scanners(){
  apt-fast install -y nmap masscan
}
#########################################################################################################
apt_install_zeek(){
  # https://software.opensuse.org//download.html?project=security%3Azeek&package=zeek-lts
  echo "postfix postfix/mailname string example.com" | debconf-set-selections
  echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
  apt -y install zeek-lts
}
#########################################################################################################
install_metasploit(){
  # https://docs.rapid7.com/metasploit/installing-the-metasploit-framework/
  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall
}
#########################################################################################################
install_sliverc2(){
  # https://github.com/BishopFox/sliver
  curl https://sliver.sh/install|sudo bash
}
#########################################################################################################
install_radare2(){
  # https://github.com/radareorg/radare2#installation
  git clone https://github.com/radareorg/radare2
  cd radare2
  radare2/sys/install.sh
  cd /home/vagrant
  # clean up
  rm -rf /home/vagrant/radare2
}
#########################################################################################################
install_yara(){
  # https://github.com/radareorg/radare2#installation
  cd /home/vagrant
  wget https://github.com/VirusTotal/yara/archive/refs/tags/v${YARA_VERSION}.tar.gz
  tar -zxf yara-${YARA_VERSION}.tar.gz
  cd yara-${YARA_VERSION}
  ./bootstrap.sh
  ./configure --enable-magic --enable-dotnet
  make
  make install
  # clean up
  rm -rf /home/vagrant/yara-${YARA_VERSION}.tar.gz
}
#########################################################################################################
install_binlex(){
  # https://github.com/c3rb3ru5d3d53c/binlex
  # deps
  apt-fast install -y git build-essential cmake make parallel doxygen git-lfs rpm python3 python3-dev
  cd /home/vagrant
  git clone --recursive https://github.com/c3rb3ru5d3d53c/binlex.git
  # Install
  cd binlex/
  make threads=4
  make install
  cd /home/vagrant
  chown -R vagrant:vagrant binlex/
}
#######################################################################################################
install_pywhat(){
  # https://github.com/bee-san/pyWhat
  pip3 install pywhat[optimize]
}
#########################################################################################################
install_spiderfoot(){
  cd /opt
  wget https://github.com/smicallef/spiderfoot/archive/v${SPIDERFOOT_VERSION}.tar.gz
  chmod +x run_spiderfoot.sh
  # clean up
  cd ..
  rm -rf v${SPIDERFOOT_VERSION}.tar.gz
  cd /home/vagrant
}
#########################################################################################################
install_barq(){
  # https://github.com/Voulnet/barq
  cd /opt
  git clone https://github.com/Voulnet/barq.git
  cd barq
  pip3 install -r requirements.txt
  cd /home/vagrant
}
#########################################################################################################
install_fennec(){
  # https://github.com/AbdulRhmanAlfaifi/Fennec
  cd /opt
  wget https://github.com/AbdulRhmanAlfaifi/Fennec/releases/download/v${FENNEC_VERSION}/fennec_linux_x86_64
  chmod +x fennec_linux_x86_64
  cd /home/vagrant
}
#########################################################################################################
install_arkime(){
  ## PRE-REQUISITE: docker, to run ES
  # https://arkime.com/downloads
  ARKIME_DEB=arkime_3.4.2-1_amd64.deb
  ES_IMAGE=elasticsearch:7.17.5
  ARKIME_INSTALL_DIR=/opt/arkime
  ARKIME_NAME=arkime
  ARKIME_PORT=8080

  echo "Arkime - Pulling $ES_IMAGE"
  #docker pull $ES_IMAGE;

  echo "Arkime - Downloading DEB package"
  #cd /opt && wget https://s3.amazonaws.com/files.molo.ch/builds/ubuntu-20.04/$ARKIME_DEB;

  echo "Arkime - Installing DEB package"
  cd /opt && apt install -f ./$ARKIME_DEB;

  echo "Arkime - Running $ES_IMAGE container (name: es01)"
  docker run --name es01 -p 9200:9200 -p 9300:9300 -e "http.host=0.0.0.0" -e "transport.host=127.0.0.1" -e "xpack.security.enabled=false" -d -it $ES_IMAGE;
  echo "Arkime - Giving Elasticsearch time to start up (30 secs)"
  sleep 30;

  echo "Arkime - Generating config file"
  sed -e "s/ARKIME_INTERFACE/eth0;eth1/g" -e "s/viewPort = 8005/viewPort = $ARKIME_PORT/g" -e "s,ARKIME_ELASTICSEARCH,http://localhost:9200,g" -e "s/ARKIME_PASSWORD/changeme/g" -e "s,ARKIME_INSTALL_DIR,/opt/arkime,g" < $ARKIME_INSTALL_DIR/etc/config.ini.sample > $ARKIME_INSTALL_DIR/etc/config.ini;

  echo "Arkime - Creating log dirs"
  CREATEDIRS="logs raw"
  for CREATEDIR in $CREATEDIRS; do
    mkdir -m 0700 -p $ARKIME_INSTALL_DIR/$CREATEDIR && \
    chown nobody $ARKIME_INSTALL_DIR/$CREATEDIR
  done

  if [ -d "/etc/logrotate.d" ] && [ ! -f "/etc/logrotate.d/$ARKIME_NAME" ]; then
    echo "Arkime - Installing /etc/logrotate.d/$ARKIME_NAME to rotate files after 7 days"
    cat << EOF > /etc/logrotate.d/$ARKIME_NAME
$ARKIME_INSTALL_DIR/logs/capture.log
$ARKIME_INSTALL_DIR/logs/viewer.log {
    daily
    rotate 7
    notifempty
    copytruncate
}
EOF
fi

  if [ -d "/etc/security/limits.d" ] && [ ! -f "/etc/security/limits.d/99-arkime.conf" ]; then
    echo "Arkime - Installing /etc/security/limits.d/99-arkime.conf to make core and memlock unlimited"
    cat << EOF > /etc/security/limits.d/99-arkime.conf
nobody  -       core    unlimited
root    -       core    unlimited
nobody  -       memlock    unlimited
root    -       memlock    unlimited
EOF
  fi

  echo "Arkime - Downloading GEO files (see https://arkime.com/faq#maxmind)"
  $ARKIME_INSTALL_DIR/bin/arkime_update_geo.sh > /dev/null

  echo "Arkime - Clearing Elasticsearch"
  $ARKIME_INSTALL_DIR/db/db.pl http://localhost:9200 init \
  echo "Arkime - Creating admin user"
  $ARKIME_INSTALL_DIR/bin/arkime_add_user.sh admin "Admin User" changeme --admin
  echo "Arkime - Starting capture and viewer services"
  systemctl start arkimecapture.service && systemctl start arkimeviewer.service
  echo "Arkime - Service running on port 8080"
}
#########################################################################################################
get_airstrike(){
  # https://github.com/smokeme/airstrike
  cd /opt
  git clone https://github.com/smokeme/airstrike.git
  cd /home/vagrant
}
#########################################################################################################
docker_evilwinrm(){
  # https://github.com/Hackplayers/evil-winrm
  docker pull oscarakaelvis/evil-winrm:latest
  echo "docker run --rm -ti --name evil-winrm -v /home/foo/ps1_scripts:/ps1_scripts -v /home/foo/exe_files:/exe_files -v /home/foo/data:/data oscarakaelvis/evil-winrm" > /opt/evilwinrm.sh
}
#########################################################################################################
docker_powershell_empire(){
  # https://bc-security.gitbook.io/empire-wiki/quickstart/installation
  docker pull bcsecurity/empire:latest
}
#########################################################################################################
docker_crackmapexec(){
  # https://mpgn.gitbook.io/crackmapexec/getting-started/installation/installation-for-docker
  docker pull byt3bl33d3r/crackmapexec
  echo "docker run -it --entrypoint=/bin/sh --name crackmapexec -v ~/.cme:/root/.cme byt3bl33d3r/crackmapexec" > /opt/crackmapexec.sh
}
#########################################################################################################
docker_clamav(){
  # https://docs.clamav.net/manual/Installing/Docker.html
  # note: latest_base does not contain av sigs
  docker pull clamav/clamav:latest_base
  echo -e 'docker run -it --rm \n--mount type=bind,source=/path/to/scan,target=/scandir \n--mount type=bind,source=/opt/clamav/databases,target=/var/lib/clamav \nclamav/clamav:latest_base \nclamscan /scandir' > /opt/clamav.sh
}
#################################################################################
#################################################################################
#################################################################################


main() {
  modify_motd
  apt_install_prerequisites
  apt_install_docker
  apt_install_scanners
  apt_install_zeek
  #install_arkime # Requires Docker. Tested w/2 CPU cores, 4GB
  install_binlex
  install_metasploit
  install_sliverc2
  install_radare2
  install_yara
  install_pywhat
  #install_barq
  install_fennec
  install_spiderfoot
  get_airstrike
  docker_evilwinrm
  docker_powershell_empire
  docker_crackmapexec
  docker_clamav
  ### clean up
  apt -y autoremove
}

main
exit 0