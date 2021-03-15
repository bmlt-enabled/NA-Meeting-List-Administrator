#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs
jazzy   --github_url https://github.com/bmlt-enabled/NA-Meeting-List-Administrator\
        -b -scheme,"NA Meeting List Administrator (Release)" \
        --readme ./README.md\
        --title NA\ Meeting\ List\ Administrator\ Documentation \
        --min-acl private
cp icon.png docs/icon.png
cd "${CWD}"
