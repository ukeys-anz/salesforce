#!/usr/bin/env bash
set -euo pipefail

# Normalize working directory to repository root
readonly CONTAINING_DIR=$(unset CDPATH && cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$CONTAINING_DIR"/..

# Static configuration
readonly SOURCE_DIR='force-app'
readonly META_DIRS=(classes components pages triggers 'email/unfiled$public' staticresources)
readonly COMPONENT_DIRS=(aura lwc)

# Import helper functions
source "$CONTAINING_DIR"/functions.sh

# Parse arguments and derive configuration from git
unset BRANCH
unset USERNAME
unset GIT_TAG_PREFIX
while (( $#>0 )); do
    KEY=$1
    case "$KEY" in
        --branch)
            shift
            BRANCH=$1
            shift
        ;;
        --username)
            shift
            USERNAME=$1
            shift
        ;;
        --git-tag-prefix)
            shift
            GIT_TAG_PREFIX=$1
            shift
        ;;
        *)
            1>&2 echo "unexpected argument $KEY"
            exit 1
        ;;
    esac
done
if [[ -z ${USERNAME+x} ]]; then
    1>&2 echo "flag --username is required"
    exit 1
fi
if [[ -z ${BRANCH+x} ]]; then
    # BRANCH is unset, but we can derive it using the command: git rev-parse --abbrev-ref HEAD
    # This command always returns master in Cloud Build, so exit with code zero to avoid attempting deploying to staging if the --branch
    # flag is missing (or to production if --git-tag-prefix is set).
    # The BUILDER_OUTPUT environment variable is set in Cloud Build.
    if [[ -z ${BUILDER_OUTPUT+x} ]]; then
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
    else
        1>&2 echo "flag --branch is required in Cloud Build"
        exit 1
    fi
fi
if [[ -n ${GIT_TAG_PREFIX+x} ]]; then
  # TODO implement logic for production deployments...
  if [[ ${BRANCH} != master ]]; then
    1>&2 echo "flag --branch should be master because --git-tag-prefix is set, implying production deployments"
  fi
  1>&2 echo "logic for production deployments is not fully implemented yet"
  exit 1
fi

# When a build is run against the latest develop commit we should compare HEAD with the current state of
# systest environment, and create a deployment with the differences.
# Naively the diff should be taken over the last commit only (HEAD^1..HEAD).
# This approach is valid because develop should only be updated from a feature branch, BUT:
# 1. When merging master into develop no validate is performed (so master should be merged into develop via a feature
# branch).
# 2. If a deployment on develop fails then it's commit will not be considered.
# Similarly, if a deployment on the master branch fails then it's commit will not be considered.
case "$BRANCH" in
  feature/*)
    DIFF_COMMITISH='develop'
  ;;
  develop)
    DIFF_COMMITISH='HEAD^1'
  ;;
  release/*)
    DIFF_COMMITISH='master'
  ;;
  master)
    DIFF_COMMITISH='HEAD^1'
  ;;
  *)
    1>&2 echo "value of --branch must be \"develop\" or \"master\" or start with \"feature/\" or \"release/\""
    exit 1
  ;;
esac

# When rerunning on local, delete files from any previous run
rm -rf tmp
mkdir tmp

# Add added or updated files to the deployment package for metadata API
echo "copying added or updated ${SOURCE_DIR} files to staging area, to be passed to \"sfdx force:source:convert -d tmp/package-deploy-md ...\""
setBranchDiffCommand false false
"${DIFFSTARTCOMMAND[@]}" > tmp/stdout.txt
if [[ -s tmp/stdout.txt ]]; then
    "${DIFFENDCOMMAND[@]}" < tmp/stdout.txt
    mkdir tmp/package-add-or-update
    unzip tmp/tmp.zip -d tmp/package-add-or-update
    rm -f tmp/tmp.zip
    copyMetaFilesToPackage
    copyMandatoryFilesToPackage tmp/package-add-or-update
    echo "copied added or updated ${SOURCE_DIR} files to staging area, running \"sfdx force:source:convert -d tmp/package-deploy-md ...\""
    mkdir tmp/package-deploy-md
    pushd "$CONTAINING_DIR"/../tmp/package-add-or-update
    sfdx force:source:convert --rootdir "${SOURCE_DIR}" -d ../package-deploy-md --loglevel debug
    popd
    echo "ran \"sfdx force:source:convert -d tmp/package-deploy-md ...\" successfully"
    echo "updated the metadata API package for added and updated ${SOURCE_DIR} files"
else
    echo "no added or updated ${SOURCE_DIR} files"
fi

# Add deleted files to the deployment package for metadata API
echo "copying deletes ${SOURCE_DIR} files to staging area, to create destructiveChanges.xml"
setBranchDiffCommand true true
"${DIFFSTARTCOMMAND[@]}" > tmp/stdout.txt
if [[ -s tmp/stdout.txt ]]; then
    "${DIFFENDCOMMAND[@]}" < tmp/stdout.txt
    mkdir tmp/package-deleted
    unzip tmp/tmp.zip -d tmp/package-deleted
    copyMandatoryFilesToPackage tmp/package-deleted
    echo "copied deleted ${SOURCE_DIR} files to staging area, creating destructiveChanges.xml..."
    mkdir tmp/package-deleted-md
    pushd "$CONTAINING_DIR"/../tmp/package-deleted
    sfdx force:source:convert --rootdir "${SOURCE_DIR}" -d ../package-deleted-md --loglevel debug
    popd
    mkdir -p tmp/package-deploy-md
    mv tmp/package-deleted-md/package.xml tmp/package-deploy-md/destructiveChanges.xml
    echo "created destructiveChanges.xml successfully from deleted ${SOURCE_DIR} files"
    echo "added destructiveChanges.xml to the metadata API package"
else
    echo "no deleted ${SOURCE_DIR} files"
fi

# Create the package for the metadata API and exit if there are no changes
if [[ ! -e tmp/package-deploy-md ]]; then
    echo "metadata API package was not created because there are no changes, exiting with code 0"
    exit 0
fi

if [[ ! -e tmp/package-deploy-md/package.xml ]]; then
  echo "adding empty package.xml to metadata API package because there are only deleted ${SOURCE_DIR} files"
  echo '<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
  <version>46.0</version>
</Package>' > tmp/package-deploy-md/package.xml
fi

case "$BUILD_COMMAND" in
    validate)
        echo "validating metadata API package"
        sfdx force:mdapi:deploy -c -d tmp/package-deploy-md -l RunLocalTests -w -1 --loglevel debug --targetusername "${USERNAME}" 
    ;;
    deploy)
        echo "deploying metadata API package"
        sfdx force:mdapi:deploy -d tmp/package-deploy-md -l RunLocalTests -w -1 --loglevel debug --targetusername "${USERNAME}"
    ;;
    *)
        1>&2 echo "unknown BUILD_COMMAND, please fix this script"
        exit 1
    ;;
esac
