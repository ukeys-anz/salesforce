#!/bin/bash


# Exit the script if any statement returns a non-true return value.
set -e

# Pretty print function.. Usage: pp "${red|green|bold}MSG" 
if [[ -t 1 ]]; then
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  bold=$(tput bold)
  reset=$(tput sgr0)
else
  red=""
  green=""
  bold=""
  reset=""
fi
pp() {
  msg="$1"
  echo "${bold}${msg}${reset}"
}




pp "$(date): Starting build.sh"

function usage {
  cat <<EOF

${bold}SYNOPSIS${reset}
    build.sh [ commands ]

${bold}COMMANDS${reset}
    help
        Print this help

    ci_pre_setup
        1. Decrypt the sfdx key using gcloud kms
        2. Authenticate using JWT key

    setup
        1. Create fresh scratch organisation
        2. Install packages
        3. Assign permissions
        4. Push code
        5. Run post-install

    run_tests
        1. Run APEX test
        2. Return success/fail based on test result

    ci_test_status_exit
        Exit with non-zero exit status if test result does not equal "Passed"

${bold}EXAMPLES${reset}
    build.sh help
    build.sh setup
    build.sh run_tests
    build.sh ci_pre_setup setup run_tests ci_test_status_exit
EOF
}

function ci_pre_setup {
  missing_required=0
  if [ -z "${CONSUMER_KEY+x}" ]; then
    pp "${red}CONSUMER_KEY environment variable must be set for ci_pre_setup action"
    missing_required=1
  fi 
  if [ -z "${HUB_USERNAME+x}" ]; then
    pp "${red}HUB_USERNAME environment variable must be set for ci_pre_setup action"
    missing_required=1
  fi 
  if [ -z "${JWT_KEY_FILE+x}" ]; then
    pp "${red}JWT_KEY_FILE environment variable must be set for ci_pre_setup action"
    missing_required=1
  fi 
  if [ -z "${INSTANCE_URL+x}" ]; then
    pp "${red}INSTANCE_URL environment variable must be set for ci_pre_setup action"
    missing_required=1
  fi 
  if [ "$missing_required" -eq 0 ]; then
    sfdx force:auth:jwt:grant --clientid="${CONSUMER_KEY}" --username="${HUB_USERNAME}" --jwtkeyfile="${JWT_KEY_FILE}" --instanceurl="${INSTANCE_URL}"
    sfdx force:config:set "defaultdevhubusername=$HUB_USERNAME"
  fi
}

function setup {
  pp "$(date): Create scratch org..."
  JOB_START_TIME=$(date +%s)
  exit_code=$(sfdx force:org:create -f config/project-scratch-def.json --setdefaultusername --durationdays 1 --wait 3 2> "$TMPDIR/err"; echo $?)
  # Due to ANZ workstations being unable to resolve DNS, `sfdx force:org:create`
  # fails with:
  #   ERROR running force:org:create: Successfully created org with ID: 00D5O0000008cz6UAA 
  #   and name: test-psoj8yyr364t@example.com. However, the My Domain URL 
  #   https://customization-momentum-1111.cs151.my.salesforce.com/ has not finished 
  #   propagating. Some commands may not work as expected until the My Domain DNS
  #   propagation is complete.even if scratc org is created successfully. In this case, 
  # We will ignore errors with this type of error only
  if [[ $exit_code == 1 ]]; then
    err=$(<"$TMPDIR/err")
    pp "${red}${err}"
    if [[ $err == *"Successfully created org"* ]]; then
      pp "${green}Expected error on ANZ workstations. Script will proceed assuming successful creation."
    else
      exit 1
    fi
    # Due to this error, the --setdefaultusername does not get actioned by the force:org:create
    # command and we must extract the user and set the default user separately
    user="test-$(echo "$err" | grep -Eo '[^-]+@')example.com"
    sfdx force:config:set "defaultusername=$user"
  fi
  JOB_END_TIME=$(date +%s)
  pp "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

  pp "$(date): Install FSC v220.8.0..."
  # http://industries.force.com/financialservicescloud
  JOB_START_TIME=$(date +%s)
  sfdx force:package:install --package 04t1E000000y9lo -w 20 --securitytype AllUsers 
  JOB_END_TIME=$(date +%s)
  pp "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

  pp "$(date): Install FSC Extensions 218.1..."
  # http://industries.force.com/financialservicescloudextension
  JOB_START_TIME=$(date +%s)
  sfdx force:package:install --package 04t1E000001Iql5 -w 20 --securitytype AllUsers 
  JOB_END_TIME=$(date +%s)
  pp "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

  pp "$(date): Install Intelligent Need-Based Referrals and Scoring 218.1..."
  # http://industries.force.com/financialservicescloudextensionrb
  JOB_START_TIME=$(date +%s)
  sfdx force:package:install --package 04t80000000lTp4 -w 20 --securitytype AllUsers 
  JOB_END_TIME=$(date +%s)
  pp "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

  pp "$(date): Assign Pset..."
  sfdx force:user:permset:assign -n FinancialServicesCloudStandard
  JOB_END_TIME=$(date +%s)
  pp "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

  pp "$(date): Push metadata..."
  sfdx force:source:push
  JOB_END_TIME=$(date +%s)
  pp "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."

  pp "$(date): Execute post-install scripts..."
  sfdx force:apex:execute -f config/post-install.apex
  JOB_END_TIME=$(date +%s)
  pp "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."
}


function run_tests {
  pp "$(date): Run apex tests and retrieve code coverage results..."
  sfdx force:apex:test:run -c -r json > "$TMPDIR/test_result.json";
  # TODO: Save test_result somewhere
  cat "$TMPDIR/test_result.json"
  JOB_END_TIME=$(date +%s)
  pp "$(date): Finished in $((JOB_END_TIME - JOB_START_TIME)) s."
}

function ci_test_status_exit {
  outcome=$(jq '.result.summary.outcome' < "$TMPDIR/test_result.json")
  if [[ $outcome == '"Passed"' ]]; then
    exit 0
  else
    exit 1
  fi
}

# Save results and logs in tempdir (save elsewhere where needed)
TMPDIR=$(mktemp -d)
trap 'rm -rf $TMPDIR' EXIT

export SFDX_DOMAIN_RETRY=0

ALL_START_TIME=$(date +%s)


if [ $# -lt 1 ]; then
    pp "${red}No actions specified. Stopping"
    usage
    exit 1
fi

while [[ $# -gt 0 ]]; do
  KEY="$1"
  case $KEY in
    help | -h | --help )
      usage
      exit
      ;;
    ci_pre_setup )
      ci_pre_setup
      shift
      ;;    
    setup )
      setup
      shift
      ;;
    run_tests )
      run_tests
      shift
      ;;    
    ci_test_status_exit )
      ci_test_status_exit
      shift
      ;;
    * )
      pp "${red}Unknown action '$1' specified. Stopping"
      usage
      exit
      ;;
  esac
done


ALL_END_TIME=$(date +%s)
pp "$(date): All done in $((ALL_END_TIME - ALL_START_TIME)) s."
# echo "Open scratch org..."
# sfdx force:org:open
