#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    if [ -f IDRRestriction.txt ];then
        f=force-app/main/default/objects/Case/fields/IDR_Restriction_Level__c.field-meta.xml
        cp IDRRestriction.txt $f
        rm -rf IDRRestriction.txt
    fi
    if [ -f SIWorkflow.txt ]; then
        f=force-app/main/default/objects/Case/fields/SI_Workflow_Step__c.field-meta.xml    
        cp SIWorkflow.txt $f
        rm -rf SIWorkflow.txt
    fi
    echo ""
    echo "Making scracthOrg has been stopped."
}
stepNo=$(($stepNo+1))
JOB_START_TIME=""
JOB_END_TIME=""
# first argument: description of the step
# second argument: step number
# third argument: start of a step?
function echoMessageCreator(){
    if [ $3 = true ]; then
        JOB_START_TIME=$(date +%s)
        echo ""
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        echo ""
        echo "Step $2 : $1"
        echo ""
        echo "Start time and date: $(date)"
        echo ""
    else
        JOB_END_TIME=$(date +%s)
        echo ""
        echo "Finish time and date: $(date)"
        echo ""
        echo "Job finished in $((JOB_END_TIME - JOB_START_TIME)) s."
        echo ""
        echo "*****************************************"
        echo ""
        stepNo=$(($stepNo+1))
    fi
}


echo "WARNING: Disable ANZ Proxy to run this script"
echo "You can leave alpaca running and proxy variables set to localhost:3128"
echo ""
# Using SOAP over REST is much faster for scratch org creations while pushing content.
sfdx config:set restDeploy=false
# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

scratchorgalias=ANZxScratchOrg
ALL_START_TIME=$(date +%s)

# assign permission sets
echoMessageCreator "Assign Permission sets" $stepNo true
sfdx force:user:permset:assign -n "FinancialServicesCloudStandard,EinsteinAnalyticsPlusAdmin" 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) && ($(cat stderr) != *'Duplicate PermissionSetAssignment'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
    renameForceignore false
    exit 1
fi
echoMessageCreator "" $stepNo false
###########################

# deploy settings and content assests
echoMessageCreator "Deploy settings and content assets" $stepNo true
sfdx force:source:deploy -p force-app/main/default/settings/BusinessHours.settings-meta.xml,force-app/main/default/settings/Quote.settings-meta.xml,force-app/main/default/settings/Forecasting.settings-meta.xml,force-app/main/default/contentassets,force-app/main/default/objects/Case/fields/SLA_Status__c.field-meta.xml 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) || ($(cat stderr) == *'statusCode=502'*) ]]; then
    exit 1
fi
echoMessageCreator "" $stepNo false
###########################

# pre deploy : change on some files
echoMessageCreator "Pre Deploy Checking Step" $stepNo true
f=force-app/main/default/objects/Case/fields/IDR_Restriction_Level__c.field-meta.xml
context=$(<$f)

cp $f IDRRestriction.txt
if [[ $context == *'<trackFeedHistory>false</trackFeedHistory>'* ]];then
    replace=$( sed 's+<trackFeedHistory>false</trackFeedHistory>+<!--<trackFeedHistory>false</trackFeedHistory>-->+g' $f )
    echo $replace > $f
    replace=$( sed "s+<trackHistory>true</trackHistory>+<!--<trackHistory>true</trackHistory>-->+g" $f )
    echo $replace > $f
    replace=$( sed "s+<trackTrending>false</trackTrending>+<!--<trackTrending>false</trackTrending>-->+g" $f )
    echo $replace > $f
fi

f=force-app/main/default/objects/Case/fields/SI_Workflow_Step__c.field-meta.xml
context=$(<$f)
cp $f SIWorkflow.txt
if [[ $context == *'<controllingFieldValue>Open</controllingFieldValue>'* ]];then
    replace=$( sed "s+<controllingFieldValue>Open</controllingFieldValue>+<!--<controllingFieldValue>Open</controllingFieldValue>-->+g" $f)
    echo $replace > $f
fi

echoMessageCreator "" $stepNo false
###########################

# push metadata
echoMessageCreator "Push metadata" $stepNo true
tryDeploying=true
while [[ $tryDeploying == true ]]; do
    sfdx force:source:push -f 2>&1 | tee stderr

    if [[ ($(cat stderr) == *'ERROR'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
        echo ""
        echo "Maybe you need to do some manual steps."
        echo "Please check the stderr file."
        echo ""
        read -rp "Do you want to retry push the metadata (y/n)? " retryFlag
        if [[ $retryFlag == n || $retryFlag == N ]]; then
            echo ""
            echo "The job has been skipped."
            echo ""
            f=force-app/main/default/objects/Case/fields/IDR_Restriction_Level__c.field-meta.xml
            cp IDRRestriction.txt $f
            f=force-app/main/default/objects/Case/fields/SI_Workflow_Step__c.field-meta.xml    
            cp SIWorkflow.txt $f
            rm -rf IDRRestriction.txt
            rm -rf SIWorkflow.txt
            exit 1
        else
            tryDeploying=true
        fi
    else
        tryDeploying=false
    fi 
done
echoMessageCreator "" $stepNo false
###########################

# post deploy: to make all the files back to what it was and deploy them
echoMessageCreator "Post Deploy" $stepNo true
f=force-app/main/default/objects/Case/fields/IDR_Restriction_Level__c.field-meta.xml
cp IDRRestriction.txt $f    
sfdx force:source:deploy -p $f

f=force-app/main/default/objects/Case/fields/SI_Workflow_Step__c.field-meta.xml    
cp SIWorkflow.txt $f  
sfdx force:source:deploy -p $f

rm -rf IDRRestriction.txt
rm -rf SIWorkflow.txt
echoMessageCreator "" $stepNo false
###########################

# import post-deployment plan
echoMessageCreator "Import post-deployment plan" $stepNo true
sfdx force:data:tree:import -p data/Post-Plan.json 2>&1 | tee stderr
sfdx force:data:tree:import -p data/IDR-CustomSetting.json 2>&1 | tee stderr
node createCmosEntitlment.js 2>&1 | tee stderr
sfdx force:data:tree:import -f data/Non_Prod_Settings__c.json 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
    exit 1
fi
echoMessageCreator "" $stepNo false
###########################

ALL_END_TIME=$(date +%s)
echo ""
echo "$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s."

rm -rf ./artefact
rm -rf ./tmp
# reset source tracking
echoMessageCreator "Resetting source tracking" $stepNo true
sfdx force:source:tracking:reset -p
echoMessageCreator "" $stepNo false
###########################

# open scratch org
echoMessageCreator "Open scratch org" $stepNo true
sfdx force:org:open
echoMessageCreator "" $stepNo false
###########################