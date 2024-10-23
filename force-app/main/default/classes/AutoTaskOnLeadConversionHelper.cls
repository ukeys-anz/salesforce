/**
 * @author Ankit Garg
 * @since 17/July/2023
 * @description CC-4429 Queueable apex class to auto create Task for mismatch during Lead conversion
 * This is without sharing as it is calling from AutoTaskOnLeadConversionQueueable class which should run as system context.
 */
public without sharing class AutoTaskOnLeadConversionHelper {
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );
  private static Map<String, String> mapLeadToAccountFields = new Map<String, String>{
    'FirstName' => 'FirstName',
    'MiddleName' => 'MiddleName',
    'LastName' => 'LastName',
    'Work_Phone__c' => 'Phone',
    'AdvertisingIndicator__c' => 'Advertising_Indicator__c' //make this part of the map, have separate Set to determine fields to compare, which could include this field when lead is MLCRM
  };

  private static Map<String, String> mapLeadToContactFields = new Map<String, String>{
    'Street' => 'OtherStreet',
    'City' => 'OtherCity',
    'State' => 'OtherState',
    'Country' => 'OtherCountry',
    'PostalCode' => 'OtherPostalCode',
    'Home_Phone__c' => 'HomePhone',
    'MobilePhone' => 'MobilePhone'
  };

  private static final Map<String, Schema.SObjectField> LEAD_FIELDS = SObjectType.Lead.fields.getMap();
  public static final String STATUS_OPEN = 'Open';
  public static final String PRIORITY_NORMAL = 'Normal';
  public static final String SPACE = ' ';

  /**
   * @description This method check the mismatch between lead fields and related account fields
   * @name checkLeadMisMatchCustomer
   * @param leadRecord Lead record
   * @return Map<Id,String>
   * @author Ankit Garg
   * @US CC-4429
   */
  public static Map<Id, String> checkLeadMisMatchCustomer(Lead leadRecord) {
    Set<String> fieldsToCompare = new Set<String>{
      'FirstName',
      'MiddleName',
      'LastName',
      'Work_Phone__c',
      'Street',
      'City',
      'State',
      'Country',
      'PostalCode',
      'Home_Phone__c',
      'MobilePhone'
    };

    if (leadRecord.RecordType.DeveloperName == 'MLCRM_Lead') {
      fieldsToCompare.add('AdvertisingIndicator__c');
    }
    Set<String> mismatched = compareLeadWithCustomerFields(
      leadRecord,
      fieldsToCompare
    );
    if (mismatched.isEmpty()) {
      return new Map<Id, String>();
    }
    List<String> mismatchList = new List<String>(mismatched);
    return new Map<Id, String>{
      leadRecord.Id => '\n- ' + String.join(mismatchList, '\n- ')
    };
  }

  /**
   * @description This method checks the mismatch between field of lead and related account
   * @name checkLeadMisMatchCustomer
   * @param leadRecord Lead record
   * @param fieldsToCompare contains set of lead fields to compare
   * @return Set<String>
   * @author Ankit Garg
   * @US CC-4429
   */
  @TestVisible
  private static Set<String> compareLeadWithCustomerFields(
    Lead leadRecord,
    Set<String> fieldsToCompare
  ) {
    Set<String> mismatched = new Set<String>();
    for (String fieldApi : fieldsToCompare) {
      if (checkField(leadRecord, fieldApi) == false) {
        mismatched.add(LEAD_FIELDS.get(fieldApi).getDescribe().Label);
      }
    }
    return mismatched;
  }

  /**
   * @description This method compares each field of lead and related account
   * @name checkField
   * @param leadRecord Lead record
   * @param fieldApi lead field api name
   * @return Boolean
   * @author Ankit Garg
   * @US CC-4429
   */
  @TestVisible
  private static Boolean checkField(Lead leadRecord, String fieldApi) {
    Object leadValue = leadRecord.get(fieldApi);
    Object targetValue = getTargetValue(leadRecord, fieldApi);
    if (fieldApi == 'AdvertisingIndicator__c') {
      return areAdvertisingIndicatorEquals(
        (Boolean) leadValue,
        (String) targetValue
      );
    }
    if (fieldApi.contains('Phone')) {
      return arePhonesEqual((String) leadValue, (String) targetValue);
    }
    return leadValue == targetValue;
  }

  /**
   * @description This method get field to be checked from financial account
   * @name getTargetValue
   * @param leadRecord Lead record
   * @param fieldApi lead field api name
   * @return Object - Target Value of the record
   * @author Ankit Garg
   * @US CC-4429
   */
  @TestVisible
  private static Object getTargetValue(Lead leadRecord, String fieldApi) {
    if (mapLeadToAccountFields.containsKey(fieldApi)) {
      return leadRecord.FinServ__RelatedAccount__r.get(
        mapLeadToAccountFields.get(fieldApi)
      );
    }
    if (
      mapLeadToContactFields.containsKey(fieldApi) &&
      leadRecord.FinServ__RelatedAccount__r.PersonContact != null
    ) {
      String parentfield = mapLeadToContactFields.get(fieldApi);
      return leadRecord.FinServ__RelatedAccount__r.PersonContact.get(
        parentfield
      );
    }
    return null;
  }

  /**
   * @description arePhonesEqual Generic method to match Phone Numbers
   * @name arePhonesEqual
   * @param phone1 Phone Number to compare from
   * @param phone2 Phone Number to compare with
   * @return Boolean
   */
  @TestVisible
  private static Boolean arePhonesEqual(String phone1, String phone2) {
    String phoneNumber1 = String.isNotBlank(phone1) ? phone1.right(8) : '';
    String phoneNumber2 = String.isNotBlank(phone2) ? phone2.right(8) : '';
    if (phoneNumber1.equalsIgnoreCase(phoneNumber2)) {
      return true;
    }
    return false;
  }

  /**
   * @description areAdvertisingIndicatorEquals method to match advertising Indicator of two different type
   * @name areAdvertisingIndicatorEquals
   * @param advIndicatorBoolean Advertising Indicator of Boolean Type to compare with
   * @param advIndicatorString Advertising Indicator of String/Picklist Type to compare from
   * @return Boolean
   */
  @TestVisible
  private static Boolean areAdvertisingIndicatorEquals(
    Boolean advIndicatorBoolean,
    String advIndicatorString
  ) {
    return ((String.isNotBlank(advIndicatorString) &&
    advIndicatorString.equalsIgnoreCase(MLCRMConstants.YES)) ==
    advIndicatorBoolean);
  }

  /**
   * @description This method
   * @name generateTasks
   * @param leadRecord Lead record
   * @param opportunityID opportunity id
   * @param mismtachLeadsWithFieldsMap map of lead id with mismatched Fields
   * @return Map<Id,String>
   * @author Ankit Garg
   * @US CC-4429
   */
  public static List<Task> generateTasks(
    Lead leadRecord,
    ID opportunityID,
    Map<Id, String> mismtachLeadsWithFieldsMap
  ) {
    if (
      mismtachLeadsWithFieldsMap.isEmpty() ||
      !mismtachLeadsWithFieldsMap.containsKey(leadRecord.Id)
    ) {
      return new List<Task>();
    }
    Task taskRecord = new Task();
    if (leadRecord.RecordType.DeveloperName == 'MLCRM_Lead') {
      taskRecord = autocreateTaskForML(
        leadRecord,
        opportunityID,
        mismtachLeadsWithFieldsMap.get(leadRecord.Id)
      );
    }
    if (leadRecord.RecordType.DeveloperName == 'CCRM_Lead') {
      taskRecord = autocreateTaskForCCRM(
        leadRecord,
        opportunityID,
        mismtachLeadsWithFieldsMap.get(leadRecord.Id)
      );
    }
    if (taskRecord != null) {
      return new List<Task>{ taskRecord };
    }
    return null;
  }

  /**
   * @description This method to auto Create a task on lead conversion for ML
   * @name autocreateTaskForML
   * @param lead Lead record
   * @param opportunityID  opportunity ID
   * @param fields Fields which is mismatched
   * @return Task
   * @author Ankit Garg
   * @US CC-4429
   */
  @TestVisible
  private static Task autocreateTaskForML(
    Lead lead,
    ID opportunityID,
    String fields
  ) {
    Task task = new Task(
      recordtypeId = RTTask.mlcrmTask,
      Status = STATUS_OPEN,
      Priority = PRIORITY_NORMAL,
      Subject = Label.MLCRM_Auto_Task_MistMatch_Subject,
      WhatId = opportunityID,
      WhoId = lead.FinServ__RelatedAccount__r.PersonContactId,
      OwnerId = lead.OwnerId,
      ActivityDate = null,
      Description = Label.MLCRM_Auto_Task_MistMatch_Message + SPACE + fields
    );
    return task;
  }

  /**
   * @description This method to auto Create a task on lead conversion for CCRM
   * @name autocreateTaskForCCRM
   * @param lead Lead record
   * @param opportunityID  opportunity ID
   * @param fields Fields which is mismatched
   * @return Task
   * @author Naman Garg
   * @US CC-7259
   */
  @TestVisible
  private static Task autocreateTaskForCCRM(
    Lead lead,
    Id opportunityID,
    String fields
  ) {
    Task task = new Task(
      recordtypeId = RTTask.ccrmTask,
      Status = STATUS_OPEN,
      Priority = PRIORITY_NORMAL,
      Subject = Label.CCRM_Auto_Task_MisMatch_Subject,
      WhatId = opportunityID,
      WhoId = lead.FinServ__RelatedAccount__r.PersonContactId,
      OwnerId = lead.OwnerId,
      ActivityDate = System.Today() + 7,
      Description = Label.MLCRM_Auto_Task_MistMatch_Message + SPACE + fields
    );
    return task;
  }
}
