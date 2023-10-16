/**
 * @author Ankit Garg
 * @since 17/July/2023
 * @description CC-4429 Queueable apex class to auto create Task for mismatch during Lead conversion
 * This is without sharing as it is calling from MLCRMAutoTaskOnLeadConversionqueueable class which should run as system context.
 * Added cyclomaticComplexity surpression due to method checkLeadMisMatchCustomer logic check
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class MLCRMAutoTaskOnLeadConversionHelper {
  /**
   * @description This method to query lead details along with customer details
   * @name getLeads
   * @param leadIds Set of Lead Ids
   * @return List<Lead>
   * @author Ankit Garg
   * @US CC-4429
   */
  public static List<Lead> getLeads(Set<Id> leadIds) {
    return [
      SELECT
        Id,
        OwnerId,
        RecordType.DeveloperName,
        FirstName,
        MiddleName,
        LastName,
        Home_Phone__c,
        Work_Phone__c,
        MobilePhone,
        Email,
        Street,
        City,
        State,
        Country,
        PostalCode,
        AdvertisingIndicator__c,
        FinServ__RelatedAccount__c,
        FinServ__RelatedAccount__r.FirstName,
        FinServ__RelatedAccount__r.MiddleName,
        FinServ__RelatedAccount__r.LastName,
        FinServ__RelatedAccount__r.Phone,
        FinServ__RelatedAccount__r.PersonContactId,
        FinServ__RelatedAccount__r.PersonContact.HomePhone,
        FinServ__RelatedAccount__r.PersonContact.MobilePhone,
        FinServ__RelatedAccount__r.PersonContact.Email,
        FinServ__RelatedAccount__r.PersonContact.OtherStreet,
        FinServ__RelatedAccount__r.PersonContact.OtherCity,
        FinServ__RelatedAccount__r.PersonContact.OtherState,
        FinServ__RelatedAccount__r.PersonContact.OtherCountry,
        FinServ__RelatedAccount__r.PersonContact.OtherPostalCode,
        FinServ__RelatedAccount__r.Advertising_Indicator__c
      FROM Lead
      WHERE
        Id IN :leadIds
        AND RecordType.DeveloperName = 'MLCRM_Lead'
        AND FinServ__RelatedAccount__c != NULL
        AND FinServ__RelatedAccount__r.OCV_Event_Version__c != 0
    ];
  }

  /**
   * @description This method
   * @name checkLeadMisMatchCustomer
   * @param leads List of Lead records
   * @return Map<Id,String>
   * @author Ankit Garg
   * @US CC-4429
   */
  public static Map<Id, String> checkLeadMisMatchCustomer(List<Lead> leads) {
    String fields = '';
    Boolean isMismatch = false;
    Map<Id, String> mismtachLeadsWithFieldsMap = new Map<Id, String>();
    for (Lead leadRecord : leads) {
      fields = '\n';
      isMismatch = false;
      if (
        leadRecord.FirstName != leadRecord.FinServ__RelatedAccount__r.FirstName
      ) {
        fields += '- First Name\n';
        isMismatch = true;
      }
      if (
        leadRecord.MiddleName !=
        leadRecord.FinServ__RelatedAccount__r.MiddleName
      ) {
        fields += '- Middle Name\n';
        isMismatch = true;
      }
      if (
        leadRecord.LastName != leadRecord.FinServ__RelatedAccount__r.LastName
      ) {
        fields += '- Last Name\n';
        isMismatch = true;
      }
      if (
        arePhonesEqual(
          leadRecord.Home_Phone__c,
          leadRecord.FinServ__RelatedAccount__r.PersonContact.HomePhone
        )
      ) {
        fields += '- Home Phone\n';
        isMismatch = true;
      }
      if (
        arePhonesEqual(
          leadRecord.Work_Phone__c,
          leadRecord.FinServ__RelatedAccount__r.Phone
        )
      ) {
        fields += '- Work Phone\n';
        isMismatch = true;
      }
      if (
        arePhonesEqual(
          leadRecord.MobilePhone,
          leadRecord.FinServ__RelatedAccount__r.PersonContact.MobilePhone
        )
      ) {
        fields += '- Mobile Phone\n';
        isMismatch = true;
      }
      if (
        leadRecord.Email !=
        leadRecord.FinServ__RelatedAccount__r.PersonContact.Email
      ) {
        fields += '- Email\n';
        isMismatch = true;
      }
      if (
        leadRecord.Street !=
        leadRecord.FinServ__RelatedAccount__r.PersonContact.OtherStreet
      ) {
        fields += '- Street\n';
        isMismatch = true;
      }
      if (
        leadRecord.City !=
        leadRecord.FinServ__RelatedAccount__r.PersonContact.OtherCity
      ) {
        fields += '- City\n';
        isMismatch = true;
      }
      if (
        leadRecord.State !=
        leadRecord.FinServ__RelatedAccount__r.PersonContact.OtherState
      ) {
        fields += '- State\n';
      }
      if (
        leadRecord.Country !=
        leadRecord.FinServ__RelatedAccount__r.PersonContact.OtherCountry
      ) {
        fields += '- Country\n';
        isMismatch = true;
      }
      if (
        leadRecord.PostalCode !=
        leadRecord.FinServ__RelatedAccount__r.PersonContact.OtherPostalCode
      ) {
        fields += '- Postal Code\n';
        isMismatch = true;
      }
      if (
        areAdvertisingIndicatorEquals(
          leadRecord.AdvertisingIndicator__c,
          leadRecord.FinServ__RelatedAccount__r.Advertising_Indicator__c
        )
      ) {
        fields += '- Advertising Indicator\n';
        isMismatch = true;
      }
      if (isMismatch) {
        mismtachLeadsWithFieldsMap.put(leadRecord.Id, fields);
      }
    }
    return mismtachLeadsWithFieldsMap;
  }

  /**
   * @description arePhonesEqual Generic method to match Phone Numbers
   * @param phone1 Phone Number to compare from
   * @param phone2 Phone Number to compare with
   * @return Boolean
   */
  private static Boolean arePhonesEqual(String phone1, String phone2) {
    String phoneNumber1 = phone1 != null ? phone1.right(8) : null;
    String phoneNumber2 = phone2 != null ? phone2.right(8) : null;
    if (phoneNumber1 != phoneNumber2) {
      return true;
    }
    return false;
  }

  /**
   * @description areAdvertisingIndicatorEquals method to match advertising Indicator of two different type
   * @param advIndicatorBoolean Advertising Indicator of Boolean Type to compare with
   * @param advIndicatorString Advertising Indicator of String/Picklist Type to compare from
   * @return Boolean
   */
  private static Boolean areAdvertisingIndicatorEquals(
    Boolean advIndicatorBoolean,
    String advIndicatorString
  ) {
    return ((String.isNotBlank(advIndicatorString) &&
    advIndicatorString.equalsIgnoreCase(MLCRMConstants.YES)) !=
    advIndicatorBoolean);
  }

  /**
   * @description This method
   * @name generateTasks
   * @param leads List of Lead records
   * @param mapLeadToOpportunity map of lead to opportunity
   * @param mismtachLeadsWithFieldsMap map of lead id with mismatched Fields
   * @return Map<Id,String>
   * @author Ankit Garg
   * @US CC-4429
   */
  public static List<Task> generateTasks(
    List<Lead> leads,
    Map<Id, Id> mapLeadToOpportunity,
    Map<Id, String> mismtachLeadsWithFieldsMap
  ) {
    Task taskRecord = new Task();
    List<Task> taskList = new List<Task>();
    if (mismtachLeadsWithFieldsMap.isEmpty()) {
      return taskList;
    }
    for (Lead leadRecord : leads) {
      taskRecord = new Task();
      if (mismtachLeadsWithFieldsMap.containsKey(leadRecord.Id)) {
        taskRecord = autocreateTask(
          leadRecord,
          mapLeadToOpportunity,
          mismtachLeadsWithFieldsMap.get(leadRecord.Id)
        );
        if (taskRecord != null) {
          taskList.add(taskRecord);
        }
      }
    }
    return taskList;
  }

  /**
   * @description This method to auto Create a task on lead conversion
   * @name autocreateTask
   * @param lead Lead record
   * @param mapLeadToOpportunity map of lead to opportunity
   * @param fields Fields which is mismatched
   * @return Task
   * @author Ankit Garg
   * @US CC-4429
   */
  private static Task autocreateTask(
    Lead lead,
    Map<Id, Id> mapLeadToOpportunity,
    String fields
  ) {
    Task task = new Task(
      recordtypeId = MLCRMConstants.MLCRM_TASK_RT_ID,
      Status = MLCRMConstants.STATUS_OPEN,
      Priority = MLCRMConstants.PRIORITY_NORMAL,
      Subject = Label.MLCRM_Auto_Task_MistMatch_Subject,
      WhatId = mapLeadToOpportunity.get(lead.id),
      WhoId = lead.FinServ__RelatedAccount__r.PersonContactId,
      OwnerId = lead.OwnerId,
      ActivityDate = null,
      Description = Label.MLCRM_Auto_Task_MistMatch_Message +
        MLCRMConstants.SPACE +
        fields
    );
    return task;
  }
}
