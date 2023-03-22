#!/bin/bash

function checkFieldBusinessStatus() {
    fieldMetadata=$( cat $1 )
    f=$(basename "$1") && f=${f/.field-meta.xml}
    if [[ $fieldMetadata != *"<businessStatus>"* ]];then
        echo "$2.$f : Missed businessStatus"
    elif [[ $fieldMetadata == *"<businessStatus>Hidden</businessStatus>"* ]];then
        echo "$2.$f : Hidden field"
    fi        
}

function checkFieldMetadataInformation() {
    fieldMetadata=$( cat $1 )
    f=$(basename "$1") && f=${f/.field-meta.xml}

    if [[ $fieldMetadata != *Source* ]];then
        echo "$2.$f : Missed complianceGroup | Source"
    fi
    if [[ $fieldMetadata != *Integrity* ]];then
        echo "$2.$f : Missed complianceGroup | Integrity"
    fi
    if [[ $fieldMetadata != *Privacy* ]];then
        echo "$2.$f : Missed complianceGroup | Privacy"
    fi
    if [[ $fieldMetadata != *"<description>"* && $3 != *"$2.$f,"* && $3 != *",$2.$f" ]];then
        echo "$2.$f : Missed description"
    fi
    if [[ $fieldMetadata != *"<securityClassification>"* ]];then
        echo "$2.$f : Missed securityClassification"
    fi
}

function checkPantherIdInformation() {
    if [[ $3 != *"$2.$1,"* && $3 != *",$2.$1" ]];then
        echo "$2.$1 : Missed pantherId"
    fi
}

echo ""
echo "*****************************************************"
echo ""
echo "----------------- Sysl error report -----------------"

if [[ -d ./tmp/deploy/force-app/main/default/objects ]];then 
    for o in ./tmp/deploy/force-app/main/default/objects/*; do
        if [[ -d $o/fields ]];then
            objectName=$(basename "$o")
            pantherIdsField=$(node ./ci/sysl-check.js "$objectName" "pantherId")
            manualDescField=$(node ./ci/sysl-check.js "$objectName" "manualFieldDesc")
            for f in $o/fields/*;do
                checkBusinessStatus=$( checkFieldBusinessStatus $f $objectName )
                if [[ $checkBusinessStatus != *"Hidden"* ]];then
                    checkFieldMetadataInformation $f $objectName $manualDescField
                    checkPantherIdInformation $f $objectName $pantherIdsField
                fi
            done
        fi
    done
fi

echo ""
echo "*****************************************************"
echo ""