/**
 * @author Peter Charalambous
 * @since December 2021
 * @description AccountBucketsController is the controller for the Buckets LWC
 */
public with sharing class AccountBucketsController {
  /**
   * @description  The getAccountBuckets(ocvId) is the method to make the Http callout to Mulesoft to fetch the accounts and goals details from Fabric.
   * @param ocvId Ocv id for which buckets needs to be fetched
   * @param pageSize The amount of buckets to return with the call
   * @param nextPageToken The token used to get the next page of data from the api
   * @param accountNumber accountNumber to fetch the goals for
   * @return String
   * @exception CalloutException
   */
  @AuraEnabled
  public static AccountBucketsModel getAccountBuckets(
    String ocvId,
    Integer pageSize,
    String nextPageToken,
    String accountNumber
  ) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    AccountBucketsModel result = coachapi.getAccountBuckets(
      ocvId,
      pageSize,
      nextPageToken,
      accountNumber
    );
    return result;
  }
}
