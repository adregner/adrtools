#!/bin/sh

cd `dirname $0`

status=`git pull 2>&1 | egrep -q "^Already up-to-date."`

if test $? -eq 1; then
  # the repo has been updated
  ./init.sh update
else
  # no change
  exit 0
fi
