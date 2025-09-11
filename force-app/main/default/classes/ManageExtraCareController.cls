/**
 * @description       : Controller for ManageExtraCare LWC
 * @author            : Akshat Khandelwal
 * @group             :
 * @last modified on  : Apr 2025
 **/
public with sharing class ManageExtraCareController {
  private static final ProfileStagingHandler PROFILE_STAGING = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );
  private static final ProfileStagingRepository PROFILE_STAGING_REPOSITORY = (ProfileStagingRepository) Lib_InstanceProvider.forType(
    ProfileStagingRepository.class
  );
  private static final ManageExtraCareControllerRepository MANAGE_EXTRACARE_REPOSITORY = (ManageExtraCareControllerRepository) Lib_InstanceProvider.forType(
    ManageExtraCareControllerRepository.class
  );

  /**
   * @description Checks the updates in Extra Care Fields and calls ManageExtraCare API
   * @param oldAccount Account instance with initial values of Extra Care fields
   * @param newAccount Account instance with updated values of Extra Care fields
   */
  @AuraEnabled
  public static void handleExtraCareUpdate(
    Account oldAccount,
    Account newAccount
  ) {
    Map<Id, Account> oldAccountMap = new Map<Id, Account>{
      oldAccount.Id => oldAccount
    };
    List<Account> newAccountList = new List<Account>{ newAccount };
    try {
      PROFILE_STAGING.process(
        new ExtraCareProfileStagingConfig(),
        newAccountList,
        new Map<Id, Account>(oldAccountMap)
      );
    } catch (Exception e) {
      Logger.info('Error in creating the Staging record', newAccount.Id, e);
      Logger.saveLog();
      throw new AuraHandledException(
        'An error occurred while updating Extra care details. Please try again.'
      );
    }
  }
  /**
   * @description get the staging record's status field value.
   * @param accountId Id of the account record
   * @return status of the staging record.
   */
  @AuraEnabled
  public static String getStagingRecordStatus(Id accountId) {
    Customer_Profile_Updates__c stagingRecord = MANAGE_EXTRACARE_REPOSITORY.queryCustomerProfileUpdateRecordByCustomerId(
      accountId
    );
    if (stagingRecord == null) {
      return null;
    }
    if (stagingRecord.Status__c != 'Completed') {
      return stagingRecord.Status__c;
    }
    Account objAccount = (Account) JSON.deserialize(
      stagingRecord.ToBeValue__c,
      Account.class
    );
    return stagingRecord.Customer_Name__r.OCV_Event_Version__c >
      objAccount.OCV_Event_Version__c
      ? stagingRecord.Status__c
      : 'WaitingForOCVUpdate';
  }
}
