#!/bin/bash

# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

ALL_START_TIME=$(date +%s)

#read -p "Enter Scratch Org Alias: " scratchorgname

echo "$(date): Create scratch org..."
JOB_START_TIME=$(date +%s)
sfdx force:org:create -f config/snapshot-scratch-def-template.json -d 30 --setdefaultusername -w 10 2>stderr
if [[ $(cat stderr) == *'Some commands may not work as expected until the My Domain DNS propagation'* ]]; then
    echo $(cat stderr)
elif [[ $(cat stderr) == *'ERROR'* ]]; then
    echo $(cat stderr)
    exit 0
fi    
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Assign Pset..."
JOB_START_TIME=$(date +%s)
sfdx force:user:permset:assign -n FinancialServicesCloudStandard
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Push metadata..."
JOB_START_TIME=$(date +%s)
sfdx force:source:push
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Setup custom settings..."
JOB_START_TIME=$(date +%s)
sfdx force:data:tree:import -p data/Post-Plan.json
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

ALL_END_TIME=$(date +%s)
echo "$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s."
echo "Open scratch org..."
sfdx force:org:open
