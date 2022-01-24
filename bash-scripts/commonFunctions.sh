#! /bin/bash

green=`tput setaf 2`
red=`tput setaf 1`
reset=`tput sgr0`

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
        echo ""
        stepNo=$(($stepNo+1))
    fi
}