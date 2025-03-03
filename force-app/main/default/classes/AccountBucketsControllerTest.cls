/**
 * @author Peter Charalambous
 * @since December 2021
 * @description AccountBucketsControllerTest is the test class to cover tests for {@link AccountBucketsController}
 */
@isTest
public with sharing class AccountBucketsControllerTest {
  static Lib_MockProvider finAccRepoMock;
  static Lib_MockProvider userMock;

  static void registerMocks() {
    finAccRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
  }

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
    registerMocks();
    Test.startTest();
    AccountBucketsModel response = AccountBucketsController.getAccountBuckets(
      '123',
      7,
      '',
      '111111111'
    );
    Assert.isTrue(
      response.account_buckets.size() == 7,
      'Response account buckets size should be as expected.'
    );
    Test.stopTest();
  }
}
