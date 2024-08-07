/**
 * @author Emmanuel Yap
 * @since  12/2021
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadConversion is class to handle Lead Conversion process
 * Added without sharing to bypass sharing settings as Account OWD is Public Read Only and will remain as is for customer accounts.
 * Lead conversion requires an Edit permission on account object otherwise it will throw insufficient access to account records error.
 */
public without sharing class CCRMLeadConversion {
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );
  /**
   * @description Checks if Related Party is having a valid Related Party for Lead Conversion.
   * Added without sharing to bypass sharing settings as Account OWD is Public Read Only and will remain as is for customer accounts.
   * Lead conversion requires an Edit permission on account object otherwise it will throw insufficient access to account records error.
   * @name getLeadRecordForConversion
   * @param recordId The record id of selected Lead.
   * @return LeadConversionWrapper This is Lead Data Wrapper for Conversion.
   */
  @AuraEnabled
  public static LeadConversionWrapper getLeadRecordForConversion(Id recordId) {
    LeadConversionWrapper leadData = new LeadConversionWrapper();
    Lead convertLeadData = LEADCONV_REPOSITORY.getLeadRecordForConversion(
      recordId
    );
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

    List<Task> task = [
      SELECT Response_Type__r.Unica_Lead_SubStatus__c, WhoId, CreatedDate
      FROM Task
      WHERE WhoId = :recordId
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    //Do not create opportunity
    //Opportunity creation required mapping of different type of fields
    //which is not possible using OOTB salesforce functionality
    lc.setDoNotCreateOpportunity(true);

    Database.LeadConvertResult lcr = Database.convertLead(lc);
    if (lcr.isSuccess()) {
      Id conid = lcr.getContactId();
      Id oppId = createOpportunity(new Map<Id, Lead>(leads));

      if (oppId != null) {
        sendUpdateToUnicaOrAdobeOnLeadConversion(recordId, oppId, task);
      }
      if (!contactIds.contains(conid)) {
        CCRMLeadConversionActions.deleteAutoCreatedContact(oppid, conid);
      }
      return oppId;
    } else {
      CCRMLeadConversion.addLeadConvertResult('CCRMLeadConversion', lcr);
      return null;
    }
  }

  /**
   * @description This method creates an opportunity when lead is converted
   * @name createOpportunity
   * @param leadMap map of lead record.
   * @return Id Opportunity Id
   */
  private static Id createOpportunity(Map<Id, Lead> leadMap) {
    Map<Id, Opportunity> mapOfLeadsWithOpportunities = new CCRMLeadMappingEngine()
      .mapLeadToOpportunityFields(leadMap, new Map<Id, Id>());
    Id oppId = null;
    if (Schema.sObjectType.Opportunity.isCreateable()) {
      insert mapOfLeadsWithOpportunities.values();
    }
    for (Id leadId : leadMap.keySet()) {
      if (mapOfLeadsWithOpportunities.containsKey(leadId)) {
        oppId = mapOfLeadsWithOpportunities.get(leadId).Id;
      }
    }
    return oppId;
  }

  /**
   * @description This method send platform event when lead is converted
   * @name sendUpdateToUnicaOrAdobeOnLeadConversion
   * @param leadId The record id of Lead.
   * @param oppId The record id of Opportunity.
   * @param task List of Task attached to Lead.
   */
  private static void sendUpdateToUnicaOrAdobeOnLeadConversion(
    Id leadId,
    Id oppId,
    List<Task> task
  ) {
    Set<Id> leadIds = new Set<Id>();
    leadIds.add(leadId);

    Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
    mapOfOpportunityId.put(leadId, oppId);
    CCRMLeadPlatformEventHelper.leadTask = task;
    CCRMLeadPlatformEventActions.sendUpdateToUnicaOrAdobeOnLeadConversion(
      leadIds,
      mapOfOpportunityId
    );
  }

  /**
   * @description  The method addLeadConvertResult is used for for creating logs with existing Trace Id when performing lead conversion
   * The save results are checked to see if its successful and if there are any failures we add to the log list. At the end the caller should call {@link insertLog()} method
   * to create record/records in Traced_Application_Log__b object. If an error is found, a boolean is returned so users can easily identify and throw errors
   * @param objectName The name of the object used to create the log record.
   * @param leadConvertResult Lead Convert Result to log
   * @return Boolean
   */
  public static Boolean addLeadConvertResult(
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
        Logger.error(
          'Id=' +
            leadConvertResult.getLeadId() +
            ',Message:' +
            err.getMessage() +
            'Fields:' +
            err.getFields()
        );
      }
    }
    Logger.saveLog();
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
  public static void checkSkipValidation(List<Lead> leads) {
    if (leads.isEmpty()) {
      return;
    }
    List<Id> leadIds = new List<Id>();
    List<Lead> leadList = new List<Lead>();
    Boolean skipValidationAccess = Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable();

    for (Lead lead : leads) {
      lead.Skip_Validations__c = skipValidationAccess
        ? CCRMConstants.CONVERT_LEAD
        : lead.Skip_Validations__c;
      leadList.add(lead);
      leadIds.add(lead.id);
    }

    if (!leadList.isEmpty() && Schema.sObjectType.Lead.isUpdateable()) {
      List<Database.saveResult> results = Database.update(leadList, false);
      Logger.error('Errors while skip validating Lead records', results);
      Logger.saveLog();
    }
    checkTaskSkipValidations(leadIds);
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
    ]) {
      if (task.Skip_Validations__c != CCRMConstants.CONVERT_LEAD) {
        task.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
        newTasks.add(task);
      }
    }
    if (
      !newTasks.isEmpty() &&
      Schema.sObjectType.Task.isUpdateable() &&
      Schema.sObjectType.Task.fields.Skip_Validations__c.isUpdateable()
    ) {
      List<Database.SaveResult> results = Database.update(newTasks, false);
      Logger.error('Errors while skip validating Task records', results);
      Logger.saveLog();
    }
  }
}
