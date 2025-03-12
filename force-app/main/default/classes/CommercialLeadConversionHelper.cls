/**
 * @author       : Advait Yermalkar
 * @since        : 02-07-2025
 * @description  :
 **/
public with sharing class CommercialLeadConversionHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CommercialLeadConversionRepository LEADCONV_REPOSITORY = (CommercialLeadConversionRepository) Lib_InstanceProvider.forType(
    CommercialLeadConversionRepository.class
  );
  private static final CommercialLeadConversionHelper COMMERCIAL_LEAD_CONVERSION_HELPER = (CommercialLeadConversionHelper) Lib_InstanceProvider.forType(
    CommercialLeadConversionHelper.class
  );
  private static final String INSUFFICIANT_PERMISSION_ERROR = 'Insufficiant Permission to update Lead';
  private static final String CAPCIS_LEAD_UPDATE_ERROR = 'Error occured while updating lead record during conversion.';
  private static final String INDIVIDUAL = 'Individual';
  private static final String OCV_USER_ERROR = 'Error occured while fetching OCV Integration User.';
  private static final String SHELL_PROSPECT_CREATION_ERROR = 'Error occured while shell prospect creation during maintain Party callout :';
  private static final String EXISTING_CUSTOMER_NOT_FOUND_ERROR = 'Cannot found Existing Customer in Salesforce with ExternalId: ';
  public static User ocvUser = new User();

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description Updates lead with capcis id for both org and Individual Accounts.
   * @name updateLeadWithCapcisId
   * @param record Lead record from lwc component.
   * @param response result from cap api response
   * @param accountInstance Account record
   * @return new oportunity id
   */
  public static String updateLeadWithCapcisId(
    Lead record,
    DCRMMaintainPartyModel response,
    Account accountInstance
  ) {
    if (!LEADCONV_REPOSITORY.isLeadCAPCISUpdatable()) {
      Logger.error(INSUFFICIANT_PERMISSION_ERROR, record.Id).save();
      throw new CustomException(INSUFFICIANT_PERMISSION_ERROR);
    }
    try {
      String opportunityId;
      if (accountInstance == null || accountInstance.Id == null) {
        return opportunityId;
      }
      record.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      record.FinServ__RelatedAccount__c = (accountInstance.recordTypeId ==
        CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID)
        ? null
        : accountInstance.id;
      record.CAPCIS_ID__c = response.sourceSystems[0].sourceSystemId;
      CCRMLeadConversionActions.leadConverionFlow = true;
      DML_REPOSITORY.doUpdate(record, new DmlConfig().withoutSharing());
      opportunityId = AccountCommonActions.findAndConvertCCRMLead(
        accountInstance.Id,
        record
      );
      return opportunityId;
    } catch (DmlException ex) {
      throw new CustomException(CAPCIS_LEAD_UPDATE_ERROR);
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), record.Id).save();
      throw new AuraHandledException(ex.getMessage());
    }
  }

  /**
   * @description Convert CCRM Lead for matched maintain party Existing Customer
   * @name updateAndConvertMatchedLead
   * @param accId get account id matched for lead conversion
   * @param cpId get cpid from ocv reponse
   * @param record The Lead record to convert
   * @return string  opportunity id created from lead conversion
   */
  @AuraEnabled(cacheable=false)
  public static String updateAndConvertMatchedLead(
    String accId,
    String cpId,
    Lead record
  ) {
    string opportunityId;
    if (!LEADCONV_REPOSITORY.isLeadCAPCISUpdatable()) {
      Logger.error(INSUFFICIANT_PERMISSION_ERROR, record.Id).save();
      throw new CustomException(INSUFFICIANT_PERMISSION_ERROR);
    }
    try {
      record.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
      record.CAPCIS_ID__c = cpId;
      record.FinServ__RelatedAccount__c = accId;
      CCRMLeadConversionActions.leadConverionFlow = true;
      DML_REPOSITORY.doUpdate(record, new DmlConfig().withoutSharing());
      opportunityId = AccountCommonActions.findAndConvertCCRMLead(
        accId,
        record
      );
      return opportunityId;
    } catch (DmlException ex) {
      throw new CustomException(CAPCIS_LEAD_UPDATE_ERROR);
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), record.Id).save();
      throw new AuraHandledException(ex.getMessage());
    }
  }

  /**
   * @description populate party details and return to lwc component
   * @name setMaintainPartyInfoWrapper
   * @param externalId unique ids to query from salesforce database
   * @param response response data from callout
   * @param record lead record
   * @return MaintainPartyInfoWrapper for lwc
   */
  public MaintainPartyInformationWrapper.MaintainPartyInfoWrapper setMaintainPartyInfoWrapper(
    String externalId,
    ShellProspectInfoWrapper response,
    OCVRequestPayloadWrapper record
  ) {
    try {
      MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainPartyWrapper = new MaintainPartyInformationWrapper.MaintainPartyInfoWrapper();
      maintainPartyWrapper.matchedResults = new List<MaintainPartyInformationWrapper.MaintainPartyInfo>();
      Account acc = LEADCONV_REPOSITORY.getAccountUsingExternalId(externalId);
      if (acc == null) {
        return maintainPartyWrapper;
      }

      MaintainPartyInformationWrapper.MaintainPartyInfo rec = new MaintainPartyInformationWrapper.MaintainPartyInfo();
      //Set Common Values
      rec.id = acc.Id;
      rec.name = acc.Name;
      rec.cpid = response.sourceSystemId;
      rec.ocvId = response.ocvId;
      rec.kycStatus = acc.FinServ__KYCStatus__c;
      rec.sourceSystem = response.sourceSystemName;

      if (
        acc.recordTypeId == CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID
      ) {
        //Set Organization Specific Values
        rec.suburb = record.strcity;
        rec.postCode = record.strPostalCode;
      } else if (acc.recordTypeId == CCRMConstants.ACCOUNT_PERSON_RT_ID) {
        //Set Individual Specific Values
        rec.clgId = acc.CLG__c;
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
      }
      maintainPartyWrapper.matchedResults.add(rec);

      return maintainPartyWrapper;
    } catch (Exception e) {
      Logger.error(e.getMessage(), record.strRecordId).save();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Shell Prospect Info population from Maintain Party response
   * @param response Maintain Party API response
   * @param reqRecord Lead record in the form of OCVRequestPayloadWrapper.
   * @return ShellProspectInfoWrapper trasform response to wrapper instance
   **/
  @TestVisible
  private ShellProspectInfoWrapper getShellProspectInfoWrapper(
    DCRMMaintainPartyModel response,
    OCVRequestPayloadWrapper reqRecord
  ) {
    ShellProspectInfoWrapper shellProspectInfoInstance = new ShellProspectInfoWrapper();
    //common variable Assignments
    shellProspectInfoInstance.sourceSystemId = response.sourceSystems[0]
      .sourceSystemId;
    shellProspectInfoInstance.sourceSystemName = response.sourceSystems[0]
      .sourceSystemName;
    shellProspectInfoInstance.ocvId = String.valueOf(response.ocvId);
    shellProspectInfoInstance.profileIds = response.profileIds;
    // Organization | Individual specific Assignments
    shellProspectInfoInstance.name = reqRecord.isIndividual
      ? ''
      : reqRecord.strName;
    shellProspectInfoInstance.isIndividual = reqRecord.isIndividual;
    return shellProspectInfoInstance;
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
    try {
      Account accountInstance;
      ocvUser = LEADCONV_REPOSITORY.getOCVUser();
      if (ocvUser == null) {
        return accountInstance;
      }
      ShellProspectInfoWrapper shellProspectInfoInstance = COMMERCIAL_LEAD_CONVERSION_HELPER.getShellProspectInfoWrapper(
        response,
        reqRecord
      );
      accountInstance = COMMERCIAL_LEAD_CONVERSION_HELPER.getShellProspectRecord(
        shellProspectInfoInstance,
        reqRecord
      );
      CCRMLeadConversionActions.manualLeadConversionInitiated = true;
      DML_REPOSITORY.doInsert(
        accountInstance,
        new DmlConfig().withoutSharing()
      );
      return accountInstance;
    } catch (DmlException ex) {
      throw new CustomException(SHELL_PROSPECT_CREATION_ERROR);
    } catch (QueryException ex) {
      Logger.error(OCV_USER_ERROR, reqRecord.strRecordId, ex).save();
      throw new CustomException(OCV_USER_ERROR);
    } catch (Exception ex) {
      Logger.error(ex.getMessage(), reqRecord.strRecordId).save();
      throw new CustomException(ex.getMessage());
    }
  }

  /**
   * @description create shell prospect after receiving response from CAP API
   * @name getMaintainPartyExistingCustomerDetails
   * @param reqRecord Lead record in the form of OCVRequestPayloadWrapper.
   * @param response result from cap api response
   * @return MaintainPartyInfoWrapper
   */
  public static MaintainPartyInformationWrapper.MaintainPartyInfoWrapper getExistingCustomerDetails(
    OCVRequestPayloadWrapper reqRecord,
    DCRMMaintainPartyModel response
  ) {
    try {
      MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainPartyWrapper = new MaintainPartyInformationWrapper.MaintainPartyInfoWrapper();
      ShellProspectInfoWrapper shellProspectInfoInstance = COMMERCIAL_LEAD_CONVERSION_HELPER.getShellProspectInfoWrapper(
        response,
        reqRecord
      );
      String externalId =
        shellProspectInfoInstance.sourceSystemName +
        '_' +
        shellProspectInfoInstance.sourceSystemId;

      maintainPartyWrapper.oppID = '';
      maintainPartyWrapper = COMMERCIAL_LEAD_CONVERSION_HELPER.setMaintainPartyInfoWrapper(
        externalId,
        shellProspectInfoInstance,
        reqRecord
      );

      if (
        maintainPartyWrapper.matchedResults == null ||
        maintainPartyWrapper.matchedResults.isEmpty()
      ) {
        Logger.error(EXISTING_CUSTOMER_NOT_FOUND_ERROR, reqRecord.strRecordId)
          .save();
        throw new CustomException(EXISTING_CUSTOMER_NOT_FOUND_ERROR);
      }
      maintainPartyWrapper.isNewCustomer = false;
      return maintainPartyWrapper;
    } catch (Exception e) {
      Logger.error(e.getMessage(), reqRecord.strRecordId).save();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description returns a instansce of ShellProspect with Appropriate Mapping
   * @param shellProspectInfo ShellProspectInfoWrapper
   * @param reqRecord OCV payload request
   * @return Account
   **/
  public Account getShellProspectRecord(
    ShellProspectInfoWrapper shellProspectInfo,
    OCVRequestPayloadWrapper reqRecord
  ) {
    Account account = new Account();
    account.RecordTypeId = reqRecord.isIndividual
      ? CCRMConstants.ACCOUNT_PERSON_RT_ID
      : CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    account.Source_System_ID__c = shellProspectInfo.sourceSystemId;
    account.Source_System_Name__c = shellProspectInfo.sourceSystemName;
    if (shellProspectInfo.isIndividual) {
      account.FirstName = reqRecord.strFirstName;
      account.LastName = reqRecord.strLastName;
      account.MiddleName = reqRecord.strMiddleName;
    } else {
      account.Name = shellProspectInfo.name;
    }
    account.FinServ__Status__c = CCRMConstants.PROSPECT;
    account.OCV_Event_Version__c = Integer.valueOf(
      System.Label.DCRM_ShellProspectOCVEventVersion
    );
    account.External_Id__c =
      shellProspectInfo.sourceSystemName +
      '_' +
      shellProspectInfo.sourceSystemId;
    //remove when the field is set to optional
    account.OCV_ID__c = shellProspectInfo.ocvId;
    account.OwnerId = ocvUser.Id;
    return account;
  }

  /**
   * @description payload request to OCV
   * @name getRequestRecordMaintainParty
   * @param record Lead record from lwc component.
   * @return ocvRequest as OCVRequestPayloadWrapper
   */
  public OCVRequestPayloadWrapper getRequestRecordOrganization(Lead record) {
    OCVRequestPayloadWrapper ocvRequest = new OCVRequestPayloadWrapper();
    ocvRequest.isIndividual =
      record.Entity_Type__c?.equalsIgnoreCase(INDIVIDUAL) == true;
    ocvRequest.strOwnerId = record.ownerid;
    ocvRequest.strOrganisationType = record.Entity_Type__c;
    ocvRequest.strIndustryCode = record.Industry__r.Code__c;
    ocvRequest.strName = record.Company;
    ocvRequest.strStartDate = DateTime.now().format('yyyy-MM-dd');
    ocvRequest.strEmail = record.Email;
    ocvRequest.strCommercialContactsPhone = record.Work_Phone__c != null
      ? record.Work_Phone__c
      : record.Home_Phone__c;
    ocvRequest.strCommercialContactsMobile = record.MobilePhone;
    ocvRequest.strCommercialContactsName = record.Name;
    ocvRequest.strCommercialContactsTitle = record.Title__c;
    ocvRequest.strABNIdentifier = record.ABN__c?.deleteWhitespace();
    ocvRequest.strACNIdentifier = record.ACN__c?.deleteWhitespace();
    ocvRequest.strIdentifiersStartDate = DateTime.now().format('yyyy-MM-dd');
    ocvRequest.isValidStreet = record.Is_Valid_Address__c;
    ocvRequest.strStreet = record.Street;
    ocvRequest.strCity = record.City;
    ocvRequest.strState = record.State;
    ocvRequest.strPostalCode = record.PostalCode;
    ocvRequest.strCountry = record.Country;
    return ocvRequest;
  }

  /**
   * @description Wrapper class to store create/maintain party info
   */
  public class ShellProspectInfoWrapper {
    @TestVisible
    private string sourceSystemName;
    @TestVisible
    private string sourceSystemId;
    @TestVisible
    private String ocvId;
    @TestVisible
    private List<string> profileIds;
    @TestVisible
    private string name;
    @TestVisible
    private Boolean isIndividual;
  }
}
