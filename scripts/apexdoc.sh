#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

# We need to clone the existing repo first so we can add the newly generated docs over the top
cd apexdoc
git clone https://github.service.anz/anzx/salesforce-docs.git
cd salesforce-docs
git checkout -b gh-pages origin/gh-pages
cd ../
mv salesforce-docs/ ApexDocumentation/
cd ../

# This shell script should be executed from the root directory of the Salesforce DX Project
# Apexdoc does not support sub directories, so we need to flatten the classes directory
find force-app/main/default/classes -mindepth 2 -type f -print -exec cp {} force-app/main/default/classes \;

# Now time to generate the docs
java -jar apexdoc/apexdoc.jar -s force-app/main/default/classes -t apexdoc/ -a apexdoc/banner.htm -h apexdoc/home.htm

# Now that the doc is generated, we will push the latest changes to the document repo
cd apexdoc/ApexDocumentation
git add .
git commit -m "Documentation updated"
git push