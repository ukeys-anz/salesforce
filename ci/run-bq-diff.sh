#!/bin/bash

# This script runs a diff between the schemas for a given sha that is stored in artifactory against the schemas in a bucket

# Function to print help message
print_help() {
    echo "Usage: $0 [BRANCH_NAME] [BUCKET_NAME] [options]"
    echo ""
    echo "Options:"
    echo "  --diff-only                  Only perform diff, do not upload to GCS"
    echo "  --local                      Run in local mode using provided paths"
    echo "  --sha-path <path>            Path to Artifactory schema folder (used with --local)"
    echo "  --gcs-path <path>            Path to GCS schema folder (used with --local)"
    echo "  --help                       Show this help message and exit"
    echo ""
    echo "Examples:"
    echo "  $0 develop my-bucket-name"
    echo "  $0 develop my-bucket-name --diff-only"
    echo "  $0 --local --sha-path ./art --gcs-path ./gcs"
}

# Default values for params and flags
DIFF_ONLY=false
LOCAL_MODE=false
BRANCH_NAME=""
BUCKET_NAME=""
SFDATASYNC_SHA_OBJECT_FIELDS=""
SFDATASYNC_GCS_OBJECT_FIELDS=""

# Parse the command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --diff-only) DIFF_ONLY=true ;;
    --local) LOCAL_MODE=true ;;
    --sha-path) SFDATASYNC_SHA_OBJECT_FIELDS=$2; shift ;;
    --gcs-path) SFDATASYNC_GCS_OBJECT_FIELDS=$2; shift ;;
    --help)
        print_help
        exit 0
        ;;
    *)
        if [[ -z "$BRANCH_NAME" ]]; then
            BRANCH_NAME=$1
        elif [[ -z "$BUCKET_NAME" ]]; then
            BUCKET_NAME=$1
        else
            echo "Unknown parameter passed: $1"
            exit 1 # Handle unknown flags or extra variables
        fi
        ;;
    esac
    shift
done

# Set paths based on mode
if [[ "$LOCAL_MODE" == "true" ]]; then
    echo "Running in LOCAL mode"
    # Ensure paths are provided via command-line
    if [[ -z "$SFDATASYNC_SHA_OBJECT_FIELDS" || -z "$SFDATASYNC_GCS_OBJECT_FIELDS" ]]; then
        echo "Error: In LOCAL mode, you must provide both --sha-path and --gcs-path."
        echo "Usage: ./ci/run-bq-diff.sh --local --sha-path /path/to/artifactory --gcs-path /path/to/gcs [--diff-only]"
        exit 1
    fi
    echo "Using local paths for testing:"
    echo "Artifactory Path: $SFDATASYNC_SHA_OBJECT_FIELDS"
    echo "GCS Path: $SFDATASYNC_GCS_OBJECT_FIELDS"
else
    # Normal CI operation
    ARTIFACTORY_ARTIFACT_NAME="sf_objects_success_diff_develop_$BRANCH_NAME"
    ARTIFACTORY_ARTIFACT_LINK="https://artifactory.gcp.anz/artifactory/anzx-salesforce-releases-np/$ARTIFACTORY_ARTIFACT_NAME.zip"

    echo "ARTIFACTORY_ARTIFACT_LINK=$ARTIFACTORY_ARTIFACT_LINK"

    echo "Pulling artifact from artifactory..."

    # Get zip from Artifactory
    if ! response=$(wget --server-response -P artifactory_success_output/ "$ARTIFACTORY_ARTIFACT_LINK" 2>&1); then
        echo "Error when pulling artifact from artifactory: $response"
    fi

    # Evaluate response from artifactory and unzip artifact
    status_code=$(echo "$response" | awk '/HTTP\// {print $2}' | tail -n 1)
    if [ -n "$status_code" ]; then
        if [ "$status_code" -eq 200 ]; then
            echo "Unzipping artifact..."
            unzip artifactory_success_output/$ARTIFACTORY_ARTIFACT_NAME.zip -d artifactory_success_output
        elif [ "$status_code" -eq 404 ]; then
            echo "Error: File not found (Status code: $status_code). This means that the upload-object-changes.yml workflow was not run on $BRANCH_NAME as a post deployment step on the develop branch. If this was a commit for a conflict fix on master, please merge it into develop first and then run the upload-object-changes.yml workflow on the develop branch. You can then re-run this workflow."
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
    SFDATASYNC_GCS_OBJECT_FIELDS="gcs_bucket"

    echo "Downloading files from GCS for the objects..."

    object_array=($(find "$SFDATASYNC_SHA_OBJECT_FIELDS/" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
    for object in "${object_array[@]}"; do
        if ! output=$(gsutil -m cp -r gs://$BUCKET_NAME/$object gcs_bucket 2>&1); then
            if echo "$output" | grep -q "No URLs matched"; then
                echo "No files or folders matched, but continuing without error."
            else
                echo "An error occurred during gsutil copy."
                exit 1
            fi
        else
            echo "$output"
        fi
    done

    ls -la "$SFDATASYNC_GCS_OBJECT_FIELDS"
fi

echo "Carrying out diff..."

# Function to extract field names
extract_field_names() {
  jq -r '.fields[].name' "$1"
}

# Function to extract full field objects for key-value comparison
extract_fields() {
  jq -c '.fields[]' "$1"
}

# Function to compare schema files by key-value pairs
compare_schemas() {
  local old_schema="$1"
  local new_schema="$2"

  if [[ ! -f "$old_schema" ]]; then
    echo -e "\n➕ New schema detected: $new_schema"
    new_fields=$(jq -c '.fields[]' "$new_schema")

    if [[ -z "$new_fields" ]]; then
      echo "⚠️ WARNING: New schema has no fields defined."
      return
    fi

    diff_output="\n🆕 New Schema Fields in '$new_schema':\n"
    while read -r field; do
      diff_output+="   ➕ $field\n"
    done <<< "$new_fields"

    echo -e "$diff_output"
    return
  fi

  old_fields=$(extract_field_names "$old_schema")
  new_fields=$(extract_field_names "$new_schema")

  old_count=$(echo "$old_fields" | wc -l | awk '{print $1}')
  new_count=$(echo "$new_fields" | wc -l | awk '{print $1}')

  # Check if new schema has fewer fields
  if [ "$new_count" -lt "$old_count" ]; then
    echo "❌ ERROR: New schema '$new_schema' has fewer fields than the existing schema '$old_schema'."
    exit 1
  fi

  # Extract full field objects for comparison
  extract_fields "$old_schema" > old_fields.json
  extract_fields "$new_schema" > new_fields.json

  # Detect removed or changed fields in a single pass
  field_diffs=()
  while read -r field; do
    old_value=$(jq -c --arg name "$field" 'select(.name == $name)' old_fields.json)
    new_value=$(jq -c --arg name "$field" 'select(.name == $name)' new_fields.json)

    if [[ -z "$new_value" ]]; then
      field_diffs+=("❌ REMOVED: $field")
    elif [[ "$old_value" != "$new_value" ]]; then
      field_diffs+=("⚠️ CHANGED: $field\n     🔴 OLD: $old_value\n     🟢 NEW: $new_value")
    fi
  done <<< "$old_fields"

  # Detect newly created fields
  while read -r field; do
    if ! echo "$old_fields" | grep -q "^$field$"; then
      field_diffs+=("➕ CREATED: $field")
    fi
  done <<< "$new_fields"

  # Generate diff output
  diff_output=""
  if [[ ${#field_diffs[@]} -gt 0 ]]; then
    diff_output+="\n📝 Field Changes in '$new_schema':\n"
    for diff in "${field_diffs[@]}"; do
      diff_output+="   $diff\n"
    done
    echo -e "$diff_output"
  else
    return
  fi
  # Cleanup temp files
  rm -f old_fields.json new_fields.json
}

# Run comparison for all JSON files in the directories
diff_output=""

for new_file in $(find "$SFDATASYNC_SHA_OBJECT_FIELDS" -type f -name 'required_fields.json'); do
  base_dir=$(dirname "${new_file/$SFDATASYNC_SHA_OBJECT_FIELDS/$SFDATASYNC_GCS_OBJECT_FIELDS}")
  old_file="$base_dir/required_fields.json"
    echo -e "\n🆚 Comparing $old_file (GCS) with $new_file (Artifactory)"
    diff_result=$(compare_schemas "$old_file" "$new_file")
      if [[ -n "$diff_result" ]]; then
        diff_output+="$diff_result\n"
      fi

done

echo "Checking for schemas removed from Artifactory..."

gcs_objects=($(find "$SFDATASYNC_GCS_OBJECT_FIELDS/" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))

for gcs_object in "${gcs_objects[@]}"; do
  if [[ ! -d "$SFDATASYNC_SHA_OBJECT_FIELDS/$gcs_object" ]]; then
    diff_output+="\n❌ REMOVED SCHEMA: $gcs_object"
    diff_output+="\n❌ REMOVED SCHEMA DIRECTORY: $gcs_object"
  fi
done

echo "Checking for schemas created in Artifactory..."

artifactory_objects=($(find "$SFDATASYNC_SHA_OBJECT_FIELDS/" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))

for artifactory_object in "${artifactory_objects[@]}"; do
  if [[ ! -d "$SFDATASYNC_GCS_OBJECT_FIELDS/$artifactory_object" ]]; then
    diff_output+="\n➕ CREATED SCHEMA: $artifactory_object"
    diff_output+="\n➕ CREATED SCHEMA DIRECTORY: $artifactory_object"
  fi
done

# Store diff output in diff_output variable
status=$?
echo -e "$diff_output"

if [ $status -eq 2 ]; then
    echo "An error occurred while comparing directories."
    exit 2
elif [ -n "$diff_output" ]; then
    echo "DIFF_ONLY set to: $DIFF_ONLY"
    if [[ "$DIFF_ONLY" == "false" && "$LOCAL_MODE" == "false" ]]; then
        echo "Changes found between $SFDATASYNC_SHA_OBJECT_FIELDS and $SFDATASYNC_GCS_OBJECT_FIELDS..."
        object_array=($(find "$SFDATASYNC_SHA_OBJECT_FIELDS/" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
        echo "Cleaning up objects in GCS and uploading artifact..."
        for object in "${object_array[@]}"; do
            if ! output=$(gcloud storage rm -r gs://$BUCKET_NAME/$object/** 2>&1); then
                if echo "$output" | grep -q "The following URLs matched no objects or files"; then
                    echo "No files or folders found to remove."
                else
                    echo "An error occurred during gsutil copy."
                    exit 1
                fi
            else
                echo "$output"
            fi
            gsutil -m cp -r $SFDATASYNC_SHA_OBJECT_FIELDS/$object/* gs://$BUCKET_NAME/$object/
        done
    fi
else
    echo "No changes found for sfdatasync user. Moving on..."
fi