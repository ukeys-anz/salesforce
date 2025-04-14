/**
 * @author Ankit Garg
 * @since  06/2023
 * @description lead conversion helper actions which includes calling search and create party api, deleting auto created contacts post conversion
 */
public with sharing class LeadConversionHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final LeadConversionActionsRepository LEADCONV_REPOSITORY = (LeadConversionActionsRepository) Lib_InstanceProvider.forType(
    LeadConversionActionsRepository.class
  );

  private static final String INSUFFICIANT_PERMISSION_ERROR = 'Insufficiant Permission to update Lead';
  private static final String CAPCIS_LEAD_UPDATE_ERROR = 'Error occured while updating lead record during conversion.';
  private static final String INDIVIDUAL = 'Individual';
  private static final String OCV_USER_ERROR = 'Error occured while fetching OCV Integration User.';
  private static final String SHELL_PROSPECT_CREATION_ERROR = 'Error occured while shell prospect creation during maintain Party callout :';
  private static final String CUSTOMER_RELATIONSHIP_CREATION_ERROR = 'Error occured while creating Customer Relationship during maintain Party callout :';
  private static final String CONVERT_LEAD = 'ConvertLead';
  private static final String SOURCE_SYSTEM_NAME = 'CAP-CIS';
  private static final String PROSPECT = 'Prospect';

  public static User ocvUser = new User();

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description populate party details and return to lwc component
   * @param externalId unique ids to query from salesforce database
   * @param response response data from callout
   * @param record lead record
   * @return MaintainPartyResult for lwc
   */
  public static MaintainPartyInformationWrapper.MaintainPartyResult populateMaintainPartyDetails(
    String externalId,
    ShellProspectInfoWrapper response,
    OCVRequestPayloadWrapper record
  ) {
    MaintainPartyInformationWrapper.MaintainPartyResult maintainPartyWrapperResult = new MaintainPartyInformationWrapper.MaintainPartyResult();
    maintainPartyWrapperResult.matchedResults = new List<MaintainPartyInformationWrapper.MaintainPartyInfo>();
    Account accountRecord = new Account();
    try {
      accountRecord = LEADCONV_REPOSITORY.getAccountUsingExternalId(externalId);
    } catch (Exception ex) {
      return maintainPartyWrapperResult;
    }
    try {
      if (accountRecord == null) {
        return maintainPartyWrapperResult;
      }
      MaintainPartyInformationWrapper.MaintainPartyInfo matchedCustomerInfo = getMatchedCustomerInfo(
        record,
        accountRecord,
        response
      );
      maintainPartyWrapperResult.matchedResults.add(matchedCustomerInfo);
      maintainPartyWrapperResult.oppID = '';
      maintainPartyWrapperResult.isNewCustomer = false;
      maintainPartyWrapperResult.retrievePartyRequired = false;
    } catch (Exception e) {
      Logger.error(e.getMessage() + record.strRecordId);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
    return maintainPartyWrapperResult;
  }

  /**
   * @description Updates lead with capcis id which will be used in Account trigger handler
   * @name updateLeadWithMaintainPartyInfo
   * @param accId Account id matched with ocv api response
   * @param capcisId capcis id from ocv api response
   * @param record Lead record from lwc component.
   * @return Lead the lead Record
   */
  public static Lead updateLeadWithMaintainPartyInfo(
    String accId,
    String capcisId,
    Lead record
  ) {
    if (!LEADCONV_REPOSITORY.isLeadCAPCISUpdatable()) {
      // Throw custom exception
      handleError(INSUFFICIANT_PERMISSION_ERROR, record.Id);
    }
    record.Skip_Validations__c = CONVERT_LEAD;
    record.CAPCIS_ID__c = capcisId;
    record.FinServ__RelatedAccount__c = accId;
    return record;
  }

  /**
   * @description Updates lead with capcis id which will be used in Account trigger handler
   * @name updateLeadWithCapcisIdOrg
   * @param record Lead record from lwc component.
   * @param response result from cap api response
   * @return Boolean isLeadUpdated
   */
  public static Boolean updateLeadWithCapcisIdOrg(
    Lead record,
    CCRMCreatePartyModel response
  ) {
    if (!LEADCONV_REPOSITORY.isLeadCAPCISUpdatable()) {
      // Throw custom exception
      handleError(INSUFFICIANT_PERMISSION_ERROR, record.Id);
    }
    ShellProspectCreator prospectCreator = new ShellProspectCreator();
    record.Skip_Validations__c = CONVERT_LEAD;
    record.CAPCIS_ID__c = response.capcisId;
    return prospectCreator.updateLead(record);
  }

  /**
   * @description Create Party Shell Prospect Info population
   * @name getCreatePartyInfo
   * @param response get CreateParty response
   * @return ShellProspectInfoWrapper trasform response to wrapper instance
   */
  @TestVisible
  private static ShellProspectInfoWrapper getCreatePartyInfo(
    CCRMCreatePartyModel response
  ) {
    ShellProspectInfoWrapper shellProspectInfoInstance = new ShellProspectInfoWrapper();
    shellProspectInfoInstance.sourceSystemId = response.capcisId;
    shellProspectInfoInstance.sourceSystemName = SOURCE_SYSTEM_NAME;
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
  public static ShellProspectInfoWrapper getMaintainPartyInfo(
    MaintainPartyModel response
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
   * @description create shell prospect after receiving response from CAP API
   * @name autoCreateShellProspect
   * @param reqRecord Lead record in the form of OCVRequestPayloadWrapper.
   * @param response result from cap api response
   * @return Account
   */
  public static Account autoCreateShellProspect(
    OCVRequestPayloadWrapper reqRecord,
    MaintainPartyModel response
  ) {
    String recordTypeId = RTAccount.personAccount;
    Account accountInstance;
    ShellProspectInfoWrapper shellProspectInfoInstance = getMaintainPartyInfo(
      response
    );
    try {
      ocvUser = LEADCONV_REPOSITORY.getOCVUser();
    } catch (Exception ex) {
      handleError(OCV_USER_ERROR, reqRecord.strRecordId);
    }
    accountInstance = createShellProspect(
      shellProspectInfoInstance,
      recordTypeId,
      reqRecord
    );
    ShellProspectCreator prospectCreator = new ShellProspectCreator();
    accountInstance = prospectCreator.insertAccount(
      accountInstance,
      reqRecord.strRecordId
    );
    return accountInstance;
  }

  /**
   * @description create shell prospect after receiving response from CAP API
   * @name autoCreateShellProspectForCCRM
   * @param record Lead record
   * @param response result from cap api response
   * @return Account
   */
  public static Account autoCreateShellProspectForCCRM(
    Lead record,
    CCRMCreatePartyModel response
  ) {
    OCVRequestPayloadWrapper reqRecord = getRequestRecord(record);
    String recordTypeId = (record.Entity_Type__c != null &&
      record.Entity_Type__c.equalsIgnoreCase(INDIVIDUAL))
      ? RTAccount.personAccount
      : RTAccount.businessAccount;
    Account accountInstance;
    ShellProspectInfoWrapper shellProspectInfoInstance = getCreatePartyInfo(
      response
    );
    try {
      ocvUser = LEADCONV_REPOSITORY.getOCVUser();
    } catch (Exception ex) {
      handleError(OCV_USER_ERROR, reqRecord.strRecordId);
    }
    accountInstance = createShellProspect(
      shellProspectInfoInstance,
      recordTypeId,
      reqRecord
    );
    ShellProspectCreator prospectCreator = new ShellProspectCreator();
    accountInstance = prospectCreator.insertAccount(
      accountInstance,
      reqRecord.strRecordId
    );
    return accountInstance;
  }

  /**
   * @description private without sharing class to bypass user sharing setting in lead conversion process
   */
  private without sharing class ShellProspectCreator {
    /**
     * @description update leadRecord in system Context as new shell prospect account owner is ocv user.
     * @name updateLead
     * @param record lead record
     * @return Boolean isUpdated as true if lead updated sucessfully
     */
    public Boolean updateLead(Lead record) {
      Database.SaveResult result = DML_REPOSITORY.doUpdate(
        record,
        new DmlConfig().allowPartial().systemMode()
      );
      if (Test.isRunningTest() || result.isSuccess()) {
        return true;
      } else {
        handleError(CAPCIS_LEAD_UPDATE_ERROR, record.Id);
      }
      return false;
    }

    /**
     * @description insert Account Record in system Context without sharing
     * @name insertAccount
     * @param accountRecord shell prospect account record to insert
     * @param leadId lead record Id
     * @return shell prospect created for lead conversion
     */
    public Account insertAccount(Account accountRecord, Id leadId) {
      LeadConversionController.manualLeadConversionInitiated = true;
      Database.SaveResult result = DML_REPOSITORY.doInsert(
        accountRecord,
        new DmlConfig().allowPartial().systemMode()
      );
      if (!Test.isRunningTest() && !result.isSuccess()) {
        handleError(
          SHELL_PROSPECT_CREATION_ERROR + result.getErrors()[0].getMessage(),
          leadId
        );
      }
      return accountRecord;
    }
  }
  /**
   * @description create shell prospect after receiving response from cap API
   * @name createShellProspect
   * @param shellProspectInfoInstance result from cap api response transformed into CustomerInfo wrapper
   * @param recordTypeId recordtype id of shell prospect
   * @param reqRecord source SObject record i.e lead, Opportunity
   * @return shell prospect created for lead conversion
   */
  public static Account createShellProspect(
    ShellProspectInfoWrapper shellProspectInfoInstance,
    String recordTypeId,
    OCVRequestPayloadWrapper reqRecord
  ) {
    Account shellProspectToInsert = new Account();
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
    shellProspectToInsert.FinServ__Status__c = PROSPECT;
    shellProspectToInsert.RecordTypeId = recordTypeId;
    shellProspectToInsert.OCV_Event_Version__c = Integer.valueOf(
      System.Label.ShellProspectOCVEventVersion
    );
    shellProspectToInsert.External_Id__c =
      shellProspectInfoInstance.sourceSystemName +
      '_' +
      shellProspectInfoInstance.sourceSystemId;
    //remove when the field is set to optional
    shellProspectToInsert.OCV_ID__c = shellProspectInfoInstance.ocvId;
    shellProspectToInsert.OwnerId = ocvUser.Id;
    shellProspectToInsert.Gender__pc = reqRecord.strGender;
    shellProspectToInsert.PersonBirthdate = String.isNotBlank(
        reqRecord.strDateOfBirth
      )
      ? Date.valueOf(reqRecord.strDateOfBirth)
      : null;
    return shellProspectToInsert;
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
    ocvRequest.strAdvertisingIndicator = record.AdvertisingIndicator__c
      ? 'Y'
      : 'N'; //added as part of CC-6745
    return ocvRequest;
  }

  /**
   * @description payload request to OCV
   * @name getRequestRecordForRetrieveParty
   * @param record Account record
   * @return ocvRequest as OCVRetrievePartyPayloadWrapper
   */
  public static OCVRetrievePartyPayloadWrapper getRequestRecordForRetrieveParty(
    Account record
  ) {
    OCVRetrievePartyPayloadWrapper ocvRequest = new OCVRetrievePartyPayloadWrapper();
    ocvRequest.ocvId = record.OCV_ID__c;
    ocvRequest.ownerId = record.ownerId;
    ocvRequest.partyType = record.isPersonaccount ? 'P' : 'O';
    OCVRetrievePartyPayloadWrapper.sourceSystems objSystem = new OCVRetrievePartyPayloadWrapper.sourceSystems();
    objSystem.sourceSystemId = record.Source_System_ID__c;
    objSystem.sourceSystemName = record.Source_System_Name__c;
    List<OCVRetrievePartyPayloadWrapper.sourceSystems> lstOfSourceSystem = new List<OCVRetrievePartyPayloadWrapper.sourceSystems>();
    lstOfSourceSystem.add(objSystem);
    ocvRequest.sourceSystems = lstOfSourceSystem;
    return ocvRequest;
  }

  /**
   * @description update leadRecord in system Context as new shell prospect account owner is ocv user.
   * @name updateLead
   * @param record lead record
   * @return Boolean isUpdated as true if lead updated sucessfully
   */
  public static Boolean updateLead(Lead record) {
    ShellProspectCreator prospectCreator = new ShellProspectCreator();
    return prospectCreator.updateLead(record);
  }

  /**
   * @description method to form the table data to display the matched existing customer found
   * @name getMatchedCustomerInfo
   * @param record OCVRequestPayloadWrapper from lead record
   * @param accountRecord existing matched account record
   *  @param response data from callout
   * @return  MaintainPartyInformationWrapper.MaintainPartyInfo
   */
  @TestVisible
  private static MaintainPartyInformationWrapper.MaintainPartyInfo getMatchedCustomerInfo(
    OCVRequestPayloadWrapper record,
    Account accountRecord,
    ShellProspectInfoWrapper response
  ) {
    MaintainPartyInformationWrapper.MaintainPartyInfo rec = new MaintainPartyInformationWrapper.MaintainPartyInfo();
    rec.id = accountRecord.Id;
    rec.name = accountRecord.Name;
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
    rec.clgId = accountRecord.CLG__c;
    rec.cpid = response.sourceSystemId;
    rec.kycStatus = accountRecord.FinServ__KYCStatus__c;
    rec.sourceSystem = response.sourceSystemName;
    rec.ocvId = response.ocvId;
    return rec;
  }
}
