/**
 * @author Ankit Garg
 * @since 17/July/2023
 * @description CC-4429 Queueable apex class to auto create Task for mismatch during Lead conversion
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class MLCRMAutoTaskOnLeadConversionQueueable implements Queueable {
  private Map<Id, Id> mapLeadToOpportunity = new Map<Id, Id>();

  /**
   * @description Constructor
   * @param leadOppMap Map of Lead ID with Opportunity
   */
  public MLCRMAutoTaskOnLeadConversionQueueable(Map<Id, Id> leadOppMap) {
    this.mapLeadToOpportunity = leadOppMap;
  }

  /**
   * @description execute method
   * @param context QueueableContext
   */
  public void execute(QueueableContext context) {
    // auto task to be created on lead conversion if there is mismatching data in the lead in comparison the related customer record
    List<Lead> leads = new List<Lead>();
    List<Task> taskList = new List<Task>();
    if (!mapLeadToOpportunity.isEmpty()) {
      leads = getLeads(mapLeadToOpportunity.keySet());
    }
    if (!leads.isEmpty()) {
      taskList = checkLeadMistMatchCustomer(leads, mapLeadToOpportunity);
    }
    if (Task.sObjectType.getDescribe().isCreateable() && !taskList.isEmpty()) {
      List<Database.SaveResult> results = Database.insert(taskList, false);
      for (Database.SaveResult dr : results) {
        if (!dr.isSuccess()) {
          logError('Lead', dr);
        }
      }
    }
    Logger.saveLog();
  }

  /**
   * @description This method to query lead details along with customer details
   * @name getLeads
   * @param leadIds Set of Lead Ids
   * @return List<Lead>
   * @author Ankit Garg
   * @US CC-4429
   */
  private static List<Lead> getLeads(Set<Id> leadIds) {
    List<Lead> leads = [
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
        FinServ__RelatedAccount__r.PersonContact.OtherPostalCode
      FROM Lead
      WHERE
        Id IN :leadIds
        AND RecordType.DeveloperName = 'MLCRM_Lead'
        AND FinServ__RelatedAccount__c != NULL
        AND FinServ__RelatedAccount__r.OCV_Event_Version__c != 0
    ];
    return leads;
  }

  /**
   * @description This method
   * @name checkLeadMistMatchCustomer
   * @param leads List of Lead records
   * @param mapLeadToOpportunity map of lead to opportunity
   * @return List<Task>
   * @author Ankit Garg
   * @US CC-4429
   */
  @SuppressWarnings('PMD.NcssMethodCount')
  private static List<Task> checkLeadMistMatchCustomer(
    List<Lead> leads,
    Map<Id, Id> mapLeadToOpportunity
  ) {
    String fields = '';
    Boolean isMismatch = false;
    Task taskRecord = new Task();
    List<Task> taskList = new List<Task>();
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
        checkPhone(
          leadRecord.Home_Phone__c,
          leadRecord.FinServ__RelatedAccount__r.PersonContact.HomePhone
        )
      ) {
        fields += '- Home Phone\n';
        isMismatch = true;
      }
      if (
        checkPhone(
          leadRecord.Work_Phone__c,
          leadRecord.FinServ__RelatedAccount__r.Phone
        )
      ) {
        fields += '- Work Phone\n';
        isMismatch = true;
      }
      if (
        checkPhone(
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
        fields += '- PostalCode\n';
        isMismatch = true;
      }
      if (isMismatch) {
        taskRecord = autocreateTask(leadRecord, mapLeadToOpportunity, fields);
        if (taskRecord != null) {
          taskList.add(taskRecord);
        }
      }
    }
    return taskList;
  }
  /**
   * @description checkPhone Generic method to match Phone Numbers
   * @param leadPhone Phone Number of Lead
   * @param customerPhone Phone Number of Customer
   * @return Boolean
   */
  private static Boolean checkPhone(String leadPhone, String customerPhone) {
    String phone1 = leadPhone != null ? leadPhone.right(8) : null;
    String phone2 = customerPhone != null ? customerPhone.right(8) : null;
    if (phone1 != phone2) {
      return true;
    }
    return false;
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

  /**
   * @description Generic method to log delete failures in Logger
   * @param objectAPIName object API Name
   * @param result Database.SaveResult
   */
  private void logError(String objectAPIName, Database.SaveResult result) {
    for (Database.Error err : result.getErrors()) {
      Logger.error(err.getMessage());
    }
  }

  /**
   * @description extend the Exception class to allow errors to be thrown if the user does not have access
   */
  private class MLCRMAutoTaskOnLeadConversionException extends Exception {
  }
}
