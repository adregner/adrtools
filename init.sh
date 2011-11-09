#!/usr/bin/bash

# get the required user settings
if [[ $UID == 0 ]]; then
    read "Enter a username to install to: " username
    home=$(eval echo ~$username)
    id=$(id -u $username)
else
    echo "This setup script must be run with root privileges." > /dev/stderr
    exit 1
fi

# check dependencies
which git > /dev/null || echo "git must be installed and on the PATH" && exit 1

# get some local information about this system
pythonversion=python$(python --version 2>&1 | egrep -o '2.[4-9]')
basedir=$(basedir $0)

# save the username for the update script
echo $username > $basedir/.our-user

# distro
if [[ -f /etc/lsb-release ]]; then
  if grep -qi ubuntu /etc/lsb-release; then
    dist="ubuntu"
  else
    dist="debian"
  fi
elif [[ -f /etc/redhat-release ]]; then
  if grep -qi centos /etc/redhat-release; then
    dist="centos"
  else
    dist="redhat"
  fi
elif [[ -f /etc/gentoo-release ]]; then
  dist="gentoo"
else
  dist="unknown"
fi

# export things
export username home id pythonversion basedir dist

env

# set up scripts
function run_setup() {
  for script in setup.$1.d/*; do
    if [[ -x "$script" ]]; then
      if [[ "$1" -eq "user" ]]; then
        sudo -u $username ./$script
      elif [[ "$1" -eq "system" ]]; then
        ./$script
      fi
    fi
  done
}

# ...run them
run_setup user
run_setup system

# automatic updates
echo "0   */4   *   *   *   root   $basedir/update.sh" > /etc/cron.d/adrtools
