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
    Set<String> fieldsToQuery = extractFieldNames(mergedFieldMatcher);
    //Get the name of the object for the given record
    String sObjectName = recordId.getSObjectType().toString();

    // Query the database for the necessary fields
    List<SObject> recordsFromDatabase = PUSH_TO_APP_REPOSITORY.queryMergeFieldsData(
      fieldsToQuery,
      recordId,
      sObjectName
    );

    // Replace the merged fields in the JSON string
    return replaceFieldsInJson(
      aemContentData,
      recordsFromDatabase,
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
  private static Set<String> extractFieldNames(Matcher mergedFieldMatcher) {
    Set<String> fieldsToQuery = new Set<String>();
    while (mergedFieldMatcher.find()) {
      String fieldName = mergedFieldMatcher.group(1);
      fieldsToQuery.add(fieldName);
    }

    return fieldsToQuery;
  }

  // Replaces the field placeholders in the JSON string with actual values from the database
  @TestVisible
  private static String replaceFieldsInJson(
    String aemContentData,
    List<SObject> recordsFromDatabase,
    Matcher mergedFieldMatcher
  ) {
    mergedFieldMatcher.reset();

    while (mergedFieldMatcher.find()) {
      String fieldName = mergedFieldMatcher.group(1);
      SObject record = recordsFromDatabase.get(0);
      String fieldvalue = '';

      if (fieldName.contains('.')) {
        List<String> parts = fieldName.split('\\.');
        SObject relatedObject = record.getSObject(parts[0]);

        fieldvalue = (parts.size() > 1 &&
          relatedObject != null)
          ? String.valueOf(relatedObject.get(parts[1]))
          : '';
      } else {
        fieldvalue = String.valueOf(record.get(fieldName));
      }
      aemContentData = aemContentData.replace(
        mergedFieldMatcher.group(0),
        fieldValue != null ? fieldValue : ''
      );
    }

    return aemContentData;
  }
}
