#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

stepNo=0
# first argument: description of the step
# second argument: step number
# third argument: start of a step of end of that
function echoMessageCreator(){
    if [ $3 = true ]; then
        echo ""
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        echo ""
        if [ $2 = 0 ]; then    
            echo "Step 0 : Input scratch org alias and data"
        else
            echo ""
            echo "Step $2 : $1"
            echo ""
            echo "Start time and date: $(date)"
        fi
        echo ""
    else
        if [ $2 != 0 ]; then
            echo ""
            echo "Finish time and date: $(date)"
            echo ""
            echo "Job finished in $((JOB_END_TIME - JOB_START_TIME)) s."
        fi
        echo ""
        echo "*****************************************"
        echo ""
        stepNo=$(($stepNo+1))
    fi
}

echo "WARNING: Disable ANZ Proxy to run this script\n(You can leave alpaca running and proxy variables set to localhost:3128)"
# Using SOAP over REST is much faster for scratch org creations while pushing content.
sfdx config:set restDeploy=false
# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

echoMessageCreator "Input: Scratch org alias and Data" $stepNo true
read -rp "Enter scratch org alias (optional): " scratchorgalias
read -rp "Is test data needed for this scratch org (y/n)? " testdata
read -rp "Preload ANZ Plus test data (y/n)? " preloadANZPlusData
echoMessageCreator "" $stepNo false

ALL_START_TIME=$(date +%s)

echoMessageCreator "Create scratch org" $stepNo true
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
echoMessageCreator "" $stepNo false

echoMessageCreator "Assign Permission sets" $stepNo true
JOB_START_TIME=$(date +%s)
sfdx force:user:permset:assign -n "FinancialServicesCloudStandard,EinsteinAnalyticsPlusAdmin" 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) && ($(cat stderr) != *'Duplicate PermissionSetAssignment'*)]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echoMessageCreator "" $stepNo false

echoMessageCreator "Deploy settings and content assets" $stepNo true
JOB_START_TIME=$(date +%s)
sfdx force:source:deploy -p force-app/main/default/settings/BusinessHours.settings-meta.xml,force-app/main/default/settings/Quote.settings-meta.xml,force-app/main/default/settings/Forecasting.settings-meta.xml,force-app/main/default/contentassets 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) ]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echoMessageCreator "" $stepNo false

echoMessageCreator "Push metadata" $stepNo true
JOB_START_TIME=$(date +%s)
sfdx force:source:push -f 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) ]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echoMessageCreator "" $stepNo false
<<<<<<< Updated upstream
=======
###########################

if [ -d "./artefact/" ]; then

    # push metadata
    echoMessageCreator "deploy the diff metadata" $stepNo true

    tryDeploying=true
    while [[ $tryDeploying == true ]]; do
        tryDeploying=false
        sfdx force:mdapi:deploy -u $scratchorgalias -d artefact -w 10 | tee stderr
        if [[ ($(cat stderr) == *'ERROR'*) || ($(cat stderr) == *'Error'*) || ($(cat stderr) == *'statusCode=502'*) ]]; then
            
        # step: to if it is failed, make it to re-run, or try again, and you can check the stderr one
            echo "${green}"
            echo "Maybe you need to do some manual steps."
            echo "Please check the stderr file."
            echo ""
            read -rp "Do you want to retry deploying (y/n)? " retryFlag
            echo "${reset}"
            if [[ $retryFlag == n || $retryFlag == N ]]; then
                echo "${green}"
                echo "The job has been skipped."
                echo ""
                exit 1
            else
                tryDeploying=true
            fi
        fi
    done
    echoMessageCreator "" $stepNo false
    #########################
fi 
>>>>>>> Stashed changes

echoMessageCreator "Import post-deployment plan" $stepNo true
JOB_START_TIME=$(date +%s)
sfdx force:data:tree:import -p data/Post-Plan.json 2>&1 | tee stderr
sfdx force:data:tree:import -p data/IDR-CustomSetting.json 2>&1 | tee stderr
node createCmosEntitlment.js 2>&1 | tee stderr
sfdx force:data:tree:import -f data/Non_Prod_Settings__c.json 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) ]]; then
    exit 1
fi
JOB_END_TIME=$(date +%s)
echoMessageCreator "" $stepNo false

case ${preloadANZPlusData:0:1} in
y | Y)
    echoMessageCreator "Pre-loading sample data" $stepNo true
    JOB_START_TIME=$(date +%s)
    sfdx force:apex:execute -f ./apex-scripts/createTestData.apex
    JOB_END_TIME=$(date +%s)
    echoMessageCreator "" $stepNo false

    echoMessageCreator "Creating test users (inactive by default) with different roles" $stepNo true
    JOB_START_TIME=$(date +%s)
    sfdx force:apex:execute -f ./apex-scripts/createTestUsers.apex
    JOB_END_TIME=$(date +%s)
    echoMessageCreator "" $stepNo false
    ;;
*) echo "Skipping ANZ plus test data preload" ;;
esac

case ${testdata:0:1} in
y | Y)
    echoMessageCreator "Import test data and users" $stepNo true
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
    
    echo ""
    echo "-=- Creating Coach user -=-"
    echo ""
    node webdriverIO/setup-scripts/createUser.js --profile "coach"
    echo ""
    echo "-=- Creating IDR user -=-"
    echo ""
    node webdriverIO/setup-scripts/createUser.js --profile "idr level 3"
    echo ""
    echo "-=- Assigning user roles -=-"
    echo ""
    sfdx force:apex:execute -f ./apex-scripts/assignUserRole.apex
    echo ""
    echo "-=- Create users json for webdriverIO -=-"
    echo ""
    node webdriverIO/setup-scripts/createUserJsonList.js

    JOB_END_TIME=$(date +%s)
    echoMessageCreator "" $stepNo false
    ;;
*) echo "Skipping test data creation" ;;
esac

ALL_END_TIME=$(date +%s)
echo ""
echo "$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s."

echoMessageCreator "Resetting source tracking" $stepNo true
sfdx force:source:tracking:reset -p
echoMessageCreator "" $stepNo false

echoMessageCreator "Open scratch org" $stepNo true
sfdx force:org:open
echoMessageCreator "" $stepNo false