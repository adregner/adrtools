#!/bin/bash

# local system's python information
python_major=$(python -c 'import sys; print sys.version_info.major')
python_minor=$(python -c 'import sys; print sys.version_info.minor')
python_site=$(python -c 'import site; print site.USER_SITE')

export python_major python_minor python_site

# create the site dir
[[ -d $python_site ]] || mkdir -p $python_site

# copy updated files to the site dir
cd $basedir/filesystem

rsync -ca "home/username/.local/lib/python2.x/*" $python_site/
