/**
 * @author Ankit Garg
 * @since  06/2023
 * @description CCRM lead conversion helper actions which includes calling search and create party api, deleting auto created contacts post conversion
 */
public with sharing class CCRMLeadConversionActionsHelper {
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
   * @return MaintainPartyInfoWrapper
   */
  public static MaintainPartyInformationWrapper.MaintainPartyInfoWrapper updateLeadWithCapcisIdIndividual(
    Lead record,
    DCRMMaintainPartyModel response
  ) {
    Map<Id, Id> mapOfOpportunityId = new Map<Id, Id>();
    String recordTypeId = '';
    if (
      Schema.sObjectType.Lead.isUpdateable() &&
      Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable() &&
      Schema.sObjectType.Lead.fields.FinServ__RelatedAccount__c.isUpdateable() &&
      Schema.sObjectType.Lead.fields.CAPCIS_ID__c.isUpdateable()
    ) {
      recordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID;
      Account accountInstance = new Account();
      MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainPartyWrapper = new MaintainPartyInformationWrapper.MaintainPartyInfoWrapper();
      ShellProspectCreator prospectCreator = new ShellProspectCreator();
      ShellProspectInfoWrapper shellProspectInfoInstance = getMaintainPartyInfo(
        response
      );
      if (response.newCustomer == 'true') {
        maintainPartyWrapper.oppID = '';
        accountInstance = prospectCreator.createShellProspect(
          shellProspectInfoInstance,
          recordTypeId,
          record
        );
        record.FinServ__RelatedAccount__c = accountInstance.id;
        maintainPartyWrapper.isNewCustomer = true;
      } else {
        String externalId =
          shellProspectInfoInstance.sourceSystemName +
          '_' +
          shellProspectInfoInstance.sourceSystemId;
        try {
          maintainPartyWrapper.oppID = '';
          maintainPartyWrapper = populateMaintainPartyDetails(
            externalId,
            shellProspectInfoInstance,
            record
          );
          if (
            maintainPartyWrapper.matchedResults == null ||
            maintainPartyWrapper.matchedResults.isEmpty()
          ) {
            // Throw custom exception
            handleError(
              'Cannot found Existing Customer in Salesforce with ExternalId: ' +
              externalId,
              record.Id
            );
          }
          maintainPartyWrapper.isNewCustomer = false;
        } catch (Exception e) {
          Logger.error(e.getMessage() + record.Id);
          Logger.saveLog();
          throw new AuraHandledException(e.getMessage());
        }
      }
      if (
        response.newCustomer == 'true' &&
        accountInstance != null &&
        accountInstance.Id != null
      ) {
        record.Skip_Validations__c = CCRMConstants.CONVERT_LEAD;
        record.CAPCIS_ID__c = response.sourceSystems[0].sourceSystemId;
        CCRMLeadConversionActions.leadConverionFlow = true;
        Boolean isLeadUpdated = prospectCreator.updateLead(record);
        if (isLeadUpdated) {
          String opptId = CCRMLeadConversionActions.convertCCRMLead(
            accountInstance.Id,
            record
          );
          maintainPartyWrapper.oppID = opptId;
        }
      } else if (response.newCustomer == 'true' && accountInstance.Id == null) {
        maintainPartyWrapper.oppID = '';
        // Throw custom exception
        handleError('Shell Customer Creation Failure.', record.Id);
      }
      return maintainPartyWrapper;
    }
    Logger.error('Insufficiant Permission to update Lead' + record.Id);
    Logger.saveLog();
    // Throw custom exception
    throw new CustomException('Insufficiant Permission to update Lead.');
  }

  /**
   * @param externalId unique ids to query from salesforce database
   * @param response response data from callout
   * @param record lead record
   * @return MaintainPartyInfoWrapper for lwc
   * @description populate party details and return to lwc component
   */
  public static MaintainPartyInformationWrapper.MaintainPartyInfoWrapper populateMaintainPartyDetails(
    String externalId,
    ShellProspectInfoWrapper response,
    Lead record
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
        record?.street +
        ', ' +
        record?.city +
        ' ' +
        record?.state +
        ' ' +
        record?.country +
        ' ' +
        record?.postalCode;
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
      handleError('Insufficiant Permission to update Lead', record.Id);
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
        handleError(
          'Error occured while updating lead record during conversion.',
          record.Id
        );
      }
      recordTypeId = (record.Entity_Type__c != null &&
        record.Entity_Type__c.equalsIgnoreCase('Individual'))
        ? CCRMConstants.ACCOUNT_PERSON_RT_ID
        : CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
      ShellProspectInfoWrapper shellProspectInfoInstance = getCreatePartyInfo(
        response
      );
      //transform api result to wrapper instance
      ShellProspectCreator prospectCreator = new ShellProspectCreator();
      Account accountInstance = prospectCreator.createShellProspect(
        shellProspectInfoInstance,
        recordTypeId,
        record
      );
      return CCRMLeadConversionActions.convertCCRMLead(
        accountInstance.Id,
        record
      );
    }
    // Throw custom exception
    throw new CustomException(
      'Error occured while trying to update Lead record.'
    );
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
  private static void handleError(String errorMessage, String leadId) {
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
        handleError(
          'Error occured while updating lead record during conversion.',
          record.Id
        );
      }
      return false;
    }

    /**
     * @description create shell prospect after receiving response form cap API
     * @name createShellProspect
     * @param shellProspectInfoInstance result from cap api response transformed into CustomerInfo wrapper
     * @param recordTypeId recordtype id of shell prospect
     * @param leadRecord lead record
     * @return shell prospect created for lead conversion
     */
    private Account createShellProspect(
      ShellProspectInfoWrapper shellProspectInfoInstance,
      String recordTypeId,
      Lead leadRecord
    ) {
      Account shellProspectToInsert = new Account();
      List<User> userList = new List<User>();
      userList = getOCVUser();
      if (userList.isEmpty()) {
        handleError(
          'Error occured while fetching OCV Integration User.',
          leadRecord.Id
        );
      }
      shellProspectToInsert = new Account();
      shellProspectToInsert.Source_System_ID__c = shellProspectInfoInstance.sourceSystemId;
      shellProspectToInsert.Source_System_Name__c = shellProspectInfoInstance.sourceSystemName;
      if (shellProspectInfoInstance.isIndividual) {
        shellProspectToInsert.FirstName = leadRecord.FirstName;
        shellProspectToInsert.LastName = leadRecord.LastName;
        shellProspectToInsert.MiddleName = leadRecord.MiddleName;
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
          'Error occured while shell prospect creation during lead conversion :' +
          result.getErrors()[0].getMessage(),
          leadRecord.id
        );
      }
      return shellProspectToInsert;
    }
  }
}
