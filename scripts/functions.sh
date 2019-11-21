function copyMandatoryFilesToPackage(){
  cp sfdx-project.json .forceignore "$1"
}

function getLatestTag() {
  local TAG_PREFIX
  TAG_PREFIX=$1
  if git describe --abbrev=0 --tags --match "${TAG_PREFIX}*" 2>tmp/stderr; then
    return 0
  fi
  # Ignore tag not found errors
  if [[ $(cat tmp/stderr) == *'No names found, cannot describe anything'* ]]; then
    return 0
  fi
  # Otherwise, fail and crash the script (assuming set -e)
  1>&2 cat tmp/stderr
  return 1
}

function setBranchDiffCommand() {
    local ISDESTRUCTIVE
    local ISCHECKCOUNT
    ISDESTRUCTIVE=$1
    ISCHECKCOUNT=$2
    if [[ $ISDESTRUCTIVE = false ]]; then
        DIFFENDCOMMAND=(xargs -0 git archive -o tmp/tmp.zip HEAD)
        DIFFSTARTCOMMAND=(git diff -z --name-only --diff-filter=d "${DIFF_COMMITISH}"..remotes/origin/"${BRANCH}" "${SOURCE_DIR}"/)
    elif [[ $ISCHECKCOUNT = true ]]; then
        DIFFSTARTCOMMAND=(git diff -z --diff-filter=D --no-renames --name-only "${DIFF_COMMITISH}"..remotes/origin/"${BRANCH}" "${SOURCE_DIR}"/)
        DIFFENDCOMMAND=(xargs -0 git archive -o tmp/tmp.zip "${DIFF_COMMITISH}")
    else
        DIFFSTARTCOMMAND=(git diff -z --diff-filter=D --no-renames --name-only "${DIFF_COMMITISH}"..remotes/origin/"${BRANCH}" "${SOURCE_DIR}"/)
        DIFFENDCOMMAND=(xargs -0 git archive -o tmp/tmp.zip "${DIFF_COMMITISH}")
    fi
}

function copyMetaFilesToPackage(){
    echo "Deployment changes"
    local DIR
    # Make sure that a loop like "for X in DIR/*" has zero iterations when DIR is empty, instead of one iteration
    # with X=DIR/X
    shopt -s nullglob
    # Ensure any -meta.xml files are paired properly.
    for DIR in "${META_DIRS[@]}"; do
        if [[ ! -e tmp/package-add-or-update/"${SOURCE_DIR}"/main/default/"${DIR}" ]]; then
            continue
        fi
        for FILE in tmp/package-add-or-update/"${SOURCE_DIR}"/main/default/"$DIR"/*; do
            FILE=$(basename -- "$FILE")
            if [[ $DIR = staticresources ]]; then
                FILE=${FILE%%.*}.resource
            fi
            if [[ $FILE != "${FILE%-meta.xml}" ]]; then
                continue
            fi
            cp "${SOURCE_DIR}/main/default/$DIR/${FILE}-meta.xml" "tmp/package-add-or-update/${SOURCE_DIR}/main/default/${DIR}"
        done
    done
    # Copy full Aura and LWC directories where at least one change has been made
    for COMPONENT_DIR in "${COMPONENT_DIRS[@]}"; do
        if [[ ! -e tmp/package-add-or-update/"${SOURCE_DIR}"/main/default/"${COMPONENT_DIR}" ]]; then
            continue
        fi
        for DIR in tmp/package-add-or-update/"${SOURCE_DIR}"/main/default/"${COMPONENT_DIR}"/*; do
            if [[ ! -d ${DIR} ]]; then
                continue
            fi
            DIR=$(basename -- "${DIR}")
            cp -R "${SOURCE_DIR}/main/default/${COMPONENT_DIR}/${DIR}/"* "tmp/package-add-or-update/${SOURCE_DIR}/main/default/${COMPONENT_DIR}/${DIR}/"
        done
    done
}
