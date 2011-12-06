#!/bin/sh
cd $basedir/filesystem
rsync -ctpr --exclude "home/username" * /
