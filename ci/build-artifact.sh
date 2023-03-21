#!/bin/bash
# harness file this was copied from : https://github.com/anzx/platform-harness-delegates/commit/f4ff83a6436ce12e28569445e528a83cba8707ad

echo ""
echo "************************************************"
echo ""
echo "----- build artifact ----"
echo ""

SOURCE_DIR="./force-app"
DEPLOY_DIR="./tmp/deploy"
DESTRUCTIVE_DIR="./tmp/destructive"
# ignore shellcheck requesting double quotes for expansion, need to use the literal string 'unfiled$public'
# shellcheck disable=SC2016
META_DIR=(classes components objectTranslations pages triggers 'email/unfiled$public' staticresources wave)
BUNDLE_DIR=(aura lwc waveTemplates)
# ignore shellcheck on harness variable reference
# shellcheck disable=SC2154
BRANCH_NAME='snapshot-latest'

function convertSourceFormat() {
    DIR_PATH=$1
    CONVERSION_DIR=$2
    ISDESTRUCTIVE=$3

    # This error message means the artifact is empty, either ci changes only, or everything is forceignored
    ERROR_MSG="ERROR running force:source:convert:  No matching source was found within the package root directory:"
    if result=$(sfdx force:source:convert -r "${DIR_PATH}/force-app" -d "$2" --loglevel debug 2>&1); then
        echo "Conversion successful into $CONVERSION_DIR"
    else
        echo "$result"
        if [[ $result == $ERROR_MSG* ]]; then
            echo "No files found in artifact, all files forceignored or no changes in deployable meta"
            if [[ $ISDESTRUCTIVE = false ]]; then
                return 0
            fi
        else
            if [[ $ISDESTRUCTIVE = false ]]; then
                exit 1
            fi
        fi        
    fi
}


# builds a package.xml format directory
# DEPLOY_DIR directory where we are building the deployment artifact
# META_DIR list of metadata types that need a -meta.xml file
# SOURCE_DIR directory where the checked out source metadata is
# BUNDLE_DIR list of metadata types that need the entire bundle to be included to deploy
function unzipDeployPackageandCopyMetaFiles() {
    echo "Deployment changes"

    if [ -f package.zip ]; then
        unzip package.zip -d ${DEPLOY_DIR}
    fi
    # Remove tmp package
    rm -f ./package.zip

    # Copy the additional -meta.xml files for all files that require them
    # ignoring quotes warning, expansion here is desirable for the for loop
    # shellcheck disable=SC2048
    for p in "${DEPLOY_DIR}"/force-app/main/*; do
        package=$(basename "$p")
        for dir in ${META_DIR[*]}; do
            if [[ -d "${DEPLOY_DIR}"/force-app/main/"$package"/$dir ]]; then
                echo "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir"
                if [[ $dir == "classes" ]]; then
                    # ignoring for loop find warning, this iterates through our class subdirs which are lowercase alpha no spaces
                    # shellcheck disable=SC2044
                    for subdirectory in $(find "${DEPLOY_DIR}/force-app/main/""$package""/$dir" -type d -maxdepth 1 -mindepth 1); do
                        subDir=classes/$(basename "${subdirectory}")
                        for filename in "${DEPLOY_DIR}"/force-app/main/"$package"/"${subDir}"/*; do
                            filename=$(basename "$filename")
                            if [[ $filename == *.cls-meta.xml ]]; then
                                classextension=".cls"
                                classfilename=${filename/.cls-meta.xml/$classextension}
                                cp "${SOURCE_DIR}"/main/"$package"/"${subDir}"/"$classfilename" "${DEPLOY_DIR}"/force-app/main/"$package"/"${subDir}" || true
                            fi
                            [[ $filename == *.xml ]] && continue
                            cp "${SOURCE_DIR}"/main/"$package"/"${subDir}"/"$filename"-meta.xml "${DEPLOY_DIR}"/force-app/main/"$package"/"${subDir}" || true
                        done
                    done
                fi
                if [[ $dir == "objectTranslations" ]]; then
                    # ignoring for loop find warning, this iterates through our field translation subdirs which are lowercase alpha no spaces
                    # shellcheck disable=SC2044
                    for subdirectory in $(find "${DEPLOY_DIR}/force-app/main/""$package""/$dir" -type d -maxdepth 1 -mindepth 1); do
                        subDir=objectTranslations/$(basename "${subdirectory}")
                        subDirBase=$(basename "${subdirectory}")
                        for filename in "${DEPLOY_DIR}"/force-app/main/"$package"/"${subDir}"/*; do
                            filename=$(basename "$filename")
                            if [[ $filename == *.fieldTranslation-meta.xml ]]; then
                                objextension=".objectTranslation-meta.xml"
                                objfilename=$subDirBase$objextension
                                cp "${SOURCE_DIR}"/main/"$package"/"${subDir}"/"$objfilename" "${DEPLOY_DIR}"/force-app/main/"$package"/"${subDir}" || true
                            fi
                        done
                    done
                fi
                for filename in "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir"/*; do
                    filename=$(basename "$filename")
                    # find and remove standalone static resource-meta.xml files, or pass the filename to copy at the end of loop
                    if [[ $dir == "staticresources" ]]; then
                        resourcename="$(echo "$filename" | cut -f 1 -d '.')"
                        resourcelist="$(find "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir" -name "$resourcename*" | wc -l)"
                        if [ "$resourcelist" -eq 1 ] && [[ $filename == *.resource-meta.xml ]];
                        then
                            echo "Removing orphan meta-xml static resource $filename"
                            rm -rf "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir"/"$filename"
                        else
                            filename="$(echo "$filename" | cut -f 1 -d '.').resource"
                        fi
                    fi
                    if [[ $filename == *.trigger-meta.xml ]]; then
                        triggerextension=".trigger"
                        triggerfilename=${filename/.trigger-meta.xml/$triggerextension}
                        cp "${SOURCE_DIR}"/main/"$package"/"$dir"/"$triggerfilename" "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir" || true
                    fi
                    if [[ $filename == *.wdash-meta.xml ]]; then
                        wdashextension=".wdash"
                        wdashfilename=${filename/.wdash-meta.xml/$wdashextension}
                        cp "${SOURCE_DIR}"/main/"$package"/"$dir"/"$wdashfilename" "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir" || true
                    fi
                    if [[ $filename == *.wdf-meta.xml ]]; then
                        wdfextension=".wdf"
                        wdffilename=${filename/.wdf-meta.xml/$wdfextension}
                        cp "${SOURCE_DIR}"/main/"$package"/"$dir"/"$wdffilename" "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir" || true
                    fi
                    if [[ $filename == *.cls-meta.xml ]]; then
                        classextension=".cls"
                        classfilename=${filename/.cls-meta.xml/$classextension}
                        cp "${SOURCE_DIR}"/main/"$package"/"$dir"/"$classfilename" "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir" || true
                    fi
                    if [[ "$filename" == *".xml" ]]; then
                        continue
                    fi
                    if [[ "$filename" == *"."* ]]; then
                        echo "Copying meta file $filename-meta.xml into the package due to orphaned metadata"
                        cp "${SOURCE_DIR}"/main/"$package"/"$dir"/"$filename"-meta.xml "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir" || true
                    fi
                done
            fi
        done
    done

    # Copy full Aura, LWC, waveTemplate directories where at least one change has been made
    # ignoring quotes warning, expansion here is desirable for the for loop
    # shellcheck disable=SC2048
    for p in "${DEPLOY_DIR}"/force-app/main/*; do
        package=$(basename "$p")
        for dir in ${BUNDLE_DIR[*]}; do
            if [[ -d ${DEPLOY_DIR}/force-app/main/"$package"/$dir ]]; then
                for d in "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir"/*; do
                    if [ -d "$d" ]; then
                        directory=$(basename "$d")
                        cp -R "${SOURCE_DIR}"/main/"$package"/"$dir"/"$directory"/* "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir"/"$directory"/
                    fi
                done
            fi
        done
    done
}

# Unzip destructive changes and remove the archive
function unzipDestructivePackage() {
    echo "Destructive changes"
    unzip destructivePackage.zip -d ${DESTRUCTIVE_DIR}
    # if a file from bundle dir is deleted, but the bundle still exists in source, instead of 
    # deleting the bundle, the full bundle should be deployed.
    # Check if file in bundle dir is deleted, check if bundle dir still exist in source
    # Check if the bundle dir does not exist in deploy dir (could have already been copied because because of change)
    # shellcheck disable=SC2048
    for p in "${DESTRUCTIVE_DIR}"/force-app/main/*; do
        package=$(basename "$p")
        for dir in ${BUNDLE_DIR[*]}; do
            if [[ -d "${DESTRUCTIVE_DIR}"/force-app/main/"$package"/"$dir" ]]; then
                for d in "${DESTRUCTIVE_DIR}"/force-app/main/"$package"/"$dir"/*; do
                    if [ -d "$d" ]; then
                        directory=$(basename "$d")
                        if [[ -d "${SOURCE_DIR}"/main/"$package"/"$dir"/"$directory" ]]; then
                            echo "$directory" "has a file deleted, needs to be redeployed"
                            if [ ! -d "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir"/"$directory" ]; then
                                echo "$directory" "has a deleted file and does not exist in deploy directory, copying it to deploy full component"
                                mkdir -p "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir"/"$directory"
                                cp -R "${SOURCE_DIR}"/main/"$package"/"$dir"/"$directory"/* "${DEPLOY_DIR}"/force-app/main/"$package"/"$dir"/"$directory"/
                            fi
                            rm -rf "${DESTRUCTIVE_DIR}"/force-app/main/"$package"/"$dir"/"$directory"
                        fi
                    fi
                done
            fi
        done
    done

    #delete any empty directories left
    for dir in "${DESTRUCTIVE_DIR}"/*; do
        if [ "$(find "$dir" -type d -empty)" ]; then
            rm -rf "$dir"
        fi
    done

    # Remove tmp package
    rm -f ./destructivePackage.zip
}

# copy files that are required by SFDX to run a conversion
function copyMandatoryFilesToPackage() {
    echo "copy to $1"
    cp sfdx-project.json .forceignore "$1"
}

#move to working dir
cd ../salesforce || exit

## Make a deploy and destroy directories to start building artefacts
mkdir -p ${DEPLOY_DIR}
mkdir -p ${DESTRUCTIVE_DIR}

# If any files have changed/been added that require a deployment, generate an artefact
DIFFSTARTCOMMAND="git diff -z --name-only --diff-filter=d $(git describe --abbrev=0 --tags --match "${BRANCH_NAME}"*)..HEAD  ${SOURCE_DIR}/"
DIFFENDCOMMAND="xargs -0 git archive -o package.zip HEAD"
echo "Diff statement: ${DIFFSTARTCOMMAND} | ${DIFFENDCOMMAND}"
CHANGED_FILES=$($DIFFSTARTCOMMAND | wc -w)
echo "Number of changed files: ${CHANGED_FILES}"
if [ "${CHANGED_FILES}" -gt "0" ]; then
    echo "Delta deployment requested, commit from head to last ${BRANCH_NAME} tag"
    eval "$($DIFFSTARTCOMMAND | $DIFFENDCOMMAND)"
    unzipDeployPackageandCopyMetaFiles
fi

echo ""

# If any files have been deleted that need to be deleted, generate an artefact
DIFFSTARTCOMMAND="git diff -z --diff-filter=D --no-renames --name-only $(git describe --abbrev=0 --tags --match "${BRANCH_NAME}"*)..HEAD  ${SOURCE_DIR}/"
DIFFENDCOMMAND="xargs -0 git archive -o destructivePackage.zip $(git describe --abbrev=0 --tags --match "${BRANCH_NAME}"*)"
echo "Deletion diff statement: ${DIFFSTARTCOMMAND} | ${DIFFENDCOMMAND}"
DELETED_FILES=$($DIFFSTARTCOMMAND | wc -w)
echo "Number of deleted files: ${DELETED_FILES}"
if [ "${DELETED_FILES}" -gt "0" ]; then
    echo "Deletion delta deployment requested, commit from head to last ${BRANCH_NAME} tag"
    eval "$($DIFFSTARTCOMMAND | $DIFFENDCOMMAND)"
    unzipDestructivePackage
fi

echo ""

#copy project file and ignore file
echo "copying project & forceignore to ${DEPLOY_DIR}"
cp sfdx-project.json .forceignore ${DEPLOY_DIR}
echo "copying project & forceignore to ${DESTRUCTIVE_DIR}"
cp sfdx-project.json .forceignore ${DESTRUCTIVE_DIR}

# Convert the DX project to a metadata api package and commit the changes to the artefact
CURRENT_DIR=$(pwd)

# Only generate artefacts where files are found
if [ "${CHANGED_FILES}" -gt "0" ] || [ -d ${DEPLOY_DIR}/force-app ]; then
    echo "converting into ${CURRENT_DIR}"
    convertSourceFormat "${DEPLOY_DIR}" "${CURRENT_DIR}/artefact" false
fi

echo ""

if [ "${DELETED_FILES}" -gt "0" ] && [ -d ${DESTRUCTIVE_DIR}/force-app ]; then
    convertSourceFormat "$DESTRUCTIVE_DIR" "${DESTRUCTIVE_DIR}/tmp" true
    echo "Creating destroy manifest"
    cd "${DESTRUCTIVE_DIR}/tmp" || exit
    if [ ! -d "${CURRENT_DIR}"/artefact ]; then
        mkdir "${CURRENT_DIR}"/artefact
        echo '<?xml version="1.0" encoding="UTF-8"?><Package xmlns="http://soap.sforce.com/2006/04/metadata"><version>50.0</version></Package>' > "${CURRENT_DIR}"/artefact/package.xml
    fi
    mv package.xml "${CURRENT_DIR}"/artefact/destructiveChanges.xml
fi

# Return to working DIR
cd "${CURRENT_DIR}" || exit

