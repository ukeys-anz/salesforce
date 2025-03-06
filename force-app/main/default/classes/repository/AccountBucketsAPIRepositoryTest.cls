/**
 * @author Kopal Goswami
 * @date March 2025
 * @description Test class for {@link AccountBucketsAPIRepositoryTest}
 * @group Repository
 */
@isTest
public with sharing class AccountBucketsAPIRepositoryTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(
      new List<String>{
        'Accounts_Goals_Read_Only',
        'View_Card_Details',
        'View_Transaction_History',
        'Product_Read_Only'
      }
    );
  }

  /**
   * @description fetch valid account buckets, mocked values in force-app/main/default/staticresources/mock_accountBuckets.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void accountBucketsValidResponse() {
    Test.startTest();
    AccountBucketsAPIRepository accountBucketApi = new AccountBucketsAPIRepository();
    AccountBucketsModel response = accountBucketApi.getAccountBuckets(
      '1111',
      7,
      '',
      ''
    );
    Test.stopTest();

    Assert.isTrue(
      response.account_buckets.size() == 7,
      'Response account buckets size should be as expected.'
    );
  }

  /**
   * @description fetch invalid account buckets
   */
  @isTest
  static void accountBucketsInvalidResponse() {
    HttpCalloutResponse res = getAccountBucketsInvalidResponse(
      'Get account buckets failed'
    );
    Service serviceInstance = ServiceProvider.getService(FabricService.class);
    serviceInstance.setCalloutResponse(res);
    Exception resultException;
    Test.startTest();
    AccountBucketsAPIRepository accountBucketApi = new AccountBucketsAPIRepository();
    try {
      accountBucketApi.getAccountBuckets('1111', 4, '', '');
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    Assert.areEqual(
      'Get account buckets failed',
      resultException.getMessage(),
      'Error message should be as expected.'
    );
  }

  private static HttpCalloutResponse getAccountBucketsInvalidResponse(
    String exceptionMsg
  ) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(exceptionMsg);
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
