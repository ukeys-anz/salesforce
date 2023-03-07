#!/bin/sh

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

# to use all the functions that we need and do not repeat the code
source ./commonFunctions.sh

scratchorgalias='ANZxScratchOrg'

# input your email, to make sure that the defualt devhub is the production
echoMessageCreator "enter your dev hub alias" $stepNo true
read -rp "${green}Please enter your devhub alias (production): " prodname
echoMessageCreator "" $stepNo false
########################

cd ../..

# to clean the artefact and tmp folders
rm -rf ./artefact
rm -rf ./tmp

# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

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

# deploy bigObjects
echoMessageCreator "Deploy bigObjects" $stepNo true
sfdx force:source:deploy -p force-app/main/default/objects/Accessed_Record_Log__b
echo ""
sfdx force:source:deploy -p force-app/main/default/objects/Log_Record_Access__b
echo ""
sfdx force:source:deploy -p force-app/main/default/objects/Record_Access_Log__b
echo ""
sfdx force:source:deploy -p force-app/main/default/objects/Application_Trace_Log__b
echo ""
sfdx force:source:deploy -p force-app/main/default/objects/Traced_Application_Log__b
echoMessageCreator "" $stepNo false
###########################

# change forceignore to harness.forceignore as we will have all things in our snapshot
echoMessageCreator "change the forceignore to the proper one" $stepNo true
mv .forceignore ci.forceignore
cp harness.forceignore h.forceignore
mv harness.forceignore .forceignore
echo -e "\nforce-app/main/default/transactionSecurityPolicies" >> .forceignore
echo -e "\nforce-app/main/default/sharingRules" >> .forceignore
echo -e "\nforce-app/main/default/objects/Lead/fields/Id.field-meta.xml" >> .forceignore
echo -e "\nforce-app/main/default/permissionsetgroups/Shared_Admin.permissionsetgroup-meta.xml" >> .forceignore
echo -e "\nforce-app/main/default/permissionsetgroups/Muted_Backup_and_Restore.permissionsetgroup-meta.xml" >> .forceignore
echo -e "\nforce-app/main/default/objects/Accessed_Record_Log__b" >> .forceignore
echo -e "\nforce-app/main/default/objects/Log_Record_Access__b" >> .forceignore
echo -e "\nforce-app/main/default/objects/Record_Access_Log__b" >> .forceignore
echo -e "\nforce-app/main/default/objects/Application_Trace_Log__b" >> .forceignore
echo -e "\nforce-app/main/default/objects/Traced_Application_Log__b" >> .forceignore
echoMessageCreator "" $stepNo false
########################

# build the artifact 
echoMessageCreator "making artifact folder" $stepNo true
# to make the artifact from the diff
source ./ci/build-artifact.sh
echoMessageCreator "" $stepNo false
###########################

# pre deploy : change on some files on artefact folder ( tracking history )
echoMessageCreator "Pre Deploy Checking Step" $stepNo true
trackingFalseOnArtefact
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

# post deploy: to make all the files back to what it was and deploy them
echoMessageCreator "Post Deploy" $stepNo true
mv h.forceignore .forceignore
sfdx force:source:deploy -u $scratchorgalias -p "force-app/main/default/sharingRules"
echoMessageCreator "" $stepNo false
###########################

# assign a role to default user of scratchOrg
echoMessageCreator "assign a role to default user of scratchOrg" $stepNo true
sfdx force:apex:execute -f ./ci/apex-scripts/assignUserRole.apex
echoMessageCreator "" $stepNo false
###########################

# apply perm sets
echoMessageCreator "apply customer details perm set" $stepNo true
sfdx force:user:permset:assign -n Read_Write_Customer_Details 
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

# reset source tracking
echoMessageCreator "Resetting source tracking" $stepNo true
sfdx force:source:tracking:reset -p
echoMessageCreator "" $stepNo false
###########################

echoMessageCreator "check if you want to delete an existed snapshot" $stepNo true
sfdx force:org:snapshot:list
echo "${green}"
read -rp "Do you want to delete ReleaseSnapshot snapshot (y/n)? " deleteSnapshot
case ${deleteSnapshot:0:1} in
    y | Y)        
        snapshotName=ReleaseSnapshot
        sfdx force:org:snapshot:delete -s $snapshotName
        echo "************************"
        ;;
    *)
        echo "${red}Job has been skipped."
        exit 1
        ;;
esac
echoMessageCreator "" $stepNo false
########################

# create a new snapshot
echoMessageCreator "creating a new snapshot" $stepNo true
name=ReleaseSnapshot
developCommitSHA=$(git log develop --oneline --pretty=format:'%h' -1)
sfdx force:org:snapshot:create -n $name -d "Snapshot from $developCommitSHA" -o $scratchorgalias -v $prodname
waitTillSnapshotIsActive=false
while [[ $waitTillSnapshotIsActive == *'false'* ]]; do
    sfdx force:org:snapshot:list
    snapshotList=$( sfdx force:org:snapshot:list --json )
    if [[ $snapshotList == *"InProgress"* ]];then
        echo "${green}"
        echo "wait for another 1 mins"
        sleep 60
        echo "${reset}"
    else
        waitTillSnapshotIsActive=true
    fi
done
echoMessageCreator "" $stepNo false
#######################

# cleaning the job
echoMessageCreator "removing all changes made during creating snapshot" $stepNo true
rm -rf ci.forceignore
git checkout .

echo ""
echo "${green}new snapshot has been created${reset}"
echo "${green}create a new tag (snapshot-latest-<DDMMYYYY>)${reset}"
echo ""
echoMessageCreator "" $stepNo false
#######################
