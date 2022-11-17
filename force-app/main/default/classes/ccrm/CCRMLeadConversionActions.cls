/**
 * @author Boobalakrishnan Duraisamy
 * @since  10/2022
 * @description CCRM lead conversion actions which includes calling search and create party api, deleting auto created contacts post conversion
 */
public with sharing class CCRMLeadConversionActions {
  /**
   * @description Clear Task, OpportunityContactRole, and Contact of the newly converted Opportunity.
   * @name deleteContact
   * @param oppid The record Id of Opportunity
   * @param conid The record Id of Contact
   */
  public static void deleteAutoCreatedContact(Id oppid, Id conid) {
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
      Logger.error(
        'Error occured while deleting contact record during lead conversion.',
        result
      );
      Logger.saveLog();
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
      Logger.error(
        'Error occured while updating tasks during lead conversion',
        results
      );
      Logger.saveLog();
    }
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
      externalIds.addAll(populateExternalIds(result.certifiedResults));
      externalIds.addAll(populateExternalIds(result.probableResults));
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
    Map<String, Account> accountIdMap = new Map<String, Account>();
    for (Account acc : [
      SELECT Id, External_Id__c, Name
      FROM Account
      WHERE External_Id__c IN :externalIds
      WITH SECURITY_ENFORCED
    ]) {
      accountIdMap.put(acc.External_Id__c, acc);
    }
    for (
      CCRMSearchPartyModel.CustomerDetails certResult : result.certifiedResults
    ) {
      if (accountIdMap.containsKey(generateExternalId(certResult))) {
        searchPartyWrapper.certifiedResults.add(
          populateSearchPartyWrapper(certResult, accountIdMap)
        );
      }
    }

    for (
      CCRMSearchPartyModel.CustomerDetails probResult : result.probableResults
    ) {
      if (accountIdMap.containsKey(generateExternalId(probResult))) {
        searchPartyWrapper.probableResults.add(
          populateSearchPartyWrapper(probResult, accountIdMap)
        );
      }
    }

    return searchPartyWrapper;
  }

  /**
   * @param searchPartyResult search party result from the API, either certified or probable result
   * @param accountIdMap map of accounts with key as external id
   * @return CCRMSearchPartyInfo returns search party wrapper for lwc component
   * @description populates search party wrapper used in lwc component
   */
  private static CCRMSearchPartyInfo populateSearchPartyWrapper(
    CCRMSearchPartyModel.CustomerDetails searchPartyResult,
    Map<String, Account> accountIdMap
  ) {
    CCRMSearchPartyInfo rec = new CCRMSearchPartyInfo();
    String externalId = generateExternalId(searchPartyResult);
    rec.id = accountIdMap.get(externalId).Id;
    rec.ocvId = searchPartyResult.ocvId;
    rec.name = accountIdMap.get(externalId).Name;
    rec.suburb = searchPartyResult.addresses[0]?.city;
    rec.postCode = searchPartyResult.addresses[0]?.postalCode;
    rec.cpid = searchPartyResult.cpId;
    rec.kycStatus = searchPartyResult.kycDetails.status;
    return rec;
  }

  /**
   * @param searchPartyResults search party results from the API.
   * @return Set<String> set of external Ids
   * @description called to populate external ids which will be used to account records in salesforce
   */
  private static Set<String> populateExternalIds(
    List<CCRMSearchPartyModel.CustomerDetails> searchPartyResults
  ) {
    Set<String> externalIds = new Set<String>();
    for (
      CCRMSearchPartyModel.CustomerDetails searchPartyResult : searchPartyResults
    ) {
      externalIds.add(generateExternalId(searchPartyResult));
    }
    return externalIds;
  }

  /**
   * @param searchPartyResult search party result from the API, either certified or probable result
   * @return String external Id which is a combination of source system name and source system id
   * @description used to generate external id which will be used to query account object
   */
  private static String generateExternalId(
    CCRMSearchPartyModel.CustomerDetails searchPartyResult
  ) {
    return searchPartyResult.sourceSystems[0].sourceSystemName +
      '_' +
      searchPartyResult.sourceSystems[0].sourceSystemId;
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
      Database.SaveResult result = Database.update(record, false);
      if (!result.isSuccess()) {
        Logger.error(
          'Error occured while updating lead record during conversion.',
          result
        );
        Logger.saveLog();
      }
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
}
