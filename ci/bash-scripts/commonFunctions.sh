#! /bin/bash

green=`tput setaf 2`
red=`tput setaf 1`
reset=`tput sgr0`

trap ctrl_c INT

function ctrl_c() {
    git checkout .
    rm -rf ci.forceignore
    echo "${red}"
    echo "Creating snapshot has been stopped."
    echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    exit 1
}

echo "${red}"
echo "WARNING: Disable ANZ Proxy to run this script"
echo "You can leave alpaca running and proxy variables set to localhost:3128"
echo "${reset}"

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
        echo "${reset}"
        stepNo=$(($stepNo+1))
    fi
}

# first argument : filepath -> relative file path
# second argument : name -> to make a copy of that
function changeMetadata(){
    echo $1
    context=$(<"$1")

    if [[ $2 == 'IDRRestriction' || $2 == 'IDR3rdParty' || $2 == 'SIWorkflow' || $2 == 'IDRNCState' || $2 == 'OnboardingVerificationFailedReason' ]];then
        replace=$( sed 's+<trackFeedHistory>false</trackFeedHistory>+<!--<trackFeedHistory>false</trackFeedHistory>-->+g' "$1" )
        echo $replace > "$1"
        replace=$( sed "s+<trackHistory>true</trackHistory>+<!--<trackHistory>true</trackHistory>-->+g" "$1" )
        echo $replace > "$1"
        replace=$( sed "s+<trackTrending>false</trackTrending>+<!--<trackTrending>false</trackTrending>-->+g" "$1" )
        echo $replace > "$1"
        replace=$( sed "s+<controllingFieldValue>Open</controllingFieldValue>+<!--<controllingFieldValue>Open</controllingFieldValue>-->+g" "$1")
        echo $replace > "$1"
    elif [[ $2 == 'IsotopeSubscription' ]];then
        replace=$( sed "s+<excludedStandardButtons>IsotopeSubscription</excludedStandardButtons>+<!-- <excludedStandardButtons>IsotopeSubscription</excludedStandardButtons> -->+g" "$1" )
        echo $replace > "$1"
    elif [[ $2 == 'AddressSettings' ]]; then
        replace=$( sed "s+<label>Czech Republic</label>+<label>Czechia</label>+g" "$1" )
        echo $replace > "$1"
        replace=$( sed "s+<label>Macedonia, the former Yugoslav Republic of</label>+<label>North Macedonia</label>+g" "$1" )
        echo $replace > "$1"
        replace=$( sed "s+<label>Swaziland</label>+<label>Eswatini</label>+g" "$1" )
        echo $replace > "$1"
        replace=$( sed "s+<label>Turkey</label>+<label>Türkiye</label>+g" "$1" )
        echo $replace > "$1"
    else
        f=$(echo $context | sed 's/\n//g')
        echo $f > "$1"
        context=$(<"$1")

        if [[ $2 == 'manageUsers' ]];then
            replace=$( sed 's+<enabled>false</enabled> <name>ManageSharing</name>+<enabled>true</enabled> <name>ManageSharing</name>+g' "$1")
            echo $replace > "$1"
        elif [[ $2 == 'keyManager' ]];then
            replace=$( sed 's+<userPermissions> <enabled>true</enabled> <name>CustomizeApplication</name> </userPermissions>++g' "$1")
            echo $replace > "$1"
        elif [[ $2 == 'NLPReporting' ]]; then
            replace=$( sed 's+<shares> <accessLevel>Manage</accessLevel> <sharedTo>Engineer</sharedTo> <sharedToType>RoleAndSubordinates</sharedToType> </shares>+<shares> <accessLevel>View</accessLevel> <sharedTo>Engineer</sharedTo> <sharedToType>RoleAndSubordinates</sharedToType> </shares>+g' "$1")
            echo $replace > "$1"
        elif [[ $2 == 'myTrailheadContentAccess' ]];then
            replace=$( sed 's+<classAccesses> <apexClass>TH_Assignments</apexClass> <enabled>true</enabled> </classAccesses>++g' "$1")
            echo $replace > "$1"
        elif [[ $2 == 'bugEnquiry' ]];then
            replace=$( sed 's+<values> <fullName>Closed - Resolved</fullName> <default>false</default> </values>++g' "$1")
            echo $replace > "$1"
        else
            replace=$( sed 's+<objectPermissions> <allowCreate>true</allowCreate> <allowDelete>true</allowDelete> <allowEdit>true</allowEdit> <allowRead>true</allowRead> <modifyAllRecords>true</modifyAllRecords> <object>OrgSnapshot</object> <viewAllRecords>true</viewAllRecords> </objectPermissions>+<!-- -->+g' "$1" )
            echo $replace > "$1"
            replace=$( sed 's+<objectPermissions> <allowCreate>false</allowCreate> <allowDelete>false</allowDelete> <allowEdit>false</allowEdit> <allowRead>true</allowRead> <modifyAllRecords>false</modifyAllRecords> <object>OrgSnapshot</object> <viewAllRecords>true</viewAllRecords> </objectPermissions>+<!-- -->+g' "$1" )
            echo $replace > "$1"
            replace=$( sed 's+<objectPermissions> <allowCreate>false</allowCreate> <allowDelete>false</allowDelete> <allowEdit>false</allowEdit> <allowRead>false</allowRead> <modifyAllRecords>false</modifyAllRecords> <object>OrgSnapshot</object> <viewAllRecords>false</viewAllRecords> </objectPermissions>+<!-- -->+g' "$1" )
            echo $replace > "$1"
        fi
    fi
}

# first argument : scratchOrg alias
# second argument : which step ( pre/post deploy )
function waitForManualSteps(){
    read -rp "${green}Do you want to open the scratch org to do manual $2 steps (y/n)? " manualDeploySteps
    echo "${reset}"
    if [[ $manualDeploySteps == y || $manualDeploySteps == Y ]]; then
        sfdx force:org:open -u $1 
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
    read -rp "When you have done the manual steps, just type (y). If you want to stop the job, type (n): " continueFlag
    if [[ $continueFlag == n || $continueFlag == N ]]; then
        echo ""
        echo "Creating snapshot has been stopped."
        echo ""
        exit 1
    fi
}

function continueTheJob(){
    read -rp "${green}Do you want to continue (y/n)? ${reset}" continueFlag
    if [[ $continueFlag == 'N' || $continueFlag == 'n' ]];then
        exit 1
    fi
    if [[ ($(cat stderr) == *'ERROR'*) || ($(cat stderr) == *'statusCode=502'*) ]]; then
        echo ""
        echo "${red} check the deployment status from the scratchOrg"
        echo "if the deployment is finished successfully, continue the job"
        read -rp "Do you want to open the scratch org (y/n)? " manualDeploySteps
        echo "${reset}"
        if [[ $manualDeploySteps == y || $manualDeploySteps == Y ]]; then
            sfdx force:org:open 
        fi
        echo ""
    fi
}

function trackingFalseOnArtefact(){
    if [ -d artefact/objects ];then
        for filename in artefact/objects/*; do
            echo $filename
            changeMetadataArtefact $filename "<trackHistory>true</trackHistory>" "<trackHistory>false</trackHistory>"
            changeMetadataArtefact $filename "<trackFeedHistory>true</trackFeedHistory>" "<trackFeedHistory>false</trackFeedHistory>"
            changeMetadataArtefact $filename "<trackTrending>true</trackTrending>" "<trackTrending>false</trackTrending>"
        done
    else
        echo "No change on objects"
    fi
}

function changeMetadataArtefact(){
    context=$(cat $1)
    if [[ $context == *"$2"* ]];then
        sed -i '' "s+$2+$3+g" $1
    fi
}