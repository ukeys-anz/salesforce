/**
 * @author Mobile Lending Team
 * @since  02/2025
 * @description Lead conversion actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class LeadConversionController {
  private static final Map<String, String> RELATED_ACCOUNT_MAP = new Map<String, String>{
    'Business_Account' => 'isBusiness',
    'PersonAccount' => 'isIndividual',
    'CLG' => 'isIndividual'
  };
  public static Boolean manualLeadConversionInitiated = false;
  public static Boolean leadConverionFlow = false;
  private static final String ACCOUNT_CREATION_ERROR = 'Shell Customer Creation Failure.';
  private static final String IS_INVALID = 'isInvalid';
  private static final String MLCRM_LEAD_RECORDTYPE_NAME = 'MLCRM_Lead';
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );
  private static final AccountActionsRepository ACCOUNT_REPOSITORY = (AccountActionsRepository) Lib_InstanceProvider.forType(
    AccountActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

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
    Lead convertLeadRecord = LEADCONV_REPOSITORY.getLeadRecordForConversion(
      recordId
    );
    if (convertLeadRecord == null) {
      return leadData;
    }
    leadData.leadRecord = convertLeadRecord;
    leadData.relatedAccountType = getRelatedAccountType(convertLeadRecord);
    return leadData;
  }

  /**
   * @description getRelatedAccountType to get the Related Account Tyoe
   * @param leadRecord Lead record for conversion
   * @return relatedAccountType
   */
  @testVisible
  private static String getRelatedAccountType(Lead leadRecord) {
    if (leadRecord.FinServ__RelatedAccount__c == null) {
      return '';
    }
    return RELATED_ACCOUNT_MAP.get(
      leadRecord.FinServ__RelatedAccount__r.RecordType.DeveloperName
    ) ?? IS_INVALID;
  }

  /**
   * @param record Lead record from lwc component.
   * @return CCRMSearchPartyInfo for lwc
   * @description called from lead conversion lwc component
   */
  @AuraEnabled(cacheable=false)
  public static CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper searchPartyInfoLWC(
    Lead record
  ) {
    CCRMSearchPartyModel result;
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper searchPartyWrapper;
    Set<String> externalIds = new Set<String>();
    try {
      result = ccrmapi.searchPartyInfo(record);
      externalIds.addAll(populateExternalIds(result.certifiedResults));
      externalIds.addAll(populateExternalIds(result.probableResults));
      searchPartyWrapper = populatePartyDetails(externalIds, result);
    } catch (Exception e) {
      Logger.error('Error occured during search', record.Id, e);
      Logger.saveLog();
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
  public static CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper populatePartyDetails(
    Set<String> externalIds,
    CCRMSearchPartyModel result
  ) {
    CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper searchPartyWrapper = new CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfoWrapper();
    searchPartyWrapper.probableAndCertifiedResults = new List<CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo>();
    Map<String, Account> accountIdMap = (Map<String, Account>) ListUtil.mapBy(
      LEADCONV_REPOSITORY.getAccountUsingExternalIds(externalIds),
      Account.External_Id__c
    );
    searchPartyWrapper.probableAndCertifiedResults.addAll(
      populateSearchPartyWrapper(
        result.certifiedResults,
        accountIdMap,
        'certified'
      )
    );
    searchPartyWrapper.probableAndCertifiedResults.addAll(
      populateSearchPartyWrapper(
        result.probableResults,
        accountIdMap,
        'probable'
      )
    );
    return searchPartyWrapper;
  }

  /**
   * @param searchPartyResultList search party list of result from the API, either certified or probable result
   * @param accountIdMap map of accounts with key as external id
   * @param resultType type of result - cer
   * @return CCRMSearchPartyInfo returns search party wrapper for lwc component
   * @description populates search party wrapper used in lwc component
   */
  private static List<CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo> populateSearchPartyWrapper(
    List<CCRMSearchPartyModel.CustomerDetails> searchPartyResultList,
    Map<String, Account> accountIdMap,
    String resultType
  ) {
    List<CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo> searchPartyInfoList = new List<CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo>();
    for (
      CCRMSearchPartyModel.CustomerDetails searchPartyResult : searchPartyResultList
    ) {
      String externalId = generateExternalId(searchPartyResult);
      if (!accountIdMap.containsKey(externalId)) {
        continue;
      }
      CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo rec = new CCRMSearchPartyInformationWrapper.CCRMSearchPartyInfo();
      rec.id = accountIdMap.get(externalId).Id;
      rec.ocvId = searchPartyResult.ocvId;
      rec.name = accountIdMap.get(externalId).Name;
      rec.suburb = searchPartyResult.addresses != null
        ? searchPartyResult.addresses[0].city
        : null;
      rec.postCode = searchPartyResult.addresses != null
        ? searchPartyResult.addresses[0].postalCode
        : null;
      rec.cpid = searchPartyResult.cpId;
      rec.kycStatus = searchPartyResult.kycDetails?.status;
      rec.match = resultType;
      searchPartyInfoList.add(rec);
    }
    return searchPartyInfoList;
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
   * @return new oportunity id
   */
  @AuraEnabled(cacheable=false)
  public static String createPartyLWC(Lead record) {
    CCRMCreatePartyModel result;
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    try {
      result = ccrmapi.createParty(record);
      LeadConversionHelper.updateLeadWithCapcisIdOrg(record, result);
      Account accInstance = LeadConversionHelper.autoCreateShellProspectForCCRM(
        record,
        result
      );
      validateAccount(accInstance, record);
      return convertLead(accInstance.Id, record);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description called from lead conversion lwc component
   * @name convertLeadNTB
   * @param record Lead record from lwc component.
   * @return MaintainPartyResult new oportunity id
   */
  @AuraEnabled(cacheable=false)
  public static MaintainPartyInformationWrapper.MaintainPartyResult convertLeadNTB(
    Lead record
  ) {
    MaintainPartyModel result;
    PartyAPIRepository partyApi = new PartyAPIRepository();
    MaintainPartyInformationWrapper.MaintainPartyResult maintainResult = new MaintainPartyInformationWrapper.MaintainPartyResult();
    OCVRequestPayloadWrapper requestRecord = LeadConversionHelper.getRequestRecord(
      record
    );
    maintainResult.oppID = '';
    try {
      result = partyApi.maintainParty(requestRecord);
      validateResponse(result, record);
      Boolean shellProspectRequired = false;
      String externalId;
      ShellProspectInfoWrapper shellProspectInfoInstance;
      if (result.newCustomer == 'false') {
        shellProspectInfoInstance = LeadConversionHelper.getMaintainPartyInfo(
          result
        );
        externalId = getExternalId(shellProspectInfoInstance);
        maintainResult = LeadConversionHelper.populateMaintainPartyDetails(
          externalId,
          shellProspectInfoInstance,
          requestRecord
        );
        if (!maintainResult.matchedResults.isEmpty()) {
          return maintainResult;
        }
        shellProspectRequired = true;
        maintainResult.retrievePartyRequired = true;
      }
      Account accInstance;
      // is a shell prospect need to be created?
      if ((result.newCustomer == 'true') || shellProspectRequired) {
        accInstance = LeadConversionHelper.autoCreateShellProspect(
          requestRecord,
          result
        );
        validateAccount(accInstance, record);
      }
      if (record.RecordTypeId == RTLead.mlcrmLead) {
        CustomerRelationNotesTriggerActions.CustomerRelationshipCreator custRelationCreator = new CustomerRelationNotesTriggerActions.CustomerRelationshipCreator();
        custRelationCreator.createCustomerRelationship(
          accInstance.Id,
          requestRecord
        );
      }
      if (result.newCustomer == 'true') {
        Lead leadRecord = LeadConversionHelper.updateLeadWithMaintainPartyInfo(
          accInstance.Id,
          result.sourceSystems[0].sourceSystemId,
          record
        );
        leadConverionFlow = true;
        Boolean isLeadUpdated = LeadConversionHelper.updateLead(leadRecord);
        if (!isLeadUpdated) {
          return maintainResult;
        }
        //convert the lead for new prospect Customer
        String opptId = convertLead(accInstance.Id, record);
        maintainResult.oppID = opptId;
        maintainResult.isNewCustomer = true;
      } else {
        //fetch the customer information for matched existing customer after shell prospect creation
        maintainResult = LeadConversionHelper.populateMaintainPartyDetails(
          externalId,
          shellProspectInfoInstance,
          requestRecord
        );
        maintainResult.retrievePartyRequired = true;
        maintainResult.isNewCustomer = false;
      }
      return maintainResult;
    } catch (CustomException e) {
      Logger.error(e.getMessage() + record.Id);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Convert CCRM Lead
   * @name convertLead
   * @param accId get account id created/matched for lead conversion
   * @param leadRec The Lead records created/matched for lead conversion
   * @return string  opportunity id created/matched for lead conversion
   */
  @AuraEnabled(cacheable=false)
  public static String convertLead(String accId, Lead leadRec) {
    if (String.isBlank(accId)) {
      throw new AuraHandledException(
        Label.MLCRM_AccountBlank_LeadConversionError
      );
    }
    try {
      if (
        !leadConverionFlow &&
        leadRec.RecordType.DeveloperName == MLCRM_LEAD_RECORDTYPE_NAME
      ) {
        //Added to bypass validation rule preventEditShellProspect on Account Trigger (Error: Label.ML_ShellProspect_Update_ErrorMessage)
        manualLeadConversionInitiated = true;
        CustomerRelationNotesTriggerActions.CustomerRelationshipCreator custRelationCreator = new CustomerRelationNotesTriggerActions.CustomerRelationshipCreator();
        custRelationCreator.createCustomerRelationship(
          accId,
          LeadConversionHelper.getRequestRecord(leadRec)
        );
      }
      leadConverionFlow = true;
      // Convert lead
      Map<Id, Id> mapLeadwithOpportunityId = LeadConversionOperations.convertLead(
        ID.valueOf(accId),
        leadRec
      );
      return mapLeadwithOpportunityId.get(leadRec.Id) ?? null;
    } catch (Exception ex) {
      Logger.error('Error occured during lead conversion', leadRec.Id, ex);
      Logger.saveLog();
      throw new AuraHandledException(ex.getMessage());
    }
  }

  /**
   * @description Convert MLCRM Lead for matched maintain party Existing Customer
   * @name convertLeadWithMatchedParty
   * @param accId get account id matched for lead conversion
   * @param capId get capId from ocv reponse
   * @param leadRec The Lead record to convert
   * @return string  opportunity id created from lead conversion
   */
  @AuraEnabled(cacheable=false)
  public static String convertLeadWithMatchedParty(
    String accId,
    String capId,
    Lead leadRec
  ) {
    if (String.isBlank(accId)) {
      throw new AuraHandledException(
        Label.MLCRM_AccountBlank_LeadConversionError
      );
    }
    if (String.isBlank(capId)) {
      throw new AuraHandledException(
        Label.MLCRM_CAPCISIdBlank_LeadConversionError
      );
    }
    try {
      Lead leadRecord = LeadConversionHelper.updateLeadWithMaintainPartyInfo(
        accId,
        capId,
        leadRec
      );

      if (leadRec.RecordTypeId == RTLead.mlcrmLead) {
        CustomerRelationNotesTriggerActions.CustomerRelationshipCreator custRelationCreator = new CustomerRelationNotesTriggerActions.CustomerRelationshipCreator();
        custRelationCreator.createCustomerRelationship(
          accId,
          LeadConversionHelper.getRequestRecord(leadRec)
        );
      }
      leadConverionFlow = true;
      //Added to bypass validation rule preventEditShellProspect on Account Trigger (Error: Label.ML_ShellProspect_Update_ErrorMessage)
      manualLeadConversionInitiated = true;
      Boolean isLeadUpdated = LeadConversionHelper.updateLead(leadRecord);
      if (!isLeadUpdated) {
        return null;
      }
      // Convert lead
      Map<Id, Id> mapLeadwithOpportunityId = LeadConversionOperations.convertLead(
        ID.valueOf(accId),
        leadRec
      );
      return mapLeadwithOpportunityId.get(leadRec.Id) ?? null;
    } catch (Exception ex) {
      Logger.error(eX.getMessage() + leadRec.Id);
      Logger.saveLog();
      throw new AuraHandledException(ex.getMessage());
    }
  }

  /**
   * @description Checks if Lead details is mis-match with Customer details
   * @name isLeadMisMatchCustomer
   * @param recordId The record id of selected Lead.
   * @return String The Fields which are mismatched
   */
  @AuraEnabled(cacheable=false)
  public static String isLeadMisMatchCustomer(Id recordId) {
    try {
      if (recordId == null) {
        return null;
      }
      Lead leadRecord = LEADCONV_REPOSITORY.getLeadsWithCustomerDetails(
        recordId
      );
      if (
        leadRecord == null ||
        leadRecord.FinServ__RelatedAccount__c == null ||
        leadRecord.FinServ__RelatedAccount__r.OCV_Event_Version__c == 0
      ) {
        return null;
      }
      Map<Id, String> mismtachLeadsWithFieldsMap = AutoTaskOnLeadConversionHelper.checkLeadMisMatchCustomer(
        leadRecord
      );
      if (mismtachLeadsWithFieldsMap.containsKey(recordId)) {
        return mismtachLeadsWithFieldsMap.get(recordId);
      }
      return null;
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      return null;
    }
  }

  /**
   * @description get the external Id
   * @name getExternalId
   * @param infoWrapper resonse in form of ShellProspectInfoWrapper
   * @return String  as concatination of sourceSystemName and sourceSystemId
   */
  public static String getExternalId(ShellProspectInfoWrapper infoWrapper) {
    return infoWrapper.sourceSystemName + '_' + infoWrapper.sourceSystemId;
  }

  /**
   * @description validate response and raise error
   * @name validateResponse
   * @param result reponse result from maintain Party Call
   * @param record Lead record
   */
  @testVisible
  private static void validateResponse(MaintainPartyModel result, Lead record) {
    if (result.newCustomer == null) {
      // Throw custom exception
      LeadConversionHelper.handleError(
        Label.MLCRM_MaintainParty_NewCustomerError,
        record.Id
      );
    }
    if (result.ocvId == null) {
      // Throw custom exception
      LeadConversionHelper.handleError(
        Label.MLCRM_CAPCISIdBlank_LeadConversionError,
        record.Id
      );
    }
  }
  /**
   * @description validate account and raise error
   * @name validateAccount
   * @param accountRecord shell prospect account record created in response of maintain party
   * @param record Lead record
   */
  @testVisible
  private static void validateAccount(Account accountRecord, Lead record) {
    if (accountRecord == null) {
      // Throw custom exception
      LeadConversionHelper.handleError(ACCOUNT_CREATION_ERROR, record.Id);
    }
  }

  /**
   * @description make retrieve party API
   * @name retrieveParty
   * @param accId prospect record Id
   */
  @AuraEnabled(cacheable=false)
  public static void retrieveParty(Id accId) {
    Account objAcc = ACCOUNT_REPOSITORY.getCurrentAccountById(accId);
    PartyAPIRepository partyApi = new PartyAPIRepository();
    OCVRetrievePartyPayloadWrapper requestRecord = LeadConversionHelper.getRequestRecordForRetrieveParty(
      objAcc
    );
    try {
      partyApi.retrieveParty(requestRecord);
    } catch (Exception e) {
      Logger.error('Error occured during retrieve party', objAcc.Id, e);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
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
}
