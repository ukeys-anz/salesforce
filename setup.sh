#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e
green=`tput setaf 2`
red=`tput setaf 1`
reset=`tput sgr0`

stepNo=0
JOB_START_TIME=""
JOB_END_TIME=""
# first argument: description of the step
# second argument: step number
# third argument: start of a step?
function echoMessageCreator(){
    if [ $3 = true ]; then
        JOB_START_TIME=$(date +%s)
        echo ""
        echo "${red}-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        echo ""
        echo "${green}Step $2 : $1"
        echo ""
        echo "Start time and date: $(date)"
        echo "${reset}"
    else
        JOB_END_TIME=$(date +%s)
        echo ""
        echo "${green}Finish time and date: $(date)"
        echo ""
        echo "Job finished in $((JOB_END_TIME - JOB_START_TIME)) s."
        echo ""
        echo "${red}*****************************************"
        echo ""
        stepNo=$(($stepNo+1))
    fi
}
# to clean the artefact and tmp folders
rm -rf ./artefact
rm -rf ./tmp

echo "${red}"
echo "WARNING: Disable ANZ Proxy to run this script"
echo "You can leave alpaca running and proxy variables set to localhost:3128"
echo "${reset}"
# Using SOAP over REST is much faster for scratch org creations while pushing content.
sfdx config:set restDeploy=false
# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

# user input
echoMessageCreator "Input: Scratch org alias and Data" $stepNo true
read -rp "${green}Enter scratch org alias (optional): " scratchorgalias
read -rp "Is test data needed for this scratch org (y/n)? " testdata
read -rp "Preload ANZ Plus test data (y/n)? " preloadANZPlusData
echoMessageCreator "" $stepNo false
###########################

# make a new scratchOrg step
echoMessageCreator "Making scratchOrg out of the snapshot" $stepNo true
sfdx force:org:create -f config/snapshot-scratch-def-template.json -d 30 --setdefaultusername -w 10 --setalias "$scratchorgalias" 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) && ($(cat stderr) != *'Some commands may not work as expected until the My Domain DNS propagation'*) || ($(cat stderr) == *'statusCode=502'*) ]]; then
    echo ""
    echo "${green}* please run the below command in another terminal tab"
    echo ""
    echo "${red}--------------------------------------"
    echo "${green}sfdx force:org:create -f config/snapshot-scratch-def-template.json -d 30 --setdefaultusername -w 10 --setalias "$scratchorgalias" 2>&1 | tee stderr"
    echo "${red}--------------------------------------"
    echo ""
    echo "${green}* do not worry about the tunnelSocket error."
    echo ""
    read -rp "when it has been finished, just type (y/Y): " nextStepFlag
fi
echoMessageCreator "" $stepNo false
###########################

ALL_START_TIME=$(date +%s)

# check if the scratchOrg has been created out of th snapshot
echoMessageCreator "check if the scratchOrg has been created out of the snapshot" $stepNo true
sfdx force:org:list
echo ""
read -rp "${green}check if the scratchOrg with $scratchorgalias alias has been made(y/n)? " scratchMade
if [[ $scratchMade == n || $scratchMade == N ]];then
    echo ""
    echo "${red}exit and re-run it again"
    exit 1
fi
echoMessageCreator "" $stepNo false
###########################

# build the artifact 
echoMessageCreator "making artifact folder" $stepNo true
# to make the artifact from the diff
source ./ci/build-artifact.sh
echoMessageCreator "" $stepNo false
###########################

# manual steps
echoMessageCreator "manual steps" $stepNo true
read -rp "${green}Do you want to open the scratch org (y/n)? " openOrg
echo "${reset}"
if [[ $openOrg == y || $openOrg == Y ]]; then
    sfdx force:org:open -u $scratchorgalias 
fi

echo ""
echo "${green}************************"
echo ""
echo "Waiting while the job in scratchOrg is finished."
echo ""
echo "************************"
echo ""

echo "You can run your manual commands in another terminal window and then continue the other steps"
echo ""
read -rp "Do you want to continue (y/n)? " continueFlag
if [[ $continueFlag == n || $continueFlag == N ]]; then
    echo ""
    echo "The diff metadata has not been deployed."
    echo "You can run: sfdx force:source:deploy -u $scratchorgalias -p ./artefact/ | tee stderr"
    echo ""
    exit 1
fi
echoMessageCreator "" $stepNo false
###########################

if [ -d "./artefact/" ]; then

    # push metadata
    echoMessageCreator "deploy the diff metadata" $stepNo true

    tryDeploying=true
    while [[ $tryDeploying == true ]]; do
        tryDeploying=false
        sfdx force:source:deploy -u $scratchorgalias -p artefact | tee stderr
        if [[ ($(cat stderr) == *'ERROR'*) || ($(cat stderr) == *'Error'*) || ($(cat stderr) == *'statusCode=502'*) ]]; then
            
        # step: to if it is faild, make it to re-run, or try again, and you can check the stderr one
            echo "${green}"
            echo "Maybe you need to do some manual steps."
            echo "Please check the stderr file."
            echo ""
            read -rp "Do you want to retry deploying (y/n)? " retryFlag
            if [[ $retryFlag == n || $retryFlag == N ]]; then
                echo ""
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

# load data, create test user
case ${preloadANZPlusData:0:1} in
y | Y)
    echoMessageCreator "Pre-loading sample data" $stepNo true
    sfdx force:apex:execute -f ./apex-scripts/createTestData.apex
    echoMessageCreator "" $stepNo false

    echoMessageCreator "Creating test users (inactive by default) with different roles" $stepNo true
    sfdx force:apex:execute -f ./apex-scripts/createTestUsers.apex
    echoMessageCreator "" $stepNo false
    ;;
*) echo "Skipping ANZ plus test data preload" ;;
esac
###########################

# import test data and users
case ${testdata:0:1} in
y | Y)
    echoMessageCreator "Import test data and users" $stepNo true
    #below will fetch the latest changes from the remote master branch as its the branch specified in salesforce-scripts submodule
    git submodule update --init --remote
    #Add all the scripts to load data below
    sfdx force:user:permset:assign -n Read_Write_Customer_Details    
    node salesforce-scripts/generateTestData/loadFinancialGoals.js 2>&1 | tee stderr
    # Uncomment the next line (and comment the next) to import products without their related cases
    #sfdx force:data:bulk:upsert --sobjecttype Product2 --csvfile data/IDR-ANZ-Products.csv --externalid ANZ_Product_Code__c --wait 2 2>&1 | tee stderr
    sfdx force:data:tree:import -p data/IDR-Product2-Case-plan.json 2>&1 | tee stderr
    if [[ ($(cat stderr) == *'ERROR'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
        exit 1
    fi
    
    echo "${green}"
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

    echoMessageCreator "" $stepNo false
    ;;
*) echo "${green}Skipping test data creation" ;;
esac
###########################



ALL_END_TIME=$(date +%s)
echo "${green}"
echo "$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s."

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