/**
 * @author Akanksha Kulkarni
 * @since Nov 2025
 * @description class for Applicant Form actions
 */
public with sharing class ApplicationFormAccountActions {
  public static final ApplicationFormEventRepository APPLICATIONTFORM_ACCOUNT_REPOSITORY = (ApplicationFormEventRepository) Lib_InstanceProvider.forType(
    ApplicationFormEventRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description Orchestration method for updating the Customer Sync Status
   * @param applicantFormIds loan applicants to process
   */
  public static void accountSyncStatusUpdate(Set<Id> applicantFormIds) {
    List<ApplicationForm> filteredApplicationForm = APPLICATIONTFORM_ACCOUNT_REPOSITORY.queryApplicationFormCustomer(
      applicantFormIds
    );
    List<Account> accounts = updateAccountSyncStatus(filteredApplicationForm);
    DML_REPOSITORY.doUpdate(accounts, new DmlConfig().allowPartial());
  }
  /**
   * @description Sets the Account Sync Status picklist value from ApplicationForm
   * @param applicationFormRecs ApplicationForm list
   * @return List<Account> accountList updated accountList
   */
  @TestVisible
  private static List<Account> updateAccountSyncStatus(
    List<ApplicationForm> applicationFormRecs
  ) {
    List<Account> accounts = new List<Account>();
    for (ApplicationForm applicationForm : applicationFormRecs) {
      Account account = new Account(Id = applicationForm.AccountId);
      account.Sync_Status__c = PicklistUtil.addMultiPicklistValue(
        applicationForm.Account.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_BROKER_ORG
      );
      accounts.add(account);
    }
    return accounts;
  }
}
