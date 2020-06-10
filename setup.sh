#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

read -rp "Enter scratch org alias (optional): " scratchorgalias

ALL_START_TIME=$(date +%s)

echo "$(date): Create scratch org..."
JOB_START_TIME=$(date +%s)
if [ -n "$scratchorgalias" ]
    then sfdx force:org:create -f config/snapshot-scratch-def-template.json -d 30 --setdefaultusername -w 10 --setalias "$scratchorgalias" 2>&1 | tee stderr
    else sfdx force:org:create -f config/snapshot-scratch-def-template.json -d 30 --setdefaultusername -w 10 2>&1 | tee stderr
fi
if [[ ($(cat stderr) == *'ERROR'* ) && ( $(cat stderr) != *'Some commands may not work as expected until the My Domain DNS propagation'* ) ]]; then
    exit 1
fi    
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Assign Pset and deploy settings..."
JOB_START_TIME=$(date +%s)
sfdx force:user:permset:assign -n FinancialServicesCloudStandard 2>&1 | tee stderr
sfdx force:source:deploy -p force-app/main/default/settings 2>&1 | tee stderr
sfdx force:mdapi:deploy -d mdapi-source/app-config -w -1 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'* ) ]]; then
    exit 1
fi 
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Push metadata..."
JOB_START_TIME=$(date +%s)
sfdx force:source:push 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'* ) ]]; then
    exit 1
fi 
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Import custom settings and sample records..."
JOB_START_TIME=$(date +%s)
sfdx force:data:tree:import -p data/Post-Plan.json 2>&1 | tee stderr
# Uncomment the next line (and comment the next) to import products without their related cases
#sfdx force:data:bulk:upsert --sobjecttype Product2 --csvfile data/IDR-ANZ-Products.csv --externalid ANZ_Product_Code__c --wait 2 2>&1 | tee stderr
sfdx force:data:tree:import -p data/IDR-Product2-Case-plan.json 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'* ) ]]; then
    exit 1
fi 
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "Creating Coach user"
node createUser.js --profile Coach

echo "Creating IDR user"
node createUser.js --profile "IDR Level 1"

ALL_END_TIME=$(date +%s)
echo "$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s."
echo "Open scratch org..."
sfdx force:org:open
