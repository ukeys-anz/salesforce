#!/bin/bash

# This script runs a diff between the schemas for a given sha that is stored in artifactory against the schemas in a bucket

# $1 is the BRANCH NAME
# $2 is the BUCKET NAME

ARTIFACTORY_ARTIFACT_NAME="sf_objects_success_diff_develop_$1"
ARTIFACTORY_ARTIFACT_LINK="https://artifactory.gcp.anz/artifactory/anzx-salesforce-releases-np/$ARTIFACTORY_ARTIFACT_NAME.zip"

echo "ARTIFACTORY_ARTIFACT_LINK=$ARTIFACTORY_ARTIFACT_LINK"

echo "Pulling artifact from artifactory..."

if ! response=$(wget --server-response -P artifactory_success_output/ "$ARTIFACTORY_ARTIFACT_LINK" 2>&1); then
    echo "Error when pulling artifact from artifactory: $response"
fi

# Get zip from Artifactory
status_code=$(echo "$response" | awk '/HTTP\// {print $2}' | tail -n 1)
if [ -n "$status_code" ]; then
    if [ "$status_code" -eq 200 ]; then
        echo "Unzipping artifact..."
        unzip artifactory_success_output/$ARTIFACTORY_ARTIFACT_NAME.zip -d artifactory_success_output
    elif [ "$status_code" -eq 404 ]; then
        echo "Error: File not found (Status code: $status_code). This means that the upload-object-changes.yml workflow was not run on $1 as a post deployment step on the develop branch. If this was a commit for a conflict fix on master, please merge it into develop first and then run the upload-object-changes.yml workflow on the develop branch. You can then re-run this workflow."
        echo "wget threw error with status code: $status_code"
        exit 1
    else
        echo "wget threw error with status code: $status_code"
        exit 1
    fi
fi

# Get files from GCS
mkdir gcs_bucket
SFDATASYNC_SHA_OBJECT_FIELDS="artifactory_success_output/output"

echo "Downloading files from GCS for the objects..."

object_array=($(find "$SFDATASYNC_SHA_OBJECT_FIELDS/" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
for object in "${object_array[@]}"; do
    if ! output=$(gsutil -m cp -r gs://$2/$object gcs_bucket 2>&1); then
        echo "$output"
        if echo "$output" | grep -q "No URLs matched"; then
            echo "No files or folders matched, but continuing without error."
        else
            echo "An error occurred during gsutil copy."
            exit 1
        fi
    fi
done

SFDATASYNC_GCS_OBJECT_FIELDS="gcs_bucket"
ls -la "$SFDATASYNC_GCS_OBJECT_FIELDS"

echo "Carrying out diff..."

# diff and upload to GCS if changes are detected
diff_output=$(diff -qr "$SFDATASYNC_SHA_OBJECT_FIELDS" "$SFDATASYNC_GCS_OBJECT_FIELDS" || true)
status=$?
echo $diff_output
if [ $status -eq 2 ]; then
    echo "An error occurred while comparing directories."
    exit 2
elif [ -n "$diff_output" ]; then
    echo "Changes found between $SFDATASYNC_SHA_OBJECT_FIELDS and $SFDATASYNC_GCS_OBJECT_FIELDS..."
    object_array=($(find "$SFDATASYNC_SHA_OBJECT_FIELDS/" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
    echo "Cleaning up objects in GCS and uploading artifact..."
    for object in "${object_array[@]}"; do
        if ! output=$(gcloud storage rm -r gs://$2/$object/** 2>&1); then
            echo "$output"
            if echo "$output" | grep -q "The following URLs matched no objects or files"; then
                echo "No files or folders found to remove."
            else
                echo "An error occurred during gsutil copy."
                exit 1
            fi
        fi
        gsutil -m cp -r $SFDATASYNC_SHA_OBJECT_FIELDS/$object/* gs://$2/$object/
    done
else
    echo "No changes found for sfdatasync user. Moving on..."
fi
