#!/bin/bash

set -euo pipefail

CHECK_FLAG=false
newFieldFiles=""
errors=""
warnings=""
declare -A objectsFromFields  # Associative array to track unique parent objects that have field changes

echo ""
echo "***************************************************************"
echo ""
echo "-------------------- Find files to be checked -----------------------"
echo ""

QUALITY_CHECK_FILE_NAME="quality-check-${REPO_NAME}-${PR_NUMBER}.txt"

if [[ ! -f "$QUALITY_CHECK_FILE_NAME" ]]; then
  echo "$QUALITY_CHECK_FILE_NAME could not be found"
  exit 1
fi

# Configuration: Define paths to permission sets, muting sets, and exclusion files
BACKUP_PSET="force-app/main/default/permissionsets/Backup_and_Restore.permissionset-meta.xml"
BIGQ_PSET="force-app/main/default/permissionsets/SF_Data_Sync_Integration.permissionset-meta.xml"
BACKUP_MUTING_PSET="force-app/main/default/mutingPermissionSets/Backup_and_Restore_Muted.mutingpermissionset-meta.xml"
BACKUP_EXCLUSION="config/backup_exclusionfile.json"
BIGQ_EXCLUSION="config/bigq_exclusionfile.json"
OBJECT_CHANGES_LIST="config/object-changes-list.json"

# ========== HELPER FUNCTIONS ==========

# Extract the Salesforce object name from a file path
# Example: "force-app/main/default/objects/Account/fields/Name.field-meta.xml" -> "Account"
getObjectNameFromPath() {
  local path="$1"
  echo "$path" | sed -n 's|.*objects/\([^/]*\)/.*|\1|p'
}

# Extract the field name from a field metadata file path
# Example: "objects/Account/fields/CustomField__c.field-meta.xml" -> "CustomField__c"
getFieldNameFromPath() {
  local path="$1"
  local filename=$(basename "$path")
  echo "${filename%.field-meta.xml}"
}

# Check if a specific field exists in a permission set XML file
# Args: $1=field name (Object.Field__c format), $2=permission set file path
# Returns: 0 if found, 1 if not found
isFieldInPermissionSet() {
  local field="$1"
  local pset_file="$2"

  if grep -q "<field>$field</field>" "$pset_file" 2>/dev/null; then
    return 0  # Found
  else
    return 1  # Not found
  fi
}

# Check if a field is excluded in a JSON exclusion file
# Args: $1=object name, $2=field name, $3=exclusion file path
# Returns: 0 if excluded, 1 if not excluded
# Handles both "all" value and array of specific fields
isFieldInExclusion() {
  local object_name="$1"
  local field_name="$2"
  local exclusion_file="$3"

  if [[ ! -f "$exclusion_file" ]]; then
    return 1  # Exclusion file doesn't exist, treat field as not excluded
  fi

  # Query the JSON exclusion file to check if the object has "all" or the field is in the array
  local result=$(jq -r --arg obj "$object_name" --arg field "$field_name" '
    if (.[$obj] == "all") then
      "true"
    elif (.[$obj] | type == "array") then
      if (.[$obj] | index($field)) then
        "true"
      else
        "false"
      end
    else
      "false"
    end
  ' "$exclusion_file" 2>/dev/null || echo "false")

  echo "  [DEBUG] isFieldInExclusion: object=$object_name, field=$field_name, file=$exclusion_file, excluded=$result"

  if [[ "$result" == "true" ]]; then
    return 0  # Field is excluded
  else
    return 1  # Field is not excluded
  fi
}

# Check if a specific object exists in a permission set XML file
# Args: $1=object name, $2=permission set file path
# Returns: 0 if found, 1 if not found
isObjectInPermissionSet() {
  local object_name="$1"
  local pset_file="$2"

  if grep -q "<object>$object_name</object>" "$pset_file" 2>/dev/null; then
    return 0  # Object found in permission set
  else
    return 1  # Object not found in permission set
  fi
}

# Check if an object is in the SF Data Sync whitelist
# Args: $1=object name, $2=permission set name
# Returns: 0 if in whitelist or not SF_Data_Sync_Integration, 1 if not in whitelist
isObjectInSfDataSyncWhitelist() {
  local object_name="$1"
  local pset_name="$2"

  if [[ ! -f "$OBJECT_CHANGES_LIST" ]]; then
    return 1  # Config file doesn't exist, treat object as not in whitelist
  fi

  if [[ "$pset_name" != "SF_Data_Sync_Integration" ]]; then
    return 0  # Skip whitelist check for non-SF_Data_Sync_Integration permission sets
  fi

  local result=$(jq -r --arg obj "$object_name" '
    if (.sfdatasync_object_whitelist | index($obj)) then
      "true"
    else
      "false"
    end
  ' "$OBJECT_CHANGES_LIST" 2>/dev/null || echo "false")

  if [[ "$result" == "true" ]]; then
    return 0  # Object found in SF Data Sync whitelist
  else
    return 1  # Object not in SF Data Sync whitelist
  fi
}

# Check if an object is excluded with value "all" in the backup exclusion file
# Args: $1=object name, $2=permission set name
# Returns: 0 if excluded or SF_Data_Sync_Integration, 1 if not excluded
isObjectInBackupExclusion() {
  local object_name="$1"
  local pset_name="$2"

  if [[ ! -f "$BACKUP_EXCLUSION" ]]; then
    return 1  # Exclusion file doesn't exist, treat object as not excluded
  fi

  if [[ "$pset_name" == "SF_Data_Sync_Integration" ]]; then
    return 1  # Skip backup exclusion check for SF_Data_Sync_Integration permission set
  fi

  # Query the JSON exclusion file to check if the object has value "all"
  local result=$(jq -r --arg obj "$object_name" '
    if (.[$obj] == "all") then
      "true"
    else
      "false"
    end
  ' "$BACKUP_EXCLUSION" 2>/dev/null || echo "false")

  if [[ "$result" == "true" ]]; then
    return 0  # Object is excluded (has "all" value)
  else
    return 1  # Object is not excluded
  fi
}

# Main function to validate that new fields are properly defined in a permission set
# Args: $1=permission set name, $2=permission set file path, $3=exclusion file path
# This function checks all new field files against the specified permission set and exclusion rules
checkPermissionSet() {
  local WHICH_PSET="$1"
  local PSET_PATH="$2"
  local EXCLUSION_PATH="$3"
  local localErrors=""
  local localWarnings=""

  if [[ ! -f "${PSET_PATH}" ]];then
    echo "$WHICH_PSET Permission set does not exist..."
    echo "⏭️  Skip checking..."
    echo "----------------------------------------------"
    echo ""
    return
  fi

  while IFS= read -r field_file; do
    if [[ -z "$field_file" ]]; then continue; fi

    object_name=$(getObjectNameFromPath "$field_file")
    field_name=$(getFieldNameFromPath "$field_file")
    full_field_name="${object_name}.${field_name}"

    # Skip __mdt (metadata types) and __x (external objects) and __e (event objects) - these should NOT be in permission sets
    if [[ "$object_name" =~ (__x|__mdt|__e)$ ]]; then
      echo "  ⏭️  Skipping $full_field_name - Fields/Objects from __e, __mdt and __x objects should NOT be added to $WHICH_PSET"
      continue
    fi

    # Skip __b (big objects) for SF_Data_Sync_Integration permission set
    if [[ "$object_name" =~ (__b)$ ]] && [[ "${WHICH_PSET}" == "SF_Data_Sync_Integration" ]]; then
      echo "  ⏭️  Skipping $full_field_name - Fields/Objects from __b objects should NOT be added to $WHICH_PSET"
      continue
    fi

    if ! isObjectInSfDataSyncWhitelist "$object_name" "$WHICH_PSET"; then
      # Object not in whitelist - add a warning that it should be added to the whitelist or exclusion file
      echo "  ⚠️  Warning: $object_name - Object is not in whitelist check for $WHICH_PSET (Object)"
      localWarnings+="<p>  - $object_name object</p><p>    $object_name should be added to BQ whitelist/exclusion file</p>"
      warning=true
      continue
    fi

    if isObjectInBackupExclusion "$object_name" "$WHICH_PSET"; then
      echo "  ⏭️  Skipping $object_name - Object is excluded in $EXCLUSION_PATH"
      continue
    fi

    if isFieldInExclusion "$object_name" "$field_name" "$EXCLUSION_PATH"; then
      echo "  ⏭️  Skipping $full_field_name - Object/field is excluded in $EXCLUSION_PATH"
      continue
    fi 

    # Verify that the object is defined in the permission set XML file
    if ! isObjectInPermissionSet "$object_name" "$PSET_PATH"; then
      echo "  ❌  Failed: $object_name - $WHICH_PSET Permission Set Check Failed (Object)"
      localErrors+="<p>  - $object_name object</p>"
      failed=true
    fi

    # Skip field-level checks for muted permission sets (only object-level checks are required)
    if [[ "${WHICH_PSET}" == "Backup_and_Restore_Muted" ]];then
      continue
    fi

    # Verify that the field is defined in the permission set XML file
    if ! isFieldInPermissionSet "$full_field_name" "$PSET_PATH"; then
      echo "  ❌  Failed: $full_field_name - $WHICH_PSET Permission Set Check Failed (Field)"
      localErrors+="<p>  - $full_field_name field</p>"
      failed=true
    fi
  done <<< "$newFieldFiles"

  if [[ -n "$localErrors" ]]; then
    errors+="<p>❌ $WHICH_PSET Permission Set Check Failed</p>$localErrors"
  fi

  if [[ -n "$localWarnings" ]]; then
    warnings+="<p>⚠️  $WHICH_PSET - Whitelist Check<p>$localWarnings"
  fi
  echo "----------------------------------------------"
  echo ""
}


# Parse the quality check file to find changed files in object directories
# Filters for files in force-app or knowledge-mgm under objects/ path
CHANGED_FILES=$(cat "$QUALITY_CHECK_FILE_NAME" | jq -R -s -r '
  split("\n")[] |
  select(
    test("^(force-app|knowledge-mgm)/main/(default|sf-lending|generic-components)/objects/")
  )
')

# Iterate through changed files to identify new field metadata files
while IFS= read -r file_path; do
  if [[ "$file_path" =~ ^(force-app|knowledge-mgm)/main/(default|sf-lending|generic-components)/objects/[^/]+/fields/.*\.field-meta\.xml$ ]]; then
    echo "✅ Found new field: $file_path"
    CHECK_FLAG=true
    newFieldFiles+="$file_path"$'\n'

    # Extract and store the parent object name in the associative array for tracking
    object_name=$(getObjectNameFromPath "$file_path")
    objectsFromFields["$object_name"]=true
  fi
done <<< "$CHANGED_FILES"

echo ""
echo "***************************************************************"
echo "                Running Permission Set Checks                  "
echo "***************************************************************"
echo ""

if [[ "${CHECK_FLAG}" == "false" ]]; then
  echo "✅ No field changes."
  {
    echo "result<<EOF"
    echo "<p>✅ Permission set check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

# Initialize result file and tracking flags for failures and warnings
failed=false
warning=false
result_file="$RUNNER_TEMP/pset_result.html"
: > "$result_file"

# ========== CHECK 1: Backup & Restore Permission Set ==========
echo "🔍 Checking Backup & Restore Permission Set for new fields/objects..."
checkPermissionSet "Backup_and_Restore" "$BACKUP_PSET" "$BACKUP_EXCLUSION"

# ========== CHECK 2: SF Data Sync Integration Permission Set ==========
echo "🔍 Checking SF Data Sync Integration Permission Set for new fields/objects..."
checkPermissionSet "SF_Data_Sync_Integration" "$BIGQ_PSET" "$BIGQ_EXCLUSION"

# ========== CHECK 3: Backup & Restore Muted Permission Set ==========
echo "🔍 Checking Backup & Restore Muted Permission Set for new objects..."
checkPermissionSet "Backup_and_Restore_Muted" "$BACKUP_MUTING_PSET" "$BACKUP_EXCLUSION" 

# ========== REPORT SUMMARY ==========

if [[ -n "$errors" ]]; then
  echo "<details><summary>❌ Permission Set Check Failed</summary>" >> "$result_file"
  echo "<pre>" >> "$result_file"
  echo -e "$errors" >> "$result_file"
  echo "" >> "$result_file"
  echo "</pre></details>" >> "$result_file"
fi

if [[ -n "$warnings" ]]; then
  echo "<details><summary>⚠️ Whitelist Check (Objects)</summary>" >> "$result_file"
  echo "<pre>" >> "$result_file"
  echo -e "$warnings" >> "$result_file"
  echo "" >> "$result_file"
  echo "</pre></details>" >> "$result_file"
fi

if [[ "$failed" == "true" ]] || [[ "$warning" == "true" ]]; then
  cat "$result_file" 
  {
    echo "result<<EOF"
    cat "$result_file"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  echo ""
else
  echo "✅ All Permission Set checks passed."
  {
    echo "result<<EOF"
    echo "<p>✅ Permission set check passed</p>"
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
fi

if [[ "$failed" == "true" ]]; then
  echo "🚫 One or more Permission Set checks failed. See above for details."
  exit 1
fi
