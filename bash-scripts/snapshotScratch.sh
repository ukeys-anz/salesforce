#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

stepNum=$(($stepNo+1))
source ./bash-scripts/commonFunctions.sh
stepNo=$(($stepNum))

JOB_START_TIME=""
JOB_END_TIME=""

# Bypass the Lightning Experience custom domain check entirely, wich takes very long when connected to ANZ network
# TODO Consider a switch to bypass it when connected elsewhere (e.g. from GCB)
export SFDX_DOMAIN_RETRY=0

scratchorgalias=ANZxScratchOrg
ALL_START_TIME=$(date +%s)

# change forceignore to harness.forceignore as we will have all things in our snapshot
echoMessageCreator "change the forceignore to the proper one" $stepNo true
mv .forceignore ci.forceignore
mv harness.forceignore .forceignore
echo -e "\nforce-app/main/default/transactionSecurityPolicies" >> .forceignore
echo -e "\nforce-app/main/default/sharingRules/Case.sharingRules-meta.xml" >> .forceignore

echoMessageCreator "" $stepNo false
########################

# assign permission sets
echoMessageCreator "Assign Permission sets" $stepNo true
sfdx force:user:permset:assign -n "FinancialServicesCloudStandard,EinsteinAnalyticsPlusAdmin" 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) && ($(cat stderr) != *'Duplicate PermissionSetAssignment'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
    git checkout .
    exit 1
fi
echoMessageCreator "" $stepNo false
###########################

# deploy settings and content assests
echoMessageCreator "Deploy settings and content assets" $stepNo true
sfdx force:source:deploy -p force-app/main/default/settings/BusinessHours.settings-meta.xml,force-app/main/default/settings/Quote.settings-meta.xml,force-app/main/default/settings/Forecasting.settings-meta.xml,force-app/main/default/contentassets,force-app/main/default/objects/Case/fields/SLA_Status__c.field-meta.xml,force-app/main/default/settings/Entitlement.settings-meta.xml 2>&1 | tee stderr
if [[ ($(cat stderr) == *'ERROR'*) || ($(cat stderr) == *'statusCode=502'*) ]]; then
    exit 1
fi
echoMessageCreator "" $stepNo false
###########################

# deploy bigObjects
echoMessageCreator "Deploy bigObjects" $stepNo true
sfdx force:source:deploy -p force-app/main/default/objects/Accessed_Record_Log__b
sfdx force:source:deploy -p force-app/main/default/objects/Log_Record_Access__b
sfdx force:source:deploy -p force-app/main/default/objects/Record_Access_Log__b
sfdx force:source:deploy -p force-app/main/default/objects/Application_Trace_Log__b
sfdx force:source:deploy -p force-app/main/default/objects/Traced_Application_Log__b
echo -e "\nforce-app/main/default/objects/Accessed_Record_Log__b" >> .forceignore
echo -e "\nforce-app/main/default/objects/Log_Record_Access__b" >> .forceignore
echo -e "\nforce-app/main/default/objects/Record_Access_Log__b" >> .forceignore
echo -e "\nforce-app/main/default/objects/Application_Trace_Log__b" >> .forceignore
echo -e "\nforce-app/main/default/objects/Traced_Application_Log__b" >> .forceignore
echoMessageCreator "" $stepNo false
###########################

# pre deploy : change on some files
echoMessageCreator "Pre Deploy Checking Step" $stepNo true
changeMetadata force-app/main/default/objects/Case/fields/IDR_Restriction_Level__c.field-meta.xml IDRRestriction 
changeMetadata force-app/main/default/objects/Case/fields/SI_Workflow_Step__c.field-meta.xml SIWorkflow 
changeMetadata force-app/main/default/permissionsets/Mvision_Permissions.permissionset-meta.xml Mvision
changeMetadata force-app/main/default/permissionsets/Read_Only_Admin.permissionset-meta.xml readOnly
changeMetadata force-app/main/default/permissionsets/SFDX_Deploy.permissionset-meta.xml sfdxDeploy
changeMetadata force-app/main/default/permissionsets/SFDX_Snapshots.permissionset-meta.xml sfdxSnap
changeMetadata force-app/main/default/permissionsets/View_All_Data.permissionset-meta.xml viewAll
changeMetadata force-app/main/default/permissionsets/View_All_Files.permissionset-meta.xml viewFiles
changeMetadata force-app/main/default/objects/Account/Account.object-meta.xml IsotopeSubscription
changeMetadata force-app/main/default/objects/Campaign_Document__c/Campaign_Document__c.object-meta.xml IsotopeSubscription
changeMetadata force-app/main/default/objects/Campaign_Flex_Field__c/Campaign_Flex_Field__c.object-meta.xml IsotopeSubscription
changeMetadata force-app/main/default/objects/Industry__c/Industry__c.object-meta.xml IsotopeSubscription
changeMetadata force-app/main/default/objects/Lead/Lead.object-meta.xml IsotopeSubscription
changeMetadata force-app/main/default/objects/Quality_Assessment__c/Quality_Assessment__c.object-meta.xml IsotopeSubscription
changeMetadata "force-app/main/default/profiles/Minimum Access - External Apps.profile-meta.xml" minimum
changeMetadata "force-app/main/default/profiles/ANZx Standard User.profile-meta.xml" anzxStandard
changeMetadata force-app/main/default/permissionsets/Manage_Users.permissionset-meta.xml manageUsers
echoMessageCreator "" $stepNo false
###########################

# manual pre-deploy steps
echoMessageCreator "Manual pre-deploy steps" $stepNo true
waitForManualSteps $scratchorgalias "pre-deploy"
echoMessageCreator "" $stepNo false

# push metadata
echoMessageCreator "Push metadata" $stepNo true
tryDeploying=true
while [[ $tryDeploying == true ]]; do
    echo "${reset}"
    sfdx force:source:push -f 2>&1 | tee stderr

    if [[ ($(cat stderr) == *'ERROR'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
        echo "${green}"
        echo "Maybe you need to do some manual steps."
        echo "Please check the stderr file."
        echo ""
        read -rp "Do you want to continue without pushing the metadata (y/n)? " withoutPushFlag
        echo ""
        if [[ $withoutPushFlag == y || $withoutPushFlag == Y ]]; then
            tryDeploying=false
        else
            read -rp "Do you want to retry push the metadata (y/n)? " retryFlag
            if [[ $retryFlag == n || $retryFlag == N ]]; then
                echo ""
                echo "The job has been skipped."
                echo ""
                git checkout .
                exit 1
            else
                tryDeploying=true
            fi
        fi
    else
        tryDeploying=false
    fi 
done
echoMessageCreator "" $stepNo false
###########################

# post deploy: to make all the files back to what it was and deploy them
echoMessageCreator "Post Deploy" $stepNo true
sfdx force:source:deploy -u $scratchorgalias -p "force-app/main/default/sharingRules/Case.sharingRules-meta.xml"
git checkout .

f1=force-app/main/default/objects/Case/fields/IDR_Restriction_Level__c.field-meta.xml
f2=force-app/main/default/objects/Case/fields/SI_Workflow_Step__c.field-meta.xml
sfdx force:source:deploy -u $scratchorgalias -p $f1,$f2
waitForManualSteps $scratchorgalias "post-deploy"
echoMessageCreator "" $stepNo false
###########################

# import post-deployment plan
echoMessageCreator "Import post-deployment plan" $stepNo true
read -rp "${green}Do you want to import post-deployment plan(y/n)? " importPlan
echo "${reset}"
if [[ $importPlan == Y || $importPlan == y ]];then
    sfdx force:data:tree:import -p data/Post-Plan.json 2>&1 | tee stderr
    sfdx force:data:tree:import -p data/IDR-CustomSetting.json 2>&1 | tee stderr
    node createCmosEntitlment.js 2>&1 | tee stderr
    sfdx force:data:tree:import -f data/Non_Prod_Settings__c.json 2>&1 | tee stderr
    if [[ ($(cat stderr) == *'ERROR'*)  || ($(cat stderr) == *'statusCode=502'*) ]]; then
        exit 1
    fi
else
    echo "${green}Importing post-deployment plan has been skipped."
fi
echoMessageCreator "" $stepNo false
###########################

ALL_END_TIME=$(date +%s)
echo ""
echo "${green}$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s.${reset}"

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