/**
 * @author Emmanuel Yap
 * @since  12/2021
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadConversion is class to handle Lead Conversion process
 * Added without sharing to bypass sharing settings as Account OWD is Public Read Only and will remain as is for customer accounts.
 * Lead conversion requires an Edit permission on account object otherwise it will throw insufficient access to account records error.
 */
public without sharing class CCRMLeadConversion {
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

    if (Schema.sObjectType.Lead.isQueryable()) {
      Lead convertLeadData = [
        SELECT
          Skip_Validations__c,
          Company,
          Name,
          FirstName,
          MiddleName,
          LastName,
          Title__c,
          Email,
          MobilePhone,
          Home_Phone__c,
          Work_Phone__c,
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
          Street,
          City,
          State,
          Country,
          PostalCode,
          Is_Valid_Address__c,
          CPID__c,
          Controlling_Post__c,
          Industry__c,
          Entity_Type__c,
          Lead.Industry__r.Code__c
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

    List<Task> task = [
      SELECT Response_Type__r.Unica_Lead_SubStatus__c, WhoId
      FROM Task
      WHERE WhoId = :recordId
      WITH SECURITY_ENFORCED
      ORDER BY createddate DESC
      LIMIT 1
    ];

    //Do not create opportunity
    //Opportunity creation required mapping of different type of fields
    //which is not possible using OOTB salesforce functionality
    lc.setDoNotCreateOpportunity(true);

    Database.LeadConvertResult lcr = Database.convertLead(lc);

    if (lcr.isSuccess()) {
      Id conid = lcr.getContactId();
      Id oppId = createOpportunity(recordId);

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
   * @param leadId The record id of Lead.
   * @return Id Opportunity Id
   */
  private static Id createOpportunity(Id leadId) {
    Set<Id> leadIds = new Set<Id>();
    leadIds.add(leadId);
    Map<Id, Opportunity> mapOfLeadsWithOpportunities = new CCRMLeadMappingEngine()
      .mapLeadToOpportunityFields(leadIds, new Map<Id, Id>());
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
      Logger.error('', results);
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
      Logger.error('', results);
      Logger.saveLog();
    }
  }

  /**
   * @description Wrapper class to store only the required search party information
   */
  public class CCRMSearchPartyInfo {
    @AuraEnabled
    public string id;
    @AuraEnabled
    public string ocvId;
    @AuraEnabled
    public string name;
    @AuraEnabled
    public string clg;
    @AuraEnabled
    public string suburb;
    @AuraEnabled
    public string postCode;
    @AuraEnabled
    public string cpid;
    @AuraEnabled
    public string kycStatus;
  }

  /**
   * @description Wrapper class to send required and certified results seperately.
   */
  public class CCRMSearchPartyInfoWrapper {
    @AuraEnabled
    public List<CCRMSearchPartyInfo> certifiedResults;
    @AuraEnabled
    public List<CCRMSearchPartyInfo> probableResults;
  }

  /**
   * @param record Lead record from lwc component.
   * @return CCRMSearchPartyInfo for lwc
   * @description called from lead conversion lwc component
   */
  @AuraEnabled(cacheable=false)
  public static CCRMSearchPartyInfoWrapper searchPartyInfoLWC(Lead record) {
    CCRMSearchPartyModel result;
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    CCRMSearchPartyInfoWrapper searchPartyWrapper;
    Set<String> externalIds = new Set<String>();
    try {
      result = ccrmapi.searchPartyInfo(record);
      for (
        CCRMSearchPartyModel.CustomerDetails certResult : result.certifiedResults
      ) {
        externalIds.add(
          certResult.sourceSystems[0].sourceSystemName +
          '_' +
          certResult.sourceSystems[0].sourceSystemId
        );
      }
      for (
        CCRMSearchPartyModel.CustomerDetails probResult : result.probableResults
      ) {
        externalIds.add(
          probResult.sourceSystems[0].sourceSystemName +
          '_' +
          probResult.sourceSystems[0].sourceSystemId
        );
      }

      searchPartyWrapper = populatePartyDetails(externalIds, result);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return searchPartyWrapper;
  }

  /**
   * @param externalIds set of unique ids to query from salesforce database
   * @param result response data from callout
   * @return CCRMSearchPartyInfoWrapper for lwc
   * @description populate party details and return to lwc component
   */
  public static CCRMSearchPartyInfoWrapper populatePartyDetails(
    Set<String> externalIds,
    CCRMSearchPartyModel result
  ) {
    CCRMSearchPartyInfoWrapper searchPartyWrapper = new CCRMSearchPartyInfoWrapper();
    searchPartyWrapper.certifiedResults = new List<CCRMSearchPartyInfo>();
    searchPartyWrapper.probableResults = new List<CCRMSearchPartyInfo>();
    Map<String, String> accountIdMap = new Map<String, String>();
    for (Account acc : [
      SELECT Id, External_Id__c
      FROM Account
      WHERE External_Id__c IN :externalIds
      WITH SECURITY_ENFORCED
    ]) {
      accountIdMap.put(acc.External_Id__c, acc.Id);
    }
    for (
      CCRMSearchPartyModel.CustomerDetails certResult : result.certifiedResults
    ) {
      String externalId =
        certResult.sourceSystems[0].sourceSystemName +
        '_' +
        certResult.sourceSystems[0].sourceSystemId;
      if (accountIdMap.containsKey(externalId)) {
        CCRMSearchPartyInfo rec = new CCRMSearchPartyInfo();
        rec.id = accountIdMap.get(externalId);
        rec.ocvId = certResult.ocvId;
        String firstName = String.isNotBlank(certResult.names[0].firstName)
          ? certResult.names[0].firstName
          : '';
        rec.name = firstName + ' ' + certResult.names[0]?.lastName;
        rec.suburb = certResult.addresses[0]?.city;
        rec.postCode = certResult.addresses[0]?.postalCode;
        rec.cpid = certResult.cpId;
        rec.kycStatus = certResult.kycDetails.status;
        searchPartyWrapper.certifiedResults.add(rec);
      }
    }
    for (
      CCRMSearchPartyModel.CustomerDetails probResult : result.probableResults
    ) {
      String externalId =
        probResult.sourceSystems[0].sourceSystemName +
        '_' +
        probResult.sourceSystems[0].sourceSystemId;
      if (accountIdMap.containsKey(externalId)) {
        CCRMSearchPartyInfo rec = new CCRMSearchPartyInfo();
        rec.id = accountIdMap.get(externalId);
        rec.ocvId = probResult.ocvId;
        String firstName = String.isNotBlank(probResult.names[0].firstName)
          ? probResult.names[0].firstName
          : '';
        rec.name = firstName + ' ' + probResult.names[0]?.lastName;
        rec.suburb = probResult.addresses[0]?.city;
        rec.postCode = probResult.addresses[0]?.postalCode;
        rec.cpid = probResult.cpId;
        rec.kycStatus = probResult.kycDetails.status;
        searchPartyWrapper.probableResults.add(rec);
      }
    }
    return searchPartyWrapper;
  }

  /**
   * @description called from lead conversion lwc component
   * @name createPartyLWC
   * @param record Lead record from lwc component.
   */
  @AuraEnabled(cacheable=false)
  public static void createPartyLWC(Lead record) {
    CCRMCreatePartyModel result;
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    try {
      result = ccrmapi.createParty(record);
      updateLeadWithCapcisId(record, result.capcisId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Updates lead with capcis id which will be used in Account trigger handler
   * @name updateLeadWithCapcisId
   * @param record Lead record from lwc component.
   * @param capcisId capcis id from cap api response
   */
  private static void updateLeadWithCapcisId(Lead record, String capcisId) {
    if (
      Schema.sObjectType.Lead.isUpdateable() &&
      Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable() &&
      Schema.sObjectType.Lead.fields.CAPCIS_ID__c.isUpdateable()
    ) {
      record.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      record.CAPCIS_ID__c = capcisId;
      try {
        update record;
      } catch (Exception e) {
        //log errors to application log
        Lib_SystemLog.createSingleLogAsync(
          CCRMLeadConversion.class.getName(),
          'updateLeadWithCapcisId',
          record.Id,
          e.getMessage()
        );
      }
    }
  }
}
