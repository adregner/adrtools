#!/usr/bin/bash

if [[ $UID == 0 ]]; then
    read "Enter a username to install to: " username
    home=$(eval echo ~$username)
    id=$(id -u $username)
else
    username=$USER
    home=$HOME
    id=$UID
fi

pythonversion=python$(python --version 2>&1 | egrep -o '2.[4-9]')

sudo -u $username mkdir -pv "$home/bin" "$home/.local/lib/$pythonversion/site-packages"
sudo mkdir -pv "/usr/local/sbin" "/usr/local/bin" "/usr/local/lib"

for script in setup.d/*; do
  if [[ -x "$script" ]]; then
    ./$script
  fi
done
