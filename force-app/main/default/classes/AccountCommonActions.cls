/**
 *
 * @author David Dawson
 * @since 08/2020
 * @description Common Account Action methods
 */

public with sharing class AccountCommonActions {
  private static final Non_Prod_Settings__c NON_PROD_SETTINGS = Non_Prod_Settings__c.getInstance(
    UserInfo.getUserId()
  );

  /**
   * @description enforceNonProdAccountWhitelist is called when both after insert and after update is finished to enforce whitelisting
   * @param records The Account records passed from Trigger.new()
   */
  public static void enforceNonProdAccountWhitelist(List<Account> records) {
    if (
      (SFConstants.IS_SANDBOX || Test.isRunningTest()) &&
      NON_PROD_SETTINGS.Enable_Account_Whitelisting__c
    ) {
      List<String> whitelist = NON_PROD_SETTINGS.Account_Whitelist__c.split(
        ','
      );
      for (Account acc : records) {
        if (!whitelist.contains(acc.Fabric_ID__c)) {
          acc.addError(
            'This account is not currently whitelisted for this sandbox.'
          );
        }
      }
    }
  }

  /**
   * @description checkForAccountDeletion is called to check if the Deleted_In_OCV__c flag is updated for deletion
   * @param records The Account records passed from Trigger.new()
   */
  public static void checkForAccountDeletion(List<Account> records) {
    List<Account> accList = new List<Account>();

    for (Account acc : records) {
      if (acc.Deleted_In_OCV__c == true) {
        accList.add(acc);
      }
    }
    if (accList.size() == 1) {
      System.enqueuejob(new QueueAccountDeletion(accList[0]));
    } else if (accList.size() > 1) {
      for (Account acc : accList) {
        acc.addError(
          'having multiple records with the Deleted_In_OCV__C flag set in a single transaction is not supported'
        );
      }
    }
  }
}
