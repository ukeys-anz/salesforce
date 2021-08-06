#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e
# Using SOAP over REST is much faster for scratch org creations while pushing content.
sfdx config:set restDeploy=false
# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

read -rp "Enter scratch org alias (optional): " scratchorgalias
read -rp "Is test data needed for this scratch org (y/n)? " testdata
read -rp "Preload ANZ Plus test data (y/n)? " preloadANZPlusData

ALL_START_TIME=$(date +%s)

echo "$(date): Create scratch org..."
JOB_START_TIME=$(date +%s)
if [ -n "$scratchorgalias" ]; then
    sfdx force:org:create -f config/snapshot-scratch-def-template.json -d 30 --setdefaultusername -w 10 --setalias "$scratchorgalias" 2>&1 | tee stderr
else
    sfdx force:org:create -f config/snapshot-scratch-def-template.json -d 30 --setdefaultusername -w 10 2>&1 | tee stderr
fi
if [[ ($(cat stderr) == *'ERROR'*) && ($(cat stderr) != *'Some commands may not work as expected until the My Domain DNS propagation'*) ]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Assign Pset..."
JOB_START_TIME=$(date +%s)
sfdx force:user:permset:assign -n FinancialServicesCloudStandard 2>&1 | tee stderr
sfdx force:user:permset:assign -n EinsteinAnalyticsPlusAdmin 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) && ($(cat stderr) != *'Duplicate PermissionSetAssignment'*)]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Deploy settings..."
JOB_START_TIME=$(date +%s)
sfdx force:source:deploy -p force-app/main/default/settings/BusinessHours.settings-meta.xml,force-app/main/default/settings/Quote.settings-meta.xml,force-app/main/default/settings/Forecasting.settings-meta.xml  2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) ]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Deploy content assets......"
JOB_START_TIME=$(date +%s)
sfdx force:source:deploy -p force-app/main/default/contentassets 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) ]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Push metadata..."
JOB_START_TIME=$(date +%s)
sfdx force:source:push -f 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) ]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Import post-deployment plan..."
JOB_START_TIME=$(date +%s)
sfdx force:data:tree:import -p data/Post-Plan.json 2>&1 | tee stderr
sfdx force:data:tree:import -p data/IDR-CustomSetting.json 2>&1 | tee stderr
node createCmosEntitlment.js 2>&1 | tee stderr
sfdx force:data:tree:import -f data/Non_Prod_Settings__c.json 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) ]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

case ${preloadANZPlusData:0:1} in
y | Y)
    echo "$(date): Pre-loading sample data..."
    JOB_START_TIME=$(date +%s)
    sfdx force:apex:execute -f ./apex-scripts/createTestData.apex
    JOB_END_TIME=$(date +%s)
    echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."
    echo "$(date): Creating test users (inactive by default) with different roles..."
    JOB_START_TIME=$(date +%s)
    sfdx force:apex:execute -f ./apex-scripts/createTestUsers.apex
    JOB_END_TIME=$(date +%s)
    echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."
    ;;
*) echo "Skipping ANZ plus test data preload" ;;
esac

case ${testdata:0:1} in
y | Y)
    echo "$(date): Import test data and users..."
    JOB_START_TIME=$(date +%s)
    tsc --project webdriverIO
    cp webdriverIO/.env.example webdriverIO/.env
    node webdriverIO/setup-scripts/envSetup.js
    #below will fetch the latest changes from the remote master branch as its the branch specified in salesforce-scripts submodule
    git submodule update --init --remote
    #Add all the scripts to load data below
    sfdx force:user:permset:assign -n Read_Write_Customer_Details    
    node salesforce-scripts/generateTestData/loadFinancialGoals.js 2>&1 | tee stderr
    # Uncomment the next line (and comment the next) to import products without their related cases
    #sfdx force:data:bulk:upsert --sobjecttype Product2 --csvfile data/IDR-ANZ-Products.csv --externalid ANZ_Product_Code__c --wait 2 2>&1 | tee stderr
    sfdx force:data:tree:import -p data/IDR-Product2-Case-plan.json 2>&1 | tee stderr
    if [[ ($(cat stderr) == *'ERROR'*) ]]; then
        exit 1
    fi
    
    echo "Creating Coach user"
    node webdriverIO/setup-scripts/createUser.js --profile "coach"

    echo "Creating IDR user"
    node webdriverIO/setup-scripts/createUser.js --profile "idr level 3"

    echo "Assigning user roles"
    sfdx force:apex:execute -f ./apex-scripts/assignUserRole.apex

    echo "Create users json for webdriverIO"
    node webdriverIO/setup-scripts/createUserJsonList.js

    JOB_END_TIME=$(date +%s)
    echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."
    ;;
*) echo "Skipping test data creation" ;;
esac

ALL_END_TIME=$(date +%s)
echo "$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s."

echo "Resetting source tracking..."
sfdx force:source:tracking:reset -p

echo "Open scratch org..."
sfdx force:org:open
