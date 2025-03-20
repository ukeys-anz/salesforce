/**
 * @author Kopal Goswami
 * @date March 2025
 * @description Test class for {@link FinancialAccountAPIRepository}
 * @group Repository
 */
@isTest
public with sharing class FinancialAccountAPIRepositoryTest {
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
   * @description fetch valid accounts, mocked values in force-app/main/default/staticresources/mock_financialAccount.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void financialAccountValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      FinancialAccountAPIRepository financialaccountapi = new FinancialAccountAPIRepository();
      UnifiedFinancialAccountModel model = financialaccountapi.getAccounts(
        '1111',
        new List<String>()
      );
      Test.stopTest();

      Assert.isTrue(
        model.accounts.size() > 2,
        'Financial Account list size should be as expected.'
      );
    }
  }

  /**
   * @description fetch invalid accounts
   */
  @isTest
  static void financialAccountInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      HttpCalloutResponse res = getFinancialAccountInvalidResponse(
        'Get accounts failed'
      );
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      FinancialAccountAPIRepository financialaccountapi = new FinancialAccountAPIRepository();
      try {
        UnifiedFinancialAccountModel model = financialaccountapi.getAccounts(
          '1111',
          new List<String>()
        );
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals(
        'Get accounts failed',
        resultException.getMessage(),
        'Error message should be as expected.'
      );
    }
  }

  private static HttpCalloutResponse getFinancialAccountInvalidResponse(
    String exceptionMsg
  ) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(exceptionMsg);
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
