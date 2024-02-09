#!/bin/bash -e

function copyMandatoryFilesToPackage() {
    echo "copy to $1"
    cp sfdx-project.json .forceignore $1
}

function unzipDeployPackageandCopyMetaFiles() {
    echo "Deployment changes"

    unzip package.zip -d ${DEPLOY_DIR}
    # Remove tmp package
    rm -f ./package.zip

    # Copy the additional -meta.xml files for all files that require them
    for dir in ${META_DIR[*]}; do
        if [[ -d ${DEPLOY_DIR}/force-app/main/default/$dir ]]; then
            echo ${DEPLOY_DIR}/force-app/main/default/$dir
            if [[ $dir == "classes" ]]; then
                for subdirectory in $(find "${DEPLOY_DIR}/force-app/main/default/$dir" -type d -maxdepth 1 -mindepth 1); do
                    subDir=classes/$(basename "${subdirectory}")
                    for filename in ${DEPLOY_DIR}/force-app/main/default/${subDir}/*; do
                        filename=$(basename "$filename")
                        [[ $filename == *.xml ]] && continue
                        cp ${SOURCE_DIR}/main/default/${subDir}/$filename-meta.xml ${DEPLOY_DIR}/force-app/main/default/${subDir} || true
                    done
                done
            fi

            for filename in ${DEPLOY_DIR}/force-app/main/default/$dir/*; do
                filename=$(basename "$filename")
                if [[ $dir == "staticresources" ]]; then
                    filename="$(echo "$filename" | cut -f 1 -d '.').resource"
                fi
                [[ $filename == *.xml ]] && continue
                echo $filename
                cp ${SOURCE_DIR}/main/default/$dir/$filename-meta.xml ${DEPLOY_DIR}/force-app/main/default/$dir || true
            done

        fi
    done

    # Copy full Aura, LWC, waveTemplate directories where at least one change has been made
    for dir in ${BUNDLE_DIR[*]}; do
        if [[ -d ${DEPLOY_DIR}/force-app/main/default/$dir ]]; then
            for d in ${DEPLOY_DIR}/force-app/main/default/$dir/*; do
                if [ -d "$d" ]; then
                    directory=$(basename $d)
                    cp -R ${SOURCE_DIR}/main/default/$dir/$directory/* ${DEPLOY_DIR}/force-app/main/default/$dir/$directory/
                fi
            done
        fi
    done
}

# Unzip destructive changes and remove the archive
function unzipDestructivePackage() {
    echo "Destructive changes"
    unzip destructivePackage.zip -d ${DESTRUCTIVE_DIR}
    # Remove tmp package
    rm -f ./destructivePackage.zip
}

function setBranchDiffCommand() {
    ISDESTRUCTIVE=$1
    ISCHECKCOUNT=$2
    SOURCE_BRANCH=$3
    TAG_PREFIX=$4
    echo "SOURCE_BRANCH: $SOURCE_BRANCH"
    echo "BASE_BRANCH: $BASE_BRANCH"
    echo "TAG_PREFIX: $TAG_PREFIX"
    if [[ $ISDESTRUCTIVE = false ]]; then
        DIFFENDCOMMAND="xargs -0 git archive -o package.zip HEAD"
        if [[ "$SOURCE_BRANCH" = "master" || "$SOURCE_BRANCH" = "develop" || "$SOURCE_BRANCH" = "epic/"* ]]; then
            echo "Delta deployment requested, commit from head to last tag"
            DIFFSTARTCOMMAND="git diff -z --name-only --diff-filter=d $(git describe --abbrev=0 --tags --match ${TAG_PREFIX}*)..HEAD  ${SOURCE_DIR}/"
        else
            echo "Delta deployment requested, feature branch to ${BASE_BRANCH} branch"
            DIFFSTARTCOMMAND="git diff -z --name-only --diff-filter=d remotes/origin/${BASE_BRANCH}..remotes/origin/${SOURCE_BRANCH}  ${SOURCE_DIR}/"
        fi
    elif [[ $ISCHECKCOUNT = true ]]; then
        if [[ "$SOURCE_BRANCH" = "master" || "$SOURCE_BRANCH" = "develop" || "$SOURCE_BRANCH" = "epic/"* ]]; then
            echo "Deletion delta deployment requested, commit from head to last master tag"
            DIFFSTARTCOMMAND="git diff --diff-filter=D --no-renames --name-only $(git describe --abbrev=0 --tags --match ${TAG_PREFIX}*)..HEAD  ${SOURCE_DIR}/"
            DIFFENDCOMMAND="xargs -0 git archive -o destructivePackage.zip $(git describe --abbrev=0 --tags --match ${TAG_PREFIX}*)"
        else
            echo "Deletion delta deployment requested, feature branch to ${BASE_BRANCH} branch"
            DIFFSTARTCOMMAND="git diff --diff-filter=D --no-renames --name-only remotes/origin/${BASE_BRANCH}..origin/${SOURCE_BRANCH}  ${SOURCE_DIR}/"
            DIFFENDCOMMAND="xargs -0 git archive -o destructivePackage.zip remotes/origin/${BASE_BRANCH}"
        fi
    else
        if [[ "$SOURCE_BRANCH" = "master" || "$SOURCE_BRANCH" = "develop" || "$SOURCE_BRANCH" = "epic/"* ]]; then
            echo "Deletion delta deployment requested, commit from head to last master tag"
            DIFFSTARTCOMMAND="git diff -z --diff-filter=D --no-renames --name-only $(git describe --abbrev=0 --tags --match ${TAG_PREFIX}*)..HEAD  ${SOURCE_DIR}/"
            DIFFENDCOMMAND="xargs -0 git archive -o destructivePackage.zip $(git describe --abbrev=0 --tags --match ${TAG_PREFIX}*)"
        else
            echo "Deletion delta deployment requested, feature branch to ${BASE_BRANCH} branch"
            DIFFSTARTCOMMAND="git diff -z --diff-filter=D --no-renames --name-only remotes/origin/${BASE_BRANCH}..origin/${SOURCE_BRANCH}  ${SOURCE_DIR}/"
            DIFFENDCOMMAND="xargs -0 git archive -o destructivePackage.zip remotes/origin/${BASE_BRANCH}"
        fi
    fi
}

function makeBuildDirectory() {
    if ! [ -d "build" ]; then
        mkdir build
    fi
}

function copyBuildFiles() {

    if ! [ -e ./build/package.xml ]; then
        echo "Copy empty package.xml"
        cp config/package.xml ./build/
    fi

    ls -ltr ./build/
}

function deployArtifact() {
    echo "Target org is $2"
    if [[ $1 == 'validate' ]]; then
        #validate metadata
        echo "**********Validating metadata"
        npx sf project deploy start --metadata-dir -u $2 -c -d $DEPLOY_ROOT -l RunLocalTests -w -1 --loglevel debug
    else
        #deploy metadata
        echo "**********Deploying metadata"
        npx sf project deploy start --metadata-dir -u $2 -d $DEPLOY_ROOT -l RunLocalTests -w -1 --loglevel debug
    fi
}
