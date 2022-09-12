/**
 * @author Emmanuel Yap
 * @since  12/2021
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadConversion is class to handle Lead Conversion process
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMLeadConversion {
  /**
   * @description Checks if Related Party is having a valid Related Party for Lead Conversion.
   * @name getLeadRecordForConversion
   * @param recordId The record id of selected Lead.
   * @return LeadConversionWrapper This is Lead Data Wrapper for Conversion.
   */
  @AuraEnabled
  public static LeadConversionWrapper getLeadRecordForConversion(Id recordId) {
    LeadConversionWrapper leadData = new LeadConversionWrapper();

    if (Schema.sObjectType.Lead.isQueryable()) {
      Lead convertLeadData = [
        SELECT
          Skip_Validations__c,
          Company,
          Name,
          FinServ__ExpressedInterest__c,
          New_to_Bank__c,
          FinServ__RelatedAccount__c,
          Not_Registered__c,
          ABN__c,
          ABN_Validation_Status__c,
          ACN__c,
          ACN_Validation_Status__c,
          FinServ__RelatedAccount__r.RecordType.DeveloperName,
          RecordType.DeveloperName,
          Address,
          Is_Valid_Address__c,
          CPID__c,
          Controlling_Post__c,
          Industry__c,
          Entity_Type__c,
          Street
        FROM LEAD
        WHERE ID = :recordId
        WITH SECURITY_ENFORCED
      ];
      if (convertLeadData != null) {
        leadData.leadRecord = convertLeadData;
      }
      if (convertLeadData.FinServ__RelatedAccount__c != null) {
        leadData.relatedAccountType = CCRMConstants.BUSINESS_PARTY_RECORDTYPES.contains(
            convertLeadData.FinServ__RelatedAccount__r.RecordType.DeveloperName
          )
          ? CCRMConstants.IS_BUSINESS
          : CCRMConstants.INDIVIDUAL_PARTY_RECORDTYPES.contains(
                convertLeadData.FinServ__RelatedAccount__r.RecordType.DeveloperName
              )
              ? CCRMConstants.IS_INDIVIDUAL
              : CCRMConstants.IS_INVALID;
      } else {
        leadData.leadRecord.FinServ__RelatedAccount__c = null;
      }
    }
    return leadData;
  }

  /**
   * @description Converts a lead with Related Party
   * @name convertLead
   * @param recordId The record id of Lead.
   * @param accountId The record id of Related Party selected in Lead.
   * @return `Id` of the created Opportunity
   */
  @AuraEnabled
  public static Id convertLead(Id recordId, Id accountId) {
    Database.LeadConvert lc = new Database.LeadConvert();

    lc.setLeadId(recordId);
    if (accountId != null) {
      lc.setAccountId(accountId);
    }

    List<Lead> leads = [
      SELECT
        id,
        FinServ__RelatedAccount__r.Name,
        FinServ__ExpressedInterest__c,
        Skip_Validations__c
      FROM Lead
      WHERE id = :recordId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    if (leads.isEmpty()) {
      return null;
    }

    checkSkipValidation(leads);

    String converted = CCRMConstants.STATUS_CONVERTED;
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE AND MasterLabel = :converted
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    lc.setConvertedStatus(convertStatus.MasterLabel);

    Set<Id> contactIds = new Set<Id>();
    for (AccountContactRelation acr : [
      SELECT ContactId
      FROM AccountContactRelation
      WHERE AccountId = :accountId
      WITH SECURITY_ENFORCED
    ]) {
      contactIds.add(acr.ContactId);
    }

    //Do not create opportunity
    //Opportunity creation required mapping of different type of fields
    //which is not possible using OOTB salesforce functionality
    lc.setDoNotCreateOpportunity(true);

    Database.LeadConvertResult lcr = Database.convertLead(lc);

    if (lcr.isSuccess()) {
      id accid = lcr.getAccountId();
      Id conid = lcr.getContactId();
      Id oppId = createOpportunity(recordId);

      if (oppId != null) {
        sendUpdateToUnicaOrAdobeOnLeadConversion(recordId, oppId);
      }
      if (!contactIds.contains(conid)) {
        deleteAutoCreatedContact(oppid, conid);
      }
      return oppId;
    } else {
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMLeadConversion.class.getName(),
        'convertLead'
      );
      CCRMLeadConversion.addLeadConvertResult(log, 'CCRMLeadConversion', lcr);
      return null;
    }
  }

  /**
   * @description This method creates an opportunity when lead is converted
   * @name createOpportunity
   * @param leadId The record id of Lead.
   * @return Id Opportunity Id
   */
  private static Id createOpportunity(Id leadId) {
    Set<Id> leadIds = new Set<Id>();
    leadIds.add(leadId);
    Map<Id, Opportunity> mapOfLeadsWithOpportunities = new CCRMLeadMappingEngine()
      .mapLeadToOpportunityFields(leadIds);
    Id oppId = null;
    if (
      mapOfLeadsWithOpportunities.size() > 0 &&
      Schema.sObjectType.Opportunity.isCreateable()
    ) {
      insert mapOfLeadsWithOpportunities.values();
    }
    if (mapOfLeadsWithOpportunities.containsKey(leadId)) {
      oppId = mapOfLeadsWithOpportunities.get(leadId).Id;
    }
    return oppId;
  }

  /**
   * @description This method send platform event when lead is converted
   * @name sendUpdateToUnicaOrAdobeOnLeadConversion
   * @param leadId The record id of Lead.
   * @param oppId The record id of Opportunity.
   */
  private static void sendUpdateToUnicaOrAdobeOnLeadConversion(
    Id leadId,
    Id oppId
  ) {
    Set<Id> leadIds = new Set<Id>();
    leadIds.add(leadId);

    Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
    mapOfOpportunityId.put(leadId, oppId);
    CCRMLeadActionsHelper.sendUpdateToUnicaOrAdobeOnLeadConversion(
      leadIds,
      mapOfOpportunityId
    );
  }

  /**
   * @description  The method addLeadConvertResult is used for for creating logs with existing Trace Id when performing lead conversion
   * The save results are checked to see if its successful and if there are any failures we add to the log list. At the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object. If an error is found, a boolean is returned so users can easily identify and throw errors
   * @param log Log object
   * @param objectName The name of the object used to create the log record.
   * @param leadConvertResult Lead Convert Result to log
   * @return Boolean
   */
  public static Boolean addLeadConvertResult(
    lib_systemLog log,
    String objectName,
    Database.LeadConvertResult leadConvertResult
  ) {
    Boolean hasError = false;
    if (!leadConvertResult.isSuccess()) {
      hasError = true;
      // Operation failed, so get all errors
      for (Database.Error err : leadConvertResult.getErrors()) {
        String errNo = String.valueof(err.getStatusCode());
        if (errNo.length() > 50) {
          errNo = errNo.substring(0, 50);
        }
        log.addObjectMessage(
          objectName,
          leadConvertResult.getLeadId(),
          errNo,
          'Id=' +
          leadConvertResult.getLeadId() +
          ',Message:' +
          err.getMessage() +
          'Fields:' +
          err.getFields(),
          lib_systemLog.Severity.ERROR
        );
      }
    }
    log.insertLog();
    return hasError;
  }

  /**
   * @description This is the wrapper class to wrap all the data required for Lead Conversion.
   * @param leadRecord Lead object
   * @param relatedAccountType The type of the related Party Account associated with the Lead about to get converted.
   */
  public class LeadConversionWrapper {
    /**
     * @description Lead Record
     */
    @AuraEnabled
    public Lead leadRecord { get; set; }
    /**
     * @description Related Account Type like isBusiness OR isIndividual.
     */
    @AuraEnabled
    public String relatedAccountType { get; set; }
  }
  /**
   * @description Checks if Lead Skip Validation is set.
   * @name checkSkipValidation
   * @param leads List of Leads to update Skip Validation
   */
  private static void checkSkipValidation(List<Lead> leads) {
    List<Id> leadIds = new List<Id>();
    for (Lead lead : leads) {
      lead.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      leadIds.add(lead.id);
    }

    if (
      !leads.isEmpty() &&
      Schema.sObjectType.Lead.isUpdateable() &&
      Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable()
    ) {
      List<Database.saveResult> results = Database.update(leads, false);
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'checkSkipValidation'
      );
      log.addDatabaseSaveResult('Lead', results, leads);
      log.insertLogAsync();
    }
    checkTaskSkipValidations(leadIds);
  }

  /**
   * @description Clear Task, OpportunityContactRole, and Contact of the newly converted Opportunity.
   * @name deleteContact
   * @param oppid The record Id of Opportunity
   * @param conid The record Id of Contact
   */
  private static void deleteAutoCreatedContact(Id oppid, Id conid) {
    updateTasks(oppid, conid);

    Contact leadContact = [
      SELECT Id, RecordTypeId
      FROM Contact
      WHERE Id = :conid
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];

    lib_systemLog log = new lib_systemLog(
      CCRMLeadConversion.class.getName(),
      'deleteAutoCreatedContact'
    );

    if (
      !Schema.sObjectType.Contact.isDeletable() &&
      !Schema.sObjectType.OpportunityContactRole.isDeletable()
    ) {
      return;
    }

    Database.DeleteResult result = Database.delete(leadContact, false);
    if (!result.isSuccess()) {
      logError('Contact', result, log);
    }
  }

  /**
   * @description Generic method to log delete failures in Lib_SystemLog.addObjectMessage
   * @param objectAPIName object API Name
   * @param deleteResult Database.DeleteResult
   * @param log lib_systemLog
   */
  private static void logError(
    String objectAPIName,
    Database.DeleteResult deleteResult,
    lib_systemLog log
  ) {
    for (Database.Error err : deleteResult.getErrors()) {
      String errNo = String.valueof(err.getStatusCode());
      log.addObjectMessage(
        objectAPIName,
        deleteResult.Id,
        errNo,
        'Id=' +
        deleteResult.Id +
        ',Message:' +
        err.getMessage() +
        'Fields:' +
        err.getFields(),
        lib_systemLog.Severity.ERROR
      );
    }
  }

  /**
   * @description Remove Contact from Task
   * @name updateTasks
   * @param oppid The record Id of Opportunity
   * @param conid The record Id of Contact
   */
  private static void updateTasks(Id oppid, Id conid) {
    List<Task> newTasks = new List<Task>();
    for (Task task : [
      SELECT subject, whoid
      FROM Task
      WHERE WhoId = :conid
      WITH SECURITY_ENFORCED
    ]) {
      if (task.WhoId == conid) {
        task.WhoId = null;
        task.WhatId = oppid;
        newTasks.add(task);
      }
    }
    if (
      !newTasks.isEmpty() &&
      Schema.sObjectType.Task.isUpdateable() &&
      Schema.sObjectType.Task.fields.WhoId.isUpdateable() &&
      Schema.sObjectType.Task.fields.WhatId.isUpdateable()
    ) {
      List<Database.SaveResult> results = Database.update(newTasks, false);
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'deleteAutoCreatedContact'
      );
      log.addDatabaseSaveResult('Lead', results, newTasks);
      log.insertLogAsync();
    }
  }

  /**
   * @description Check Task Skip Validations
   * @name checkTaskSkipValidations
   * @param leadIds List of Ids of updated Leads
   */
  private static void checkTaskSkipValidations(List<Id> leadIds) {
    List<Task> newTasks = new List<Task>();
    for (Task task : [
      SELECT subject, whoid, Skip_Validations__c
      FROM Task
      WHERE WhoId IN :leadIds
      WITH SECURITY_ENFORCED
    ]) {
      task.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      newTasks.add(task);
    }
    if (
      !newTasks.isEmpty() &&
      Schema.sObjectType.Task.isUpdateable() &&
      Schema.sObjectType.Task.fields.Skip_Validations__c.isUpdateable()
    ) {
      List<Database.SaveResult> results = Database.update(newTasks, false);
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        CCRMLeadActions.class.getName(),
        'checkTaskSkipValidations'
      );
      log.addDatabaseSaveResult('Task', results, newTasks);
      log.insertLogAsync();
    }
  }
}
