/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description Helps in converting merged fields of AEM Data into appropriate values.
 * Helps in preparing notification data which needs to be sent to Mobile (push to app).
 */
public class AemDataMergeFieldProcessor {
  private static final PushToAppRepository PUSH_TO_APP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  /**
   * @description Replace Merged Fields into appropriate values.
   * @param aemContentData Data received from AEM.
   * @param recordId The Id of the record for which notification needs to send.
   * @return String with appropriate field values
   */
  public static String replaceMergedFields(String aemContentData, Id recordId) {
    Matcher mergedFieldMatcher = getMergedFieldMatcher(aemContentData);
    //Extract field names from the JSON string
    Set<String> fieldsToQuery = extractFieldNames(mergedFieldMatcher, recordId);

    // Query the database for the necessary fields
    SObject recordDetail = PUSH_TO_APP_REPOSITORY.queryMergeFieldsData(
      fieldsToQuery,
      recordId
    );

    // Replace the merged fields in the JSON string
    return replaceFieldsInJson(
      aemContentData,
      recordDetail,
      mergedFieldMatcher
    );
  }

  // Common method to create a Matcher object based on the JSON string
  private static Matcher getMergedFieldMatcher(String aemContentData) {
    String mergedFieldRegex = '\\{!([a-zA-Z0-9_\\.]+)\\}';
    Pattern mergedFieldPattern = Pattern.compile(mergedFieldRegex);
    return mergedFieldPattern.matcher(aemContentData);
  }

  // Extracts the field names from the JSON string
  @TestVisible
  private static Set<String> extractFieldNames(
    Matcher mergedFieldMatcher,
    Id recordId
  ) {
    Set<String> fieldsToQuery = new Set<String>();
    while (mergedFieldMatcher.find()) {
      fieldsToQuery.add(mergedFieldMatcher.group(1));
    }

    // This will give fieldsMap which we can use to retrieve the field type
    Map<String, Schema.SObjectField> fieldsMap = recordId
      .getSObjectType()
      .getDescribe()
      .fields.getMap();

    Set<String> finalFields = new Set<String>();

    for (String fieldName : fieldsToQuery) {
      // Add relationship fields (e.g., Account.Name) as-is
      if (fieldName.contains('.')) {
        finalFields.add(fieldName);
        continue;
      }

      // Apply toLabel only for picklist fields
      if (
        fieldsMap.get(fieldName).getDescribe().getType() ==
        Schema.DisplayType.Picklist
      ) {
        finalFields.add('toLabel(' + fieldName + ')');
      } else {
        finalFields.add(fieldName);
      }
    }

    return finalFields;
  }

  // Replaces the field placeholders in the JSON string with actual values from the database
  @TestVisible
  private static String replaceFieldsInJson(
    String aemContentData,
    SObject recordDetail,
    Matcher mergedFieldMatcher
  ) {
    mergedFieldMatcher.reset();

    while (mergedFieldMatcher.find()) {
      String fieldName = mergedFieldMatcher.group(1);
      String fieldvalue = '';

      if (fieldName.contains('.')) {
        List<String> parts = fieldName.split('\\.');
        SObject relatedObject = recordDetail.getSObject(parts[0]);

        if (relatedObject != null) {
          fieldvalue = String.valueOf(relatedObject.get(parts[1]));
        }
      } else {
        fieldvalue = String.valueOf(recordDetail.get(fieldName));
      }

      aemContentData = aemContentData.replace(
        mergedFieldMatcher.group(0),
        fieldValue ?? ''
      );
    }

    return aemContentData;
  }
}
