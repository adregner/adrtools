#!/bin/sh
cd $basedir/filesystem/home/username
# this doesn't catch hidden items, which probably isn't a problem yet
rsync -ctpr * $home/
