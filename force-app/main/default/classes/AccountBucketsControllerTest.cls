/**
 * @author Peter Charalambous
 * @since December 2021
 * @description AccountBucketsControllerTest is the test class to cover tests for {@link AccountBucketsController}
 */
@isTest
public with sharing class AccountBucketsControllerTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'Accounts_Goals_Read_Only' });
  }
  /**
   * @description test method for getting account buckets when successful
   */
  @isTest
  public static void validResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      AccountBucketsModel response = AccountBucketsController.getAccountBuckets(
        '123'
      );
      System.assertEquals(4, response.account_buckets.size());
      Test.stopTest();
    }
  }
}
