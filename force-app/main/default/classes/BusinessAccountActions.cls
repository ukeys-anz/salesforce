/**
 * @author Ashwin Mohan
 * @since  02/2025
 * @description BusinessAccountActions is class to handle the Business Account Actions
 * @runTests BusinessAccountActionsTest
 */
public with sharing class BusinessAccountActions {
  private static final AccountActionsRepository ACC_REPOSITORY = (AccountActionsRepository) Lib_InstanceProvider.forType(
    AccountActionsRepository.class
  );

  /**
   * @description CC-7202 Organisation RT fields should be read-only. Add Error to Orgnisation Records when OCV id is changed by a ML user
   * @name setErrorForOCVIdChange
   * @param records List of Account Records from Trigger.New
   * @param oldMap The Account records passed from Trigger
   */
  public static void setErrorForOCVIdChange(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    // applicable only for ML users and not applicable during lead conversion.
    if (
      !ACC_REPOSITORY.isCurrentUserML() ||
      LeadConversionController.manualLeadConversionInitiated
    ) {
      return;
    }
    List<Account> ocvIdUpdatedRecords = ListUtil.filter(records, oldMap)
      .changed(Account.OCV_ID__c)
      .toList();
    CommonUtil.raiseSobjectError(
      ocvIdUpdatedRecords,
      Label.OCV_ID_Update_ErrorMessage
    );
  }
}
