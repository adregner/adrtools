#!/bin/sh
cd $basedir/filesystem
rsync -ca --exclude "home/username" * /
