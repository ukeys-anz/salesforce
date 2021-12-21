#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e
green=`tput setaf 2`
red=`tput setaf 1`
reset=`tput sgr0`
source ./snapshotScratch.sh
stepNo=0
JOB_START_TIME=""
JOB_END_TIME=""
# first argument: description of the step
# second argument: step number
# third argument: start of a step?
function echoMessageCreator(){
    if [ $3 = true ]; then
        JOB_START_TIME=$(date +%s)
        echo "${red}"
        echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        echo "${green}"
        echo "Step $2 : $1"
        echo ""
        echo "Start time and date: $(date)"
        echo "${reset}"
    else
        JOB_END_TIME=$(date +%s)
        echo "${green}"
        echo "Finish time and date: $(date)"
        echo ""
        echo "Job finished in $((JOB_END_TIME - JOB_START_TIME)) s."
        echo "${red}"
        echo "*****************************************"
        echo ""
        stepNo=$(($stepNo+1))
    fi
}

scratchorgalias='ANZxScratchOrg'

# input your email, to make sure that the defualt devhub is the production
echoMessageCreator "enter your dev hub alias" $stepNo true
read -rp "${green}Please enter your devhub alias (production): " prodname
echoMessageCreator "" $stepNo false
########################

# creating the scratchOrg
echoMessageCreator "creating the scratchOrg" $stepNo true
sfdx force:org:create -f config/project-scratch-def.json -a $scratchorgalias --setdefaultusername --durationdays 30
echoMessageCreator "" $stepNo false
########################

# check if the scratch org has been created
echoMessageCreator "check if the scrach org has been created" $stepNo true
sfdx force:org:list
echoMessageCreator "" $stepNo false
########################

# install managed packages
echoMessageCreator "install managed packages" $stepNo true
sfdx force:mdapi:deploy -d mdapi-source/packages/
echoMessageCreator "" $stepNo false
########################

# the install managed packages will take a while to be finished, this will ask to 
# check if a user need to wait more
echoMessageCreator "waiting step for a command" $stepNo true
newCommand=true
while [[ $newCommand == true ]]; do
    echo ""
    sfdx force:mdapi:deploy:report
    echo "${green}"
    read -rp "Do you want to continue waiting (y/n)? " manualSteps
    case ${manualSteps:0:1} in
    n | N)        
        echo ""
        newCommand=false
        ;;
    *) 
        echo "${green}"
        echo "wait for another 3 mins"
        sleep 180 
        ;;
    esac
done
echoMessageCreator "" $stepNo false
########################

# install unmanaged packages
echoMessageCreator "install unmanaged packages" $stepNo true
# observe 'apvId' attribute on the below browser URL for the package version ID
# open http://industries.force.com/financialservicescloudextension
# if it is not like below, change it to the new one
apvId=04t1E000001Iql5
sfdx force:package:install --package $apvId -w 20 --securitytype AllUsers
echoMessageCreator "" $stepNo false
########################

# checkout to develop and push all the metadata into the scratchOrg
echoMessageCreator "push all the metadata into the scratchOrg" $stepNo true
source ./snapshotScratch.sh
echoMessageCreator "" $stepNo false
########################

# check if you need to delete any existed snapshot 
# if there are 5 snapshots, it will ask the engineer to delete on of them
scratchOrgsCount=$(node ./sfdxCommandJsonInfo);
if [[ $scratchOrgsCount > 4 ]]; then

    echoMessageCreator "check if you want to delete an existed snapshot" $stepNo true
    sfdx force:org:snapshot:list
    echo "${green}"
    read -rp "Do you want to delete one (y/n)? " deleteSnapshot
    case ${deleteSnapshot:0:1} in
        y | Y)        
            echo "${green}"
            read -rp "Write the name of the snapshot to be deleted: " snapshotName
            echo "${reset}"
            sfdx force:org:snapshot:delete -s $snapshotName
            echo "************************"
            ;;
        *) echo  ;;
    esac
    echoMessageCreator "" $stepNo false
fi
########################

# create a new snapshot
echoMessageCreator "creating a new snapshot" $stepNo true
read -rp "${green}Name for a snapshot: " name
echo "${reset}"
developCommitSHA=$(git log develop --oneline --pretty=format:'%h' -1)
sfdx force:org:snapshot:create -n $name -d "Snapshot from $developCommitSHA" -o $scratchorgalias -v $prodname
echoMessageCreator "" $stepNo false
#######################

# make new pr into develop
echoMessageCreator "make a new pr into develop" $stepNo true
CURRENT_DATE="$(date +%F)"
branch=feature/new-snapshot-"${CURRENT_DATE//-}"
git checkout -b $branch
snapshotTemplate='{\n\t"orgName": "ANZx",\n\t"snapshot": "'$name'"\n}'

echo -ne $snapshotTemplate > config/snapshot-scratch-def-template.json
echo "${green}"

read -rp "Do you want to push it (y/n)? " pushPR
if [[ $pushPR == y || $pushPR == Y ]]; then
    echo "${reset}"
    git add .
    git commit -m "[ANZX-0000] New snapshot"
    git push origin $branch
    open https://github.com/anzx/salesforce/compare/develop...$branch || start https://github.com/anzx/salesforce/compare/develop...$branch
else
    echo -ne "${green}\nSnapshot has been made, PR has not been pushed."
fi
echoMessageCreator "" $stepNo false
#########################
