#!/bin/bash

private_user=andrew
private_host=prometheus.aregner.net
private_port=22
# must be a bzip2 compressed tarball
private_file=.adrtools_private.tar.bz2

keyfile=$basedir/private_access_key

generate_key() {
    rm -f $keyfile 2>/dev/null
    ssh-keygen -C "auth updates" -N "" -f $keyfile > /dev/null
    echo "Copying new public key to the server..."
    cat $keyfile.pub | ssh -p $private_port -l $private_user $private_host "sh -c 'mkdir ~/.ssh ; tee -a ~/.ssh/authorized_keys'"
}

ssh_config="Host $private_host\nUser $private_user\nPort $private_port\nIdentityFile $keyfile"

# check for ssh config based on what we want
# (assume that it is all set for updates)
if [[ -z $update && -f ~/.ssh/config ]]; then
    echo "WARNING: existing ~/.ssh/config detected!  Will not try to alter it with" >&2
    echo "the host and port settings we have.  You should do this manually:" >&2
    echo -e "\nExample:\n$ssh_config" >&2
else
    echo -e $ssh_config > ~/.ssh/config
fi

private_stat=$(stat -c '%s %y' $basedir/private.tar.bz2 2>/dev/null)

rsync -tpr $private_host:$private_file $basedir/private.tar.bz2

# private file was changed, extract it
if [[ "$()" != $private_stat ]]; then
    cd $home
    tar xvjf $basedir/private.tar.bz2
fi
