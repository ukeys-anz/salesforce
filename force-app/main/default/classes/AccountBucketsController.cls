/**
 * @author Peter Charalambous
 * @since December 2021
 * @description AccountBucketsController is the controller for the Buckets LWC
 */
public with sharing class AccountBucketsController {
  /**
   * @description  The getAccountBuckets(ocvId) is the method to make the Http callout to Mulesoft to fetch the accounts and goals details from Fabric.
   * @param ocvId Ocv id for which accounts and goals needs to be fetched
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled
  public static AccountBucketsModel getAccountBuckets(String ocvId) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    AccountBucketsModel result = coachapi.getAccountBuckets(ocvId);
    return result;
  }
}
