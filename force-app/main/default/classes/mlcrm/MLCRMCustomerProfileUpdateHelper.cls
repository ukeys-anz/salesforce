/**
 * @author Ankit Garg
 * @since 28/Aug/2023
 * @description CC-5234
 */
public with sharing class MLCRMCustomerProfileUpdateHelper {
  /**
   * @description Allow edit of certain fields for active/inactive Customer
   * @name getFieldsinFieldSets
   * @param objName Object Name
   * @return 'Set<String>'  - fieldsInFieldSet
   */
  public static Set<String> getFieldsinFieldSets(String objName) {
    Set<String> fieldsInFieldSet = new Set<String>();
    Map<String, List<CCRMCustomerProfileUpdateConfig.TrackingConfig>> trackingConfig = CCRMCustomerProfileUpdateHelper.IS_MLUSER
      ? CCRMCustomerProfileUpdateConfig.TRACKING_CONFIGS_ML
      : CCRMCustomerProfileUpdateConfig.TRACKING_CONFIGS;
    for (
      CCRMCustomerProfileUpdateConfig.TrackingConfig config : trackingConfig.get(
        objName
      )
    ) {
      fieldsInFieldSet.addAll(config.trackedFields);
    }
    return fieldsInFieldSet;
  }

  /**
   * @description Allow edit of certain fields for active/inactive Customer
   * @name getRecordsApplicableForStaging
   * @param records from the trigger
   * @param oldMap Map of old records
   * @param isProspect true if we are passing prospect account records & False if we are passing Active account records.
   * @return 'Map<Id,SObject>' - recordsApplicableForStaging
   */
  public static List<SObject> getRecordsApplicableForStaging(
    List<SObject> records,
    Map<Id, SObject> oldMap,
    Boolean isProspect
  ) {
    Map<Id, SObject> recordsApplicableForStagingMap = new Map<Id, SObject>();
    if (!records.isEmpty()) {
      Map<String, Set<String>> allowedFieldsToUpdateInCustomMetadata = CCRMCustomerProfileUpdateHelper.formObjectFieldsMap(
        records[0]
      );
      Set<String> allowedFieldsToUpdateInFieldSets = getFieldsinFieldSets(
        records[0].getSObjectType().getDescribe().name
      );
      Schema.DescribeSObjectResult objectInfo = records[0]
        .getSObjectType()
        .getDescribe();
      Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = objectInfo
        .sobjectType.getDescribe()
        .getRecordTypeInfosById();
      String recordTypeName;
      Set<String> fieldPopulated;
      for (Sobject record : records) {
        fieldPopulated = getAllFieldPopulated(record, oldMap);
        recordTypeName = recordTypeInfoMap
          .get((Id) record.get('RecordTypeId'))
          .getDeveloperName();
        for (String populatedfieldName : fieldPopulated) {
          if (
            //to check if the field is changed
            isFieldChanged(record, oldMap, populatedfieldName) &&
            //to check  if the Prospect Customer field which is updated exist in the corresponding 'ProspectTrackedFields' field Set
            (isFieldExistInFieldSet(
              isProspect,
              allowedFieldsToUpdateInFieldSets,
              populatedfieldName
            ) ||
            //to check if the existing Customer field which is updated exist in the 'DCRM_Customer_Management_Non_KYC_Fields__mdt' custom metadata
            (!isProspect &&
            allowedFieldsToUpdateInFieldSets.contains(populatedfieldName) &&
            allowedFieldsToUpdateInCustomMetadata.containsKey(
              objectInfo.name +
              '-' +
              recordTypeName
            ) &&
            allowedFieldsToUpdateInCustomMetadata.get(
                objectInfo.name +
                '-' +
                recordTypeName
              )
              .contains(populatedfieldName)))
          ) {
            recordsApplicableForStagingMap.put(record.id, record);
          }
        }
      }
    }
    if (!recordsApplicableForStagingMap.isEmpty()) {
      return recordsApplicableForStagingMap.values();
    }
    return new List<SObject>();
  }

  /**
   * @description check if the field is exist in field Set
   * @name isFieldExistInFieldSet
   * @param isProspect Boolean to check if its prospect customer
   * @param fieldsInFieldSet List Of Fields from FieldSet
   * @param populatedfieldName field name
   * @return Boolean - true or false
   */
  public static Boolean isFieldExistInFieldSet(
    Boolean isProspect,
    Set<String> fieldsInFieldSet,
    String populatedfieldName
  ) {
    return (isProspect && fieldsInFieldSet.contains(populatedfieldName));
  }

  /**
   * @description check if the field is exist in field Set
   * @name getAllFieldPopulated
   * @param record from the trigger
   * @param oldMap Map of old record
   * @return  Set<String> fieldPopulated
   */
  public static Set<String> getAllFieldPopulated(
    SObject record,
    Map<Id, SObject> oldMap
  ) {
    Set<String> fieldPopulated = new Set<String>();
    fieldPopulated.addAll(record.getPopulatedFieldsAsMap().keySet());
    if (oldMap != null) {
      fieldPopulated.addAll(
        oldMap.get((Id) record.get('Id')).getPopulatedFieldsAsMap().keySet()
      );
    }
    return fieldPopulated;
  }
  /**
   * @description check if the field is changed
   * @name isFieldChanged
   * @param record from the trigger
   * @param oldMap Map of old records
   * @param populatedfieldName field name
   * @return Boolean - true or false
   */
  public static Boolean isFieldChanged(
    SObject record,
    Map<Id, SObject> oldMap,
    String populatedfieldName
  ) {
    return (oldMap == null ||
    (String.valueOf(record.get(populatedfieldName)) !=
    String.valueOf(oldMap.get((Id) record.get('Id')).get(populatedfieldName))));
  }
}
