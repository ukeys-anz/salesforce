#!/bin/bash

# Exit the script if any statement returns a non-true return value.
set -e

export SFDX_DOMAIN_RETRY=0

ALL_START_TIME=$(date +%s)

echo "$(date): Create scratch org..."
JOB_START_TIME=$(date +%s)
sfdx force:org:create -f config/project-scratch-def.json -a FscScratchOrg --setdefaultusername --durationdays 30
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Install FSC v220.6.0..."
# http://industries.force.com/financialservicescloud
JOB_START_TIME=$(date +%s)
sfdx force:package:install --package 04t1E000000y9ew -w 20 --securitytype AllUsers
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Install FSC Extensions 218.1..."
# http://industries.force.com/financialservicescloudextension
JOB_START_TIME=$(date +%s)
sfdx force:package:install --package 04t1E000001Iql5 -w 20 --securitytype AllUsers
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Install Intelligent Need-Based Referrals and Scoring 218.1..."
# http://industries.force.com/financialservicescloudextensionrb
JOB_START_TIME=$(date +%s)
sfdx force:package:install --package 04t80000000lTp4 -w 20 --securitytype AllUsers
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Assign Pset..."
sfdx force:user:permset:assign -n FinancialServicesCloudStandard
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Push metadata..."
sfdx force:source:push
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

echo "$(date): Execute post-install scripts..."
sfdx force:apex:execute -f config/post-install.apex
JOB_END_TIME=$(date +%s)
echo "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

ALL_END_TIME=$(date +%s)
echo "$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s."
echo "Open scratch org..."
sfdx force:org:open
