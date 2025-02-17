/**
 * @author Ankit Garg
 * @since  12/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMAccountActions is class to handle all the MLCRM Account Actions
 * @runTests CCRMAccountActionsTest
 */
public with sharing class MLCRMAccountActions {
  private static final AccountActionsRepository ACC_REPOSITORY = (AccountActionsRepository) Lib_InstanceProvider.forType(
    AccountActionsRepository.class
  );
   
  /**
   * @description CC-5112 && CC-7016 to restrict Date of Birth in Future
   * @name validateDateOfBirth
   * @param records The Account records passed from Trigger.new()
   */
  public static void validateDateOfBirth(List<Account> records) {
    for (Account rec : records) {
      if (
        rec.RecordTypeId == CCRMConstants.ACCOUNT_PERSON_RT_ID &&
        rec.PersonBirthdate != null &&
        rec.PersonBirthdate >= System.TODAY()
      ) {
        rec.addError(Label.ML_DateOfBirth_ErrorMessage);
      }
    }
  }

  /**
   * @description CC-7698 to revert Billing Address of the Shell Prospect auto populated during lead conversion
   * @name revertShellProspectBillingAddress
   * @param records The Account records passed from Trigger.new()
   */
  public static void revertShellProspectBillingAddress(List<Account> records) {
    if (UserInfo.getUserName().startsWith(Label.CCRM_OCVIntegrationUsername)) {
      return;
    }
    if (!CCRMLeadConversionActions.manualLeadConversionInitiated) {
      return;
    }
    if (String.isBlank(System.Label.DCRM_ShellProspectOCVEventVersion)) {
      return;
    }
    for (Account shellRecord : records) {
      if (isShellProspectBillingAddressUpdated(shellRecord)) {
        shellRecord.BillingStreet = null;
        shellRecord.BillingCity = null;
        shellRecord.BillingState = null;
        shellRecord.BillingCountry = null;
        shellRecord.BillingPostalCode = null;
      }
    }
  }

  /**
   * @description isShellProspectBillingAddressUpdated to check if the Account is shell Prospect account with Billing Address is updated or not
   * @param shellRecord Account Record new trigger value
   * @return Boolean True if the Account is shell Prospect account with Billing Address is updated otherwise false.
   */
  @testVisible
  private static Boolean isShellProspectBillingAddressUpdated(
    Account shellRecord
  ) {
    return (shellRecord.FinServ__Status__c == CCRMConstants.PROSPECT &&
    shellRecord.OCV_Event_Version__c ==
    Integer.valueOf(System.Label.DCRM_ShellProspectOCVEventVersion) &&
    (shellRecord.BillingStreet != null ||
    shellRecord.BillingCity != null ||
    shellRecord.BillingState != null ||
    shellRecord.BillingCountry != null ||
    shellRecord.BillingPostalCode != null));
  }

  /**
   * @description CC-7202 Organisation RT fields should be read-only. Add Error to Orgnisation Records when OCV id is changed and Running User having ML Profile. Return Non-Organisation Records from OldMap
   * @name setErrorAndRetNonOrgMlRec
   * @param updatedRecords List of Account Records from Trigger.New
   * @param oldMap The Account records passed from Trigger
   * @return Map<Id, User> Map of Non-Organisation Records for ML Users, return old map if user is not having ML Profile
   */
  public static Map<Id, Account> setErrorAndRetNonOrgMlRec(
    List<Account> updatedRecords,
    Map<Id, Account> oldMap
  ) {
    // If user is not ML User then do nothing and return OldMap
    if (!ACC_REPOSITORY.isCurrentUserML()) {
      return oldMap;
    }
    Map<Id, Account> orgRecords = new Map<Id, Account>();
    Map<Id, Account> nonOrgRecords = new Map<Id, Account>();

    for (String key : oldMap.keySet()) {
      Account record = oldMap.get(key);
      if (record.RecordTypeId == RTAccount.businessAccount) {
        orgRecords.put(key, record);
        continue;
      }
      nonOrgRecords.put(key, record);
    }
    CCRMAccountActions.preventEditOcvId(updatedRecords, orgRecords);
    return nonOrgRecords;
  }
}
