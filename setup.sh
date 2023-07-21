#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

# to use all the functions that we need and do not repeat the code
source ./ci/bash-scripts/commonFunctions.sh


trap ctrl_c INT

function ctrl_c() {
    # git checkout .
    echo "${red}"
    echo "Making scracthOrg has been stopped."
    echo ""
    read -rp "${green}If the scratchOrg has not been created, or you want to delete it, please type y/Y : ${reset}" deleteScratchOrgFlag
    if [[ $deleteScratchOrgFlag == 'y' || $deleteScratchOrgFlag == 'Y' ]];then
        echo ""
        sfdx force:org:delete -u $scratchorgalias | tee stderr
        echo ""
    fi
    exit 1
    echo "${red}-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-${reset}"
}

# to clean the artefact and tmp folders
rm -rf ./artefact
rm -rf ./tmp

# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

# user input
echoMessageCreator "Input: Scratch org alias and Data" $stepNo true
read -rp "${green}Enter scratch org alias (optional): " scratchorgalias
read -rp "Is this Scratch Org for Commercial CRM Project? (y/n) " ccrmpartycheck
read -rp "Preload ANZ Plus test data (y/n)? " preloadANZPlusData
read -rp "Preload CMOS test data (y/n)? " preloadCMOSData
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
    echo "${red}exit and re-run it again${reset}"
    echo ""
    sfdx force:org:delete -u $scratchorgalias | tee stderr
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
        sfdx force:mdapi:deploy -u $scratchorgalias -d artefact -w 10 | tee stderr
        if [[ ($(cat stderr) == *'ERROR'*) || ($(cat stderr) == *'Error'*) || ($(cat stderr) == *'statusCode=502'*) ]]; then
            
            # step: to if it is failed, make it to re-run, or try again, and you can check the stderr one
            echo "${green}"
            echo "Maybe you need to do some manual steps."
            echo "Please check the stderr file."
            echo ""
            read -rp "Do you want to continue without pushing the diff metdata (y/n)? ${reset}" ignorePushingMetadata
            if [[ $ignorePushingMetadata == 'y' || $ignorePushingMetadata == 'Y' ]];then
                tryDeploying=false
            else
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
        fi
    done
    echoMessageCreator "" $stepNo false
    #########################
fi 

# assign a role to default user of scratchOrg
echoMessageCreator "assign a role to default user of scratchOrg" $stepNo true
sfdx force:apex:execute -f ./ci/apex-scripts/assignUserRole.apex
echoMessageCreator "" $stepNo false
###########################

# apply perm sets
echoMessageCreator "apply customer details perm set" $stepNo true
sfdx force:user:permset:assign -n Read_Write_Customer_Details | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) || ($(cat stderr) == *'Error'*) || ($(cat stderr) == *'statusCode=502'*) ]]; then
    cat stderr
fi
echoMessageCreator "" $stepNo false
###########################

# load data, create test user
case ${preloadANZPlusData:0:1} in
y | Y)
    echoMessageCreator "Pre-loading sample anzx data" $stepNo true
    sfdx force:apex:execute -f ./ci/apex-scripts/createTestData.apex
    echoMessageCreator "" $stepNo false

    echoMessageCreator "Creating test users (inactive by default) with different roles" $stepNo true
    sfdx force:apex:execute -f ./ci/apex-scripts/createTestUsers.apex
    echoMessageCreator "" $stepNo false
    ;;
*) echo "${green}Skipping ANZ plus test data preload${reset}" ;;
esac
###########################

# import cmos test data
case ${preloadCMOSData:0:1} in
y | Y)
    echoMessageCreator "Pre-loading sample cmos data" $stepNo true
    # Uncomment the next line (and comment the next) to import products without their related cases
    #sfdx force:data:bulk:upsert --sobjecttype Product2 --csvfile data/IDR-ANZ-Products.csv --externalid ANZ_Product_Code__c --wait 2 2>&1 | tee stderr
    sfdx force:data:tree:import -p data/IDR-ProductFamily-Product2-Case-plan.json 2>&1 | tee stderr
    if [[ ($(cat stderr) == *'ERROR'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
        exit 1
    fi

    echoMessageCreator "" $stepNo false
    ;;
*) echo "${green}Skipping CMOS test data preload${reset}" ;;
esac
###########################

case ${ccrmpartycheck:0:1} in
y | Y)
    echoMessageCreator "Pre-loading CCRM data" $stepNo true
    sfdx force:data:bulk:upsert --sobjecttype Industry__c --csvfile data/CCRM-Industry__c.csv --externalid Code__c --wait 2 2>&1 | tee stderr
    sfdx force:data:tree:import -p data/Reciprocal-plan.json 2>&1 | tee stderr
    if [[ ($(cat stderr) == *'ERROR'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
        exit 1
    fi

    echoMessageCreator "" $stepNo false
    ;;
*) echo "${green}Skipping CCRM data preload${reset}" ;;
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
