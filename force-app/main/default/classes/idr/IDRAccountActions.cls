/**
 *
 * @author CMOS
 * @since 08/2025
 * @description IDRAccountActions is to handle the Account updates related to ECF changes
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRAccountActions {
  /**
   * @description Filter accounts based on ECF flag updates and enqueue to update Priority on related Cases
   * @param records The Account records passed from Trigger.new()
   * @param oldMap old trigger values
   */
  public static void checkEligibilityForCasePriorityUpdate(
    List<Account> records,
    Map<Id, SObject> oldMap
  ) {
    List<Account> lAccountsEcfTrue = ListUtil.filter(records, oldMap)
      .equals(Account.ExtraCareTimePeriod__c, IDRConstants.ECF_FLAG_TRUE)
      .oldNotEquals(Account.ExtraCareTimePeriod__c, IDRConstants.ECF_FLAG_TRUE)
      .toList();
    lAccountsEcfTrue.addAll(
      (List<Account>) ListUtil.filter(records, oldMap)
        .notEquals(Account.ExtraCareTimePeriod__c, IDRConstants.ECF_FLAG_TRUE)
        .oldEquals(Account.ExtraCareTimePeriod__c, IDRConstants.ECF_FLAG_TRUE)
        .toList()
    );

    Set<Id> sFilteredAccountIds = ListUtil.getIds(lAccountsEcfTrue, Account.Id);

    if (sFilteredAccountIds.isEmpty()) {
      return;
    }
    System.enqueuejob(new IDRCasePriorityUpdateQueueable(sFilteredAccountIds));
  }
}
