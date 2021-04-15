@isTest
public inherited sharing class CoachBankingAPIRepositoryTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addAccountsGoalsPs();
  }
  /**
   * @description fetch valid accounts, mocked values in force-app/main/default/staticresources/mock_accountsAndGoals.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void accountsGoalsValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
      AccountsAndGoalsModel model = coachapi.getAccounts('1111');
      Test.stopTest();

      System.assertEquals(2, model.accountList.size());
      System.assertEquals('000000000', model.accountList[0].accountNumber);
    }
  }

  /**
   * @description fetch invalid accounts
   */
  @isTest
  static void accountsGoalsInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      AccountsAndGoalsModel model;
      HttpCalloutResponse res = getAccountsGoalsInvalidResponse();
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
      try {
        model = coachapi.getAccounts('1111');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals('Get accounts failed', resultException.getMessage());
    }
  }

  private static HttpCalloutResponse getAccountsGoalsInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Get accounts failed');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  /**
   * @description fetch valid accounts, mocked values in force-app/main/default/staticresources/mock_accountsAndGoals.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void accountsGoalsAuraResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      AccountsAndGoalsModel model = CoachBankingAPIRepository.getAccountsAura(
        '1111'
      );
      Test.stopTest();

      System.assertEquals(2, model.accountList.size());
      System.assertEquals('000000000', model.accountList[0].accountNumber);
    }
  }

  /**
   * @description fetch valid transaction history, mocked values in force-app/main/default/staticresources/mock_transactionHistory.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void transactionHistoryValidResponse() {
    Test.startTest();
    CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
    TransactionHistoryModel transactionModel = coachAPI.getTransactionHistory(
      '1111',
      '000000000',
      ''
    );
    Test.stopTest();

    System.assertEquals(20, transactionModel.transactions.size());
  }

  /**
   * @description fetch invalid transaction history
   */
  @isTest
  static void transactionHistoryInvalidResponse() {
    TransactionHistoryModel transactionModel;
    HttpCalloutResponse res = getTransactionHistoryInvalidResponse();
    Service s = ServiceProvider.getService(FabricService.class);
    s.setCalloutResponse(res);
    Exception resultException;
    Test.startTest();
    CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
    try {
      transactionModel = coachAPI.getTransactionHistory(
        '1111',
        '000000000',
        ''
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    System.assertEquals(
      'Get transaction history failed',
      resultException.getMessage()
    );
  }

  private static HttpCalloutResponse getTransactionHistoryInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Get transaction history failed');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  /**
   * @description fetch valid transaction history, mocked values in force-app/main/default/staticresources/mock_transactionHistory.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void transactionHistoryAuraResponse() {
    Test.startTest();
    CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
    TransactionHistoryModel transactionModel = coachAPI.getTransactionHistory(
      '1111',
      '000000000',
      ''
    );
    Test.stopTest();

    System.assertEquals(20, transactionModel.transactions.size());
  }
}
