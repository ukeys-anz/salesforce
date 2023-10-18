/**
 * @author Ankit Garg
 * @since  06/2023
 * @description CCRM lead conversion helper actions which includes calling search and create party api, deleting auto created contacts post conversion
 */
public with sharing class CCRMLeadConversionActionsHelper {
  private static final String INSUFFICIANT_PERMISSION_ERROR = 'Insufficiant Permission to update Lead';
  private static final String CAPCIS_LEAD_UPDATE_ERROR = 'Error occured while updating lead record during conversion.';
  private static final String INDIVIDUAL = 'Individual';
  private static final String OCV_USER_ERROR = 'Error occured while fetching OCV Integration User.';
  private static final String SHELL_PROSPECT_CREATION_ERROR = 'Error occured while shell prospect creation during maintain Party callout :';
  private static final String CUSTOMER_RELATIONSHIP_CREATION_ERROR = 'Error occured while creating Customer Relationship during maintain Party callout :';
  private static final String EXISTING_CUSTOMER_NOT_FOUND_ERROR = 'Cannot found Existing Customer in Salesforce with ExternalId: ';
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description Updates lead with capcis id which will be used in Account trigger handler
   * @name updateLeadWithCapcisIdIndividual
   * @param record Lead record from lwc component.
   * @param response result from cap api response
   * @param accountInstance Account record
   * @return String opportunityId
   */
  public static String updateLeadWithCapcisIdIndividual(
    Lead record,
    DCRMMaintainPartyModel response,
    Account accountInstance
  ) {
    if (
      !(Schema.sObjectType.Lead.isUpdateable() &&
      Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable() &&
      Schema.sObjectType.Lead.fields.FinServ__RelatedAccount__c.isUpdateable() &&
      Schema.sObjectType.Lead.fields.CAPCIS_ID__c.isUpdateable())
    ) {
      Logger.error(INSUFFICIANT_PERMISSION_ERROR + record.Id);
      Logger.saveLog();
      // Throw custom exception
      throw new CustomException(INSUFFICIANT_PERMISSION_ERROR);
    }
    String opportunityId;
    ShellProspectCreator prospectCreator = new ShellProspectCreator();
    if (accountInstance != null && accountInstance.Id != null) {
      record.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      record.FinServ__RelatedAccount__c = accountInstance.id;
      record.CAPCIS_ID__c = response.sourceSystems[0].sourceSystemId;
      CCRMLeadConversionActions.leadConverionFlow = true;
      Boolean isLeadUpdated = prospectCreator.updateLead(record);
      if (isLeadUpdated) {
        String opptId = CCRMLeadConversionActions.convertCCRMLead(
          accountInstance.Id,
          record
        );
        opportunityId = opptId;
      }
    }
    return opportunityId;
  }

  /**
   * @description populate party details and return to lwc component
   * @param externalId unique ids to query from salesforce database
   * @param response response data from callout
   * @param record lead record
   * @return MaintainPartyInfoWrapper for lwc
   */
  public static MaintainPartyInformationWrapper.MaintainPartyInfoWrapper populateMaintainPartyDetails(
    String externalId,
    ShellProspectInfoWrapper response,
    OCVRequestPayloadWrapper record
  ) {
    MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainPartyWrapper = new MaintainPartyInformationWrapper.MaintainPartyInfoWrapper();
    maintainPartyWrapper.matchedResults = new List<MaintainPartyInformationWrapper.MaintainPartyInfo>();
    Map<String, Account> accountIdMap = new Map<String, Account>();
    for (Account acc : [
      SELECT Id, External_Id__c, Name, FinServ__KYCStatus__c, CLG__c
      FROM Account
      WHERE External_Id__c = :externalId
      WITH SECURITY_ENFORCED
    ]) {
      accountIdMap.put(acc.External_Id__c, acc);
    }
    if (accountIdMap.containsKey(externalId)) {
      MaintainPartyInformationWrapper.MaintainPartyInfo rec = new MaintainPartyInformationWrapper.MaintainPartyInfo();
      rec.id = accountIdMap.get(externalId).Id;
      rec.name = accountIdMap.get(externalId).Name;
      rec.address =
        record?.strStreet +
        ', ' +
        record?.strCity +
        ' ' +
        record?.strState +
        ' ' +
        record?.strCountry +
        ' ' +
        record?.strPostalCode;
      rec.clgId = accountIdMap.get(externalId).CLG__c;
      rec.cpid = response.sourceSystemId;
      rec.kycStatus = accountIdMap.get(externalId).FinServ__KYCStatus__c;
      rec.sourceSystem = response.sourceSystemName;
      rec.ocvId = response.ocvId;
      maintainPartyWrapper.matchedResults.add(rec);
    }
    return maintainPartyWrapper;
  }

  /**
   * @description Updates lead with capcis id which will be used in Account trigger handler
   * @name updateLeadWithMaintainPartyInfo
   * @param accId Account id matched with ocv api response
   * @param capcisId capcis id from ocv api response
   * @param record Lead record from lwc component.
   * @return Boolean isUpdated as true if lead updated sucessfully
   */
  public static Boolean updateLeadWithMaintainPartyInfo(
    String accId,
    String capcisId,
    Lead record
  ) {
    Boolean isUpdated = false;
    if (
      Schema.sObjectType.Lead.isUpdateable() &&
      Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable() &&
      Schema.sObjectType.Lead.fields.FinServ__RelatedAccount__c.isUpdateable() &&
      Schema.sObjectType.Lead.fields.CAPCIS_ID__c.isUpdateable()
    ) {
      record.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      record.CAPCIS_ID__c = capcisId;
      record.FinServ__RelatedAccount__c = accId;
      CCRMLeadConversionActions.leadConverionFlow = true;
      ShellProspectCreator prospectCreator = new ShellProspectCreator();
      isUpdated = prospectCreator.updateLead(record);
    } else {
      // Throw custom exception
      handleError(INSUFFICIANT_PERMISSION_ERROR, record.Id);
    }
    return isUpdated;
  }

  /**
   * @description Updates lead with capcis id which will be used in Account trigger handler
   * @name updateLeadWithCapcisIdOrg
   * @param record Lead record from lwc component.
   * @param response result from cap api response
   * @return new oportunity id
   */
  public static String updateLeadWithCapcisIdOrg(
    Lead record,
    CCRMCreatePartyModel response
  ) {
    Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
    String recordTypeId = '';
    if (
      Schema.sObjectType.Lead.isUpdateable() &&
      Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable() &&
      Schema.sObjectType.Lead.fields.CAPCIS_ID__c.isUpdateable()
    ) {
      record.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      record.CAPCIS_ID__c = response.capcisId;
      Database.SaveResult result = Database.update(record, false);
      if (!result.isSuccess()) {
        handleError(CAPCIS_LEAD_UPDATE_ERROR, record.Id);
      }
      recordTypeId = (record.Entity_Type__c != null &&
        record.Entity_Type__c.equalsIgnoreCase(INDIVIDUAL))
        ? CCRMConstants.ACCOUNT_PERSON_RT_ID
        : CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
      ShellProspectInfoWrapper shellProspectInfoInstance = getCreatePartyInfo(
        response
      );
      //transform api result to wrapper instance
      ShellProspectCreator prospectCreator = new ShellProspectCreator();
      OCVRequestPayloadWrapper reqRecord = new OCVRequestPayloadWrapper();
      reqRecord.strRecordId = record.Id;
      Account accountInstance = prospectCreator.createShellProspect(
        shellProspectInfoInstance,
        recordTypeId,
        reqRecord
      );
      return CCRMLeadConversionActions.convertCCRMLead(
        accountInstance.Id,
        record
      );
    }
    // Throw custom exception
    throw new CustomException(CAPCIS_LEAD_UPDATE_ERROR);
  }

  /**
   * @description Create Party Shell Prospect Info population
   * @name getCreatePartyInfo
   * @param response get CreateParty response
   * @return ShellProspectInfoWrapper trasform response to wrapper instance
   */
  private static ShellProspectInfoWrapper getCreatePartyInfo(
    CCRMCreatePartyModel response
  ) {
    ShellProspectInfoWrapper shellProspectInfoInstance = new ShellProspectInfoWrapper();
    shellProspectInfoInstance.sourceSystemId = response.capcisId;
    shellProspectInfoInstance.sourceSystemName = CCRMConstants.SOURCE_SYSTEM_NAME;
    shellProspectInfoInstance.ocvId = response.customerId;
    shellProspectInfoInstance.name = response.customerName;
    shellProspectInfoInstance.isIndividual = false;
    return shellProspectInfoInstance;
  }

  /**
   * @description Maintain Party Shell Prospect Info population
   * @name getMaintainPartyInfo
   * @param response  Maintain Party API response
   * @return ShellProspectInfoWrapper trasform response to wrapper instance
   */
  private static ShellProspectInfoWrapper getMaintainPartyInfo(
    DCRMMaintainPartyModel response
  ) {
    ShellProspectInfoWrapper shellProspectInfoInstance = new ShellProspectInfoWrapper();
    shellProspectInfoInstance.sourceSystemId = response.sourceSystems[0]
      .sourceSystemId;
    shellProspectInfoInstance.sourceSystemName = response.sourceSystems[0]
      .sourceSystemName;
    shellProspectInfoInstance.ocvId = String.valueOf(response.ocvId);
    shellProspectInfoInstance.profileIds = response.profileIds;
    shellProspectInfoInstance.name = '';
    shellProspectInfoInstance.isIndividual = true;
    return shellProspectInfoInstance;
  }
  /**
   * @description error handler
   * @name handleError
   * @param errorMessage error message to log and create UI exception
   * @param leadId Lead Record Id
   */
  public static void handleError(String errorMessage, String leadId) {
    Logger.error(errorMessage + leadId);
    Logger.saveLog();
    // Throw custom exception
    throw new CustomException(errorMessage);
  }

  /**
   * @description Wrapper class to store create/maintain party info
   */
  private class ShellProspectInfoWrapper {
    private string sourceSystemName;
    private string sourceSystemId;
    private String ocvId;
    private List<string> profileIds;
    private string name;
    private Boolean isIndividual;
  }

  /**
   * @description private without sharing class to bypass user sharing setting in lead conversion process
   */
  private without sharing class ShellProspectCreator {
    /**
     * @description fetch ocv user
     * @name getOCVUser
     * @return List<User> fetching OCV user
     */
    private List<User> getOCVUser() {
      if (Schema.sObjectType.User.isQueryable()) {
        return [
          SELECT Id
          FROM USER
          WHERE Username = :System.Label.CCRM_OCVIntegrationUsername
        ];
      }
      return null;
    }

    /**
     * @description update leadRecord in system Context as new shell prospect account owner is ocv user.
     * @name updateLead
     * @param record lead record
     * @return Boolean isUpdated as true if lead updated sucessfully
     */
    private Boolean updateLead(Lead record) {
      Database.SaveResult result = Database.update(record, false);
      if (result.isSuccess()) {
        return true;
      } else {
        handleError(CAPCIS_LEAD_UPDATE_ERROR, record.Id);
      }
      return false;
    }

    /**
     * @description create shell prospect after receiving response from cap API
     * @name createShellProspect
     * @param shellProspectInfoInstance result from cap api response transformed into CustomerInfo wrapper
     * @param recordTypeId recordtype id of shell prospect
     * @param reqRecord source SObject record i.e lead, Opportunity
     * @return shell prospect created for lead conversion
     */
    private Account createShellProspect(
      ShellProspectInfoWrapper shellProspectInfoInstance,
      String recordTypeId,
      OCVRequestPayloadWrapper reqRecord
    ) {
      Account shellProspectToInsert = new Account();
      List<User> userList = new List<User>();
      userList = getOCVUser();
      if (userList.isEmpty()) {
        handleError(OCV_USER_ERROR, reqRecord.strRecordId);
      }
      shellProspectToInsert = new Account();
      shellProspectToInsert.Source_System_ID__c = shellProspectInfoInstance.sourceSystemId;
      shellProspectToInsert.Source_System_Name__c = shellProspectInfoInstance.sourceSystemName;
      if (shellProspectInfoInstance.isIndividual) {
        shellProspectToInsert.FirstName = reqRecord.strFirstName;
        shellProspectToInsert.LastName = reqRecord.strLastName;
        shellProspectToInsert.MiddleName = reqRecord.strMiddleName;
      } else {
        shellProspectToInsert.Name = shellProspectInfoInstance.name;
      }
      shellProspectToInsert.FinServ__Status__c = CCRMConstants.PROSPECT;
      shellProspectToInsert.RecordTypeId = recordTypeId;
      shellProspectToInsert.OCV_Event_Version__c = Integer.valueOf(
        System.Label.DCRM_OCVEventVersion
      );
      shellProspectToInsert.External_Id__c =
        shellProspectInfoInstance.sourceSystemName +
        '_' +
        shellProspectInfoInstance.sourceSystemId;
      //remove when the field is set to optional
      shellProspectToInsert.OCV_ID__c = shellProspectInfoInstance.ocvId;
      shellProspectToInsert.OwnerId = userList[0].Id;
      CCRMLeadConversionActions.manualLeadConversionInitiated = true;
      Database.SaveResult result = Database.insert(
        shellProspectToInsert,
        false
      );
      if (!result.isSuccess()) {
        handleError(
          SHELL_PROSPECT_CREATION_ERROR + result.getErrors()[0].getMessage(),
          reqRecord.strRecordId
        );
      }
      return shellProspectToInsert;
    }

    /**
     * @description CC-2175 create CustomerRelationship against shell prospect after receiving response from cap API
     * @name createCustomerRelationship
     * @param shellProspectAccount shell prospect created after response from cap ocv maintain party API.
     * @param reqRecord source SObject record i.e lead, Opportunity
     */
    private void createCustomerRelationship(
      Account shellProspectAccount,
      OCVRequestPayloadWrapper reqRecord
    ) {
      ID recordId = ID.valueOf(reqRecord.strRecordId);
      List<Customer_Relationship__c> lstOfPrimaryNotes;
      String recordQuery = 'Select Id, Territory__c,Territory__r.Primary_Franchise_Owner__c From ';
      List<SObject> records = new List<SObject>();
      if (
        recordId.getSObjectType().getDescribe().getName() ==
        MLCRMConstants.SOBJECT_LEAD
      ) {
        recordQuery += 'Lead WHERE Id = :recordId';
      } else if (
        recordId.getSObjectType().getDescribe().getName() ==
        MLCRMConstants.SOBJECT_OPPORTUNITY
      ) {
        recordQuery += 'Opportunity WHERE Id = :recordId';
      }
      records = database.query(recordQuery);
      Customer_Relationship__c objRelation = new Customer_Relationship__c();
      objRelation.Preferred_Name__c =
        reqRecord?.strFirstName +
        ' ' +
        reqRecord?.strLastName;
      if (!String.isBlank(reqRecord.strMiddleName)) {
        objRelation.Preferred_Name__c += ' ' + reqRecord.strMiddleName;
      }
      objRelation.Customer__c = shellProspectAccount.Id;
      if (!records.isEmpty()) {
        objRelation.Territory__c = (ID) records[0].get('Territory__c');
      }
      if (
        !records.isEmpty() &&
        records[0]
          .getSobject('Territory__r')
          ?.get('Primary_Franchise_Owner__c') != null
      ) {
        Id strPrimaryOwnerId = (Id) records[0]
          .getSobject('Territory__r')
          ?.get('Primary_Franchise_Owner__c');
        lstOfPrimaryNotes = [
          SELECT Id
          FROM Customer_Relationship__c
          WHERE
            Relationship_To_Franchise__c = 'Primary'
            AND Territory__r.Primary_Franchise_Owner__c = :strPrimaryOwnerId
          LIMIT 1
        ];
      }
      objRelation.OwnerId = reqRecord.strOwnerId;
      objRelation.Relationship_To_Franchise__c = lstOfPrimaryNotes != null &&
        !lstOfPrimaryNotes.isEmpty()
        ? MLCRMConstants.SECONDARY
        : MLCRMConstants.PRIMARY;
      objRelation.Date_Relationship_Commenced__c = System.today();
      Database.SaveResult result = Database.insert(objRelation, false);
      if (!result.isSuccess()) {
        handleError(
          CUSTOMER_RELATIONSHIP_CREATION_ERROR +
          result.getErrors()[0].getMessage(),
          reqRecord.strRecordId
        );
      }
    }
  }

  /**
   * @description create shell prospect after receiving response from CAP API
   * @name autoCreateShellProspect
   * @param reqRecord Lead record in the form of OCVRequestPayloadWrapper.
   * @param response result from cap api response
   * @return MaintainPartyInfoWrapper
   */
  public static Account autoCreateShellProspect(
    OCVRequestPayloadWrapper reqRecord,
    DCRMMaintainPartyModel response
  ) {
    String recordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
    Account accountInstance;
    ShellProspectCreator prospectCreator = new ShellProspectCreator();
    ShellProspectInfoWrapper shellProspectInfoInstance = getMaintainPartyInfo(
      response
    );
    accountInstance = prospectCreator.createShellProspect(
      shellProspectInfoInstance,
      recordTypeId,
      reqRecord
    );
    prospectCreator.createCustomerRelationship(accountInstance, reqRecord);
    return accountInstance;
  }

  /**
   * @description create shell prospect after receiving response from CAP API
   * @name getMaintainPartyExistingCustomerDetails
   * @param reqRecord Lead record in the form of OCVRequestPayloadWrapper.
   * @param response result from cap api response
   * @return MaintainPartyInfoWrapper
   */
  public static MaintainPartyInformationWrapper.MaintainPartyInfoWrapper getMaintainPartyExistingCustomerDetails(
    OCVRequestPayloadWrapper reqRecord,
    DCRMMaintainPartyModel response
  ) {
    MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainPartyWrapper = new MaintainPartyInformationWrapper.MaintainPartyInfoWrapper();
    ShellProspectCreator prospectCreator = new ShellProspectCreator();
    ShellProspectInfoWrapper shellProspectInfoInstance = getMaintainPartyInfo(
      response
    );
    String externalId =
      shellProspectInfoInstance.sourceSystemName +
      '_' +
      shellProspectInfoInstance.sourceSystemId;
    try {
      maintainPartyWrapper.oppID = '';
      maintainPartyWrapper = populateMaintainPartyDetails(
        externalId,
        shellProspectInfoInstance,
        reqRecord
      );
      if (
        maintainPartyWrapper.matchedResults == null ||
        maintainPartyWrapper.matchedResults.isEmpty()
      ) {
        // Throw custom exception
        handleError(
          EXISTING_CUSTOMER_NOT_FOUND_ERROR + externalId,
          reqRecord.strRecordId
        );
      }
      maintainPartyWrapper.isNewCustomer = false;
    } catch (Exception e) {
      Logger.error(e.getMessage() + reqRecord.strRecordId);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
    return maintainPartyWrapper;
  }

  /**
   * @description payload request to OCV
   * @name getRequestRecord
   * @param record Lead record from lwc component.
   * @return ocvRequest as OCVRequestPayloadWrapper
   */
  public static OCVRequestPayloadWrapper getRequestRecord(Lead record) {
    OCVRequestPayloadWrapper ocvRequest = new OCVRequestPayloadWrapper();
    ocvRequest.strOwnerId = record.ownerid;
    ocvRequest.isValidStreet = record.Is_Valid_Address__c;
    ocvRequest.strStreet = record.Street;
    ocvRequest.strCity = record.City;
    ocvRequest.strState = record.State;
    ocvRequest.strCountry = record.Country;
    ocvRequest.strPostalCode = record.PostalCode;
    ocvRequest.strMobilePhone = record.MobilePhone;
    ocvRequest.strHomePhone = record.Home_Phone__c;
    ocvRequest.strWorkPhone = record.Work_Phone__c;
    ocvRequest.strEmail = record.Email;
    ocvRequest.strSalutation = record.Salutation;
    ocvRequest.strFirstName = record.FirstName;
    ocvRequest.strMiddleName = record.MiddleName;
    ocvRequest.strLastName = record.LastName;
    ocvRequest.strGender = record.Gender__c;
    ocvRequest.strRecordId = record.Id;
    return ocvRequest;
  }
}
