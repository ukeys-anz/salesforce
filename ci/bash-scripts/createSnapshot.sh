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

cd ../..

# creating the scratchOrg
echoMessageCreator "creating the scratchOrg" $stepNo true
sf org create scratch -f config/project-scratch-def.json -a $scratchorgalias -d -y 1
echoMessageCreator "" $stepNo false
########################

# check if the scratch org has been created
echoMessageCreator "check if the scratch org has been created" $stepNo true
sf org list
echo ""
read -rp "${green}check if the scratchOrg with $scratchorgalias alias has been made(y/n)? " scratchMade
if [[ $scratchMade == n || $scratchMade == N ]];then
    echo ""
    echo "${red}exit and re-run it again${reset}"
    echo ""
    sf org delete scratch -o $scratchorgalias | tee stderr
    exit 1
fi
echoMessageCreator "" $stepNo false
########################

# install managed packages
echoMessageCreator "install managed packages" $stepNo true
sf project deploy start -o $scratchorgalias -d mdapi-source/packages/ | tee stderr
continueTheJob
echoMessageCreator "" $stepNo false
########################

# this will check if all the packages has been deployed successfully or still inProgress, every 3 mins.
# if it is deployed successfully, then it will continue the job.
waitToInstallPackages=false;

echoMessageCreator "waiting step for a command" $stepNo true
while [[ $waitToInstallPackages == false ]]; do
    echo ""
    sf project deploy start --metadata-dir | tee stderr

    if [[ ($(cat stderr) == *'InProgress'*) ]]; then
        echo "${green}"
        echo "wait for another 3 mins"
        sleep 180
        echo "${reset}"
    else 
        waitToInstallPackages=true
    fi
done

continueTheJob

echoMessageCreator "" $stepNo false
########################

# install unmanaged packages
echoMessageCreator "install unmanaged packages" $stepNo true
# observe 'apvId' attribute on the below browser URL for the package version ID
# open http://industries.force.com/financialservicescloudextension
# if it is not like below, change it to the new one
apvId=04t1E000001Iql5
sf package install -p $apvId -w 20 -s AllUsers | tee stderr
continueTheJob

sf package install -p 04t2J000000IzriQAC -s AdminsOnly | tee stderr
continueTheJob

echoMessageCreator "" $stepNo false
########################

# checkout to develop and push all the metadata into the scratchOrg
echoMessageCreator "push all the metadata into the scratchOrg" $stepNo true
source ./ci/bash-scripts/snapshotScratch.sh
echoMessageCreator "" $stepNo false
########################


echoMessageCreator "check if you want to delete an existed snapshot" $stepNo true
sf org snapshot list
echo "${green}"
read -rp "Do you want to delete ReleaseSnapshot snapshot (y/n)? " deleteSnapshot
case ${deleteSnapshot:0:1} in
    y | Y)        
        snapshotName=ReleaseSnapshot
        sf org delete snapshot -s $snapshotName
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
sf org create snapshot -n $name -d "Snapshot from $developCommitSHA" -o $scratchorgalias -v $prodname
waitTillSnapshotIsActive=false
while [[ $waitTillSnapshotIsActive == *'false'* ]]; do
    sf org snapshot list
    snapshotList=$( sf org snapshot list --json )
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
echo ""
echoMessageCreator "" $stepNo false
#######################