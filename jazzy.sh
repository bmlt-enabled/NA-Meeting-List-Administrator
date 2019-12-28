#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs
jazzy   --github_url https://github.com/bmlt-enabled/NA-Meeting-List-Administrator\
        --readme ./README.md\
        --title NA\ Meeting\ List\ Administrator\ Documentation \
        --min-acl private\
        --exclude */Carthage, */Pods
cp icon.png docs/icon.png
cd "${CWD}"
