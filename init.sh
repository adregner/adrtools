#!/bin/bash

# get the required user settings
if [[ $UID == 0 ]]; then
  if [[ "$1" == "update" ]]; then
    username=$(cat .our-user)
    update="true"
  else
    read -p "Enter a username to install to: " username
    update=""
  fi
  home=$(eval echo -n ~$username)
  id=$(id -u $username)
else
  echo "This setup script must be run with root privileges." > /dev/stderr
  exit 1
fi

# check dependencies
which git > /dev/null || (echo "git must be installed and on the PATH" && exit 1)

# get some local information about this system
cd $(dirname $0)
basedir=$(pwd)

# save the username for the update script
echo $username > $basedir/.our-user

# distro
if which lsb_release > /dev/null; then
  lsb_id=$(lsb_release --short --id)
  if [[ "$lsb_id" == "LinuxMint" ]]; then
    dist="mint"
  elif [[ "$lsb_id" == "Ubuntu" ]]; then
    dist="ubuntu"
  else
    dist="debian"
  fi
  pkgman="apt"
elif [[ -f /etc/redhat-release ]]; then
  if grep -qi centos /etc/redhat-release; then
    dist="centos"
  else
    dist="redhat"
  fi
  pkgman="rpm"
elif [[ -f /etc/gentoo-release ]]; then
  dist="gentoo"
else
  dist="unknown"
  pkgman="unknown"
fi

# export things
myenv=""
myvars="username home id basedir dist update pkgman"
export $myvars

for v in $myvars; do
  pair="$v=$(eval echo \$$v)"
  echo $pair
  myenv="$myenv $pair"
done

# set up scripts
function run_setup() {
  for script in $(ls setup.$1.d/); do
    script="$basedir/setup.$1.d/$script"
    if [[ -x "$script" ]]; then
      if [[ "$1" == "user" ]]; then
        sudo -u $username $myenv $script
      elif [[ "$1" == "system" ]]; then
        $script
      fi
    fi
  done
}

# ...run them
run_setup user
run_setup system

# automatic updates
echo "0   */4   *   *   *   root   $basedir/update.sh" #> /etc/cron.d/adrtools
