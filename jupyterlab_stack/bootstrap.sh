#!/bin/bash

function systemd_jupyter_instance() {
  echo "setting up systemd for jupyter at localhost:8888"

 # using IPython security lib to hash password. Eventually this will be change to user input or randomly generated password surfaced as terraform output.
  pass=$(python -c "from IPython.lib.security import passwd; print(passwd('${password}'))")
  cat <<EOF > /etc/systemd/system/jupyterInst.service
  [Unit]
  Description=Jupyter instance

  [Service]
  User=opc
  Group=opc
  WorkingDirectory=/home/opc/
  ExecStart=/usr/local/bin/jupyter-notebook --ip=0.0.0.0 --port 8888 --NotebookApp.password="$pass"

  [Install]
  WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl is-active --quiet jupyterInst && sudo systemctl stop jupyterInst
  sudo systemctl enable --now jupyterInst
  sudo systemctl status jupyterInst
}

function open_firewall_port_offline() {
  echo "Opening port ${jupyter_port} and ${vnc_port} for jupyter notebook"
  sudo systemctl stop firewalld || true
  # using firewall-offline-cmd to open ports before firewalld service becomes active. results in faster access to jupyter notebook
  sudo firewall-offline-cmd --zone=public --add-port=${jupyter_port}
  sudo firewall-offline-cmd --zone=public --add-port=${vnc_port}
  sudo firewall-offline-cmd --zone=public --add-port=${ttyd_port}
  sudo systemctl start firewalld || true

}

function open_firewall_port_online() {
  echo "Opening port ${jupyter_port} and ${vnc_port} for jupyter notebook"
  sudo firewall-cmd --permanent --zone=public --add-port=${jupyter_port}
  sudo firewall-cmd --permanent --zone=public --add-port=${vnc_port}
  sudo firewall-cmd --permanent --zone=public --add-port=${ttyd_port}
  sudo firewall-cmd --reload

}

function install_gui() {
  echo "Installing Graphical Desktop"
  sudo dnf groupinstall -y "Server with GUI"
  sudo systemctl set-default graphical
  if ! grep '^WaylandEnable=false' /etc/gdm/custom.conf; then sudo sed -i '/^\[daemon\]/a WaylandEnable=false' /etc/gdm/custom.conf; fi
}

function install_packages() {
  echo "Installing tiger vnc"
  dnf install -y \
    tigervnc-server \
    tigervnc-server-module \
    git
}

function install_python_libs() {
  echo "Installing python numpy for websockify to work"
  sudo pip3 install numpy
  echo "Installing Jupyter notebook"
  sudo pip3 install --upgrade setuptools
  sudo pip3 install --upgrade pip
  sudo pip3 install jupyterlab

}


function install_no_vnc() {
  echo "Installing no vnc"
  sudo mkdir -p /opt/novnc
  sudo chown -R opc /opt/novnc
  pushd /opt/novnc
  git clone https://github.com/novnc/noVNC
  popd
}

function install_fuse_driver() {
  echo "Installing fuse driver"
  sudo yum-config-manager --enable ol8_developer_EPEL 
  sudo yum -y install s3fs-fuse jq python36-oci-cli 
  sudo chmod +x /usr/bin/fusermount 
}

function systemd_tiger_vnc_server() {
  echo "setting up systemd for vncserver at localhost:5901"
# create this directory for vncsession to create log file under it.

mkdir -p /home/opc/.vnc/
sudo echo ${password} | vncpasswd -f > /home/opc/.vnc/passwd

sudo mkdir -p /home/opc/.vnc
sudo chown -R opc /home/opc/.vnc
sudo cat <<EOF > /etc/tigervnc/vncserver.users
:1=opc
EOF

sudo cat <<EOF > /etc/tigervnc/vncserver-config-defaults
PasswordFile="~/.vnc/passwd"
session=gnome
geometry=1280x1024
SecurityTypes=VncAuth
localhost
alwaysshared
EOF

sudo mkdir -p /etc/systemd/system/vncserver@.service.d/
sudo cat <<EOF > /etc/systemd/system/vncserver@.service.d/10-restart.conf
[Service]
Restart=always
RestartSec=60
EOF

sudo systemctl daemon-reload
sudo systemctl is-active --quiet vncserver@:1 && sudo systemctl stop vncserver@:1
sudo systemctl enable --now vncserver@:1
sudo systemctl status vncserver@:1
}

function systemd_no_vnc_server() {
  echo "setting up systemd for novnc at localhost:5801"
cat <<EOF > /etc/systemd/system/novnc.service
[Unit]
Description=VNC Web Viewer

[Service]
Environment=HOME=/opt/novnc
ExecStart=/opt/novnc/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:5801

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl is-active --quiet novnc && sudo systemctl stop novnc
sudo systemctl enable --now novnc
sudo systemctl status novnc
}

function disable_osms() {
    sudo osms unregister
}

function oracle_cloud_agent_run_command_sudo() {
  echo "enable run command to run as sudo"
cat <<EOF > /tmp/101-oracle-cloud-agent-run-command
ocarun ALL=(ALL) NOPASSWD:ALL
EOF

visudo -cf /tmp/101-oracle-cloud-agent-run-command && sudo cp /tmp/101-oracle-cloud-agent-run-command /etc/sudoers.d/
}

function install_ttyd {
  cd /opt
  sudo wget https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64
  sudo chown $(whoami) ttyd.x86_64
  sudo chmod +x ttyd.x86_64

cat <<EOF > /etc/systemd/system/ttyd.service
[Unit]
Description=TTYD
After=syslog.target
After=network.target

[Service]
ExecStart=/opt/ttyd.x86_64 --credential ${uname}:${password} bash
Type=simple
Restart=always
User=opc
Group=opc

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl is-active --quiet ttyd && sudo systemctl stop ttyd
  sudo systemctl enable --now ttyd
  sudo systemctl status ttyd
}

# the sequencing here needs to be smart to start services proactively
function main() {
  # Phase 1
  open_firewall_port_offline
  disable_osms
  oracle_cloud_agent_run_command_sudo

  # Phase 2
  install_fuse_driver
  install_python_libs

  # Phase 3
  systemd_jupyter_instance
  install_ttyd

  # Phase 4
  install_gui
  install_packages
  install_no_vnc
  systemd_tiger_vnc_server
  systemd_no_vnc_server

  # Phase 5
  open_firewall_port_online
}

main
# now open a local ssh tunnel to your instance to access novnc
# ssh -L 5801:localhost:5801 opc@public_ip
# http://localhost:5801/vnc.html
