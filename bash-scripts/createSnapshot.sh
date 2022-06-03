#!/bin/bash

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

cd ..

# creating the scratchOrg
echoMessageCreator "creating the scratchOrg" $stepNo true
sfdx force:org:create -f config/project-scratch-def.json -a $scratchorgalias --setdefaultusername --durationdays 1
echoMessageCreator "" $stepNo false
########################

# check if the scratch org has been created
echoMessageCreator "check if the scratch org has been created" $stepNo true
sfdx force:org:list
echoMessageCreator "" $stepNo false
########################

# install managed packages
echoMessageCreator "install managed packages" $stepNo true
sfdx force:mdapi:deploy -d mdapi-source/packages/
echoMessageCreator "" $stepNo false
########################

# this will check if all the packages has been deployed successfully or still inProgress, every 3 mins.
# if it is deployed successfully, then it will continue the job.
waitToInstallPackages=false;

echoMessageCreator "waiting step for a command" $stepNo true
while [[ $waitToInstallPackages == false ]]; do
    echo ""
    sfdx force:mdapi:deploy:report | tee stderr
    if [[ ($(cat stderr) == *'InProgress'*) ]]; then
        echo "${green}"
        echo "wait for another 3 mins"
        sleep 180
        echo "${reset}"
    else
        waitToInstallPackages=true
    fi
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
sfdx force:package:install -p 04t2J000000IzriQAC --securitytype AdminsOnly
echo "wait for 5 mins to finish deploying"
sleep 300
echoMessageCreator "" $stepNo false
########################

# checkout to develop and push all the metadata into the scratchOrg
echoMessageCreator "push all the metadata into the scratchOrg" $stepNo true
source ./bash-scripts/snapshotScratch.sh
echoMessageCreator "" $stepNo false
########################


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
echoMessageCreator "" $stepNo false
#######################

read -rp "Do you want to make a PR into develop (y/n)? " makePrFlag
if [[ $makePrFlag == y || $makePrFlag == Y ]]; then

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
fi
