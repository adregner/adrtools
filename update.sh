#!/bin/sh

cd $(dirname $0)

status=$(git pull 2>&1 | grep -q "Already up-to-date.")

if [[ -z "$status" ]]; then
  # there the repo has been updated
  cat .our-user | ./init.sh
else
  # no change
  exit 0
fi
