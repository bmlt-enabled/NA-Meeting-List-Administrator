#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs
jazzy   --github_url https://github.com/bmlt-enabled/NA-Meeting-List-Administrator\
        --readme ./README.md\
        --theme fullwidth\
        --author BMLT-Enabled\
        --author_url https://bmlt.app\
        --min-acl private\
        --exclude */Carthage
cp icon.png docs/icon.png
cd "${CWD}"
