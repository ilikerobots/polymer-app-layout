#!/usr/bin/env bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#remove unnecessary files from bower install
rm -rf $BASEDIR/../lib/src/app-layout/*/{test,demo,README.md}
rm -rf $BASEDIR/../lib/src/app-layout/{demo,patterns,site,templates,test,README.md,index.html,docs.html,bower.json,.travis.yml,.gitignore,.bower.json}
rm -rf $BASEDIR/../lib/src/iron-*/{test,demo,README.md,CONTRIBUTING.md}
rm -rf $BASEDIR/../lib/src/iron-*/{demo,patterns,site,templates,test,index.html,docs.html,bower.json,.travis.yml,.gitignore,.github,.bower.json}

#move the app-layout elements directly into lib/src dir
mv -t $BASEDIR/../lib/src $BASEDIR/../lib/src/app-layout/*  

#and update package paths
sed -i 's:"\.\./\.\./iron:"../iron:g' $BASEDIR/../lib/src/*/*.html
sed -i 's:"\.\./\.\./polymer:"../polymer:g' $BASEDIR/../lib/src/*/*.html
