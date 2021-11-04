/**
 * @author Pavan Kumar Ananta
 * @date February 2020
 * @description Test class for {@link CoachBankingAPIRepository}
 * @group Repository
 */
@isTest
public inherited sharing class CoachBankingAPIRepositoryTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(
      new List<String>{ 'Accounts_Goals_Read_Only', 'View_Card_Details' }
    );
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
   * @description Test to confirm "balance" attribute in response data is validated before passing to UI layer
   */
  @isTest
  static void missingBalanceInResponse() {
    // GIVEN
    // a customer record has valid Fin Accounts in Fabric
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getAccountsAndGoals('1111');
    String validResponse = response.body;

    // WHEN
    // for some reason, the Fabric API response returns “balance” attribute as empty
    //clean up data
    validResponse = validResponse.replaceAll('\n', '');
    validResponse = validResponse.replaceAll(' ', '');
    // manipulate “balance” attribute value to be empty on the mock response coming from "mock_accountsAndGoals.json"
    String matchString = '(?i)(,"value":259)';
    String manipulatedResponse = validResponse.replaceFirst(matchString, '');
    // THEN
    // resonse should be validated before it reaches the UI layer
    Test.startTest();
    AccountsAndGoalsModel modelInstance = new AccountsAndGoalsModel();
    modelInstance = AccountsAndGoalsModel.parse(manipulatedResponse);
    Test.stopTest();

    System.assert(
      !modelInstance.accountList[0].isValid,
      'Failed to validate missing data on "balance" attribute in Accounts & Goals Fabric response.'
    );
  }

  /**
   * @description Test to confirm "currentBalance" attribute in response data is validated before passing to UI layer
   */
  @isTest
  static void missingCurrentBalanceInResponse() {
    // GIVEN
    // a customer record has valid Fin Accounts in Fabric
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getAccountsAndGoals('1111');
    String validResponse = response.body;

    // WHEN
    // for some reason, the Fabric API response returns “currentBalance” attribute as empty

    // manipulate “currentBalance” attribute value to be blank on the mock response coming from "mock_accountsAndGoals.json"
    validResponse = validResponse.replaceAll('\n', '');
    validResponse = validResponse.replaceAll(' ', '');
    // manipulate “balance” attribute value to be empty on the mock response coming from "mock_accountsAndGoals.json"
    String matchString = '(?i)(,"value":260)';
    String manipulatedResponse = validResponse.replaceFirst(matchString, '');

    // THEN
    // resonse should be validated before it reaches the UI layer
    Test.startTest();
    AccountsAndGoalsModel modelInstance = new AccountsAndGoalsModel();
    modelInstance = AccountsAndGoalsModel.parse(manipulatedResponse);
    Test.stopTest();

    System.assert(
      !modelInstance.accountList[0].isValid,
      'Failed to validate missing data on "currentBalance" attribute in Accounts & Goals Fabric response.'
    );
  }

  /**
   * @description Test to confirm "accountType" attribute in response data is validated before passing to UI layer
   */
  @isTest
  static void missingAccountTypeInResponse() {
    // GIVEN
    // a customer record has valid Fin Accounts in Fabric
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getAccountsAndGoals('1111');
    String validResponse = response.body;

    // WHEN
    // for some reason, the Fabric API response returns "accountType" attribute as empty

    // manipulate “accountType” attribute value to be blank on the mock response coming from "mock_accountsAndGoals.json"
    Integer valueStartIndex = validResponse.indexOf(
      '"',
      validResponse.indexOf('"accountType"') + 13
    );
    Integer valueEndIndex = validResponse.indexOf('"', valueStartIndex + 1);
    String accTypeValue = validResponse.substring(
      valueStartIndex + 1,
      valueEndIndex
    );
    String manipulatedResponse = validResponse.replace(accTypeValue, '');

    // THEN
    // resonse should be validated before it reaches the UI layer
    Test.startTest();
    AccountsAndGoalsModel modelInstance = new AccountsAndGoalsModel();
    modelInstance = AccountsAndGoalsModel.parse(manipulatedResponse);
    Test.stopTest();

    System.assert(
      !modelInstance.accountList[0].isValid,
      'Failed to validate missing "accountType" data at Financial Account record level on Accounts & Goals Fabric response.'
    );
  }

  /**
   * @description Test to confirm "accountNumber" attribute in response data is validated before passing to UI layer
   */
  @isTest
  static void missingAccountNumberInResponse() {
    // GIVEN
    // a customer record has valid Fin Accounts in Fabric
    Service s = ServiceProvider.getService(FabricService.class);
    HttpCalloutResponse response = s.getAccountsAndGoals('1111');
    String validResponse = response.body;

    // WHEN
    // for some reason, the Fabric API response returns "accountNumber" attribute as empty

    // manipulate "accountNumber" attribute value to be blank on the mock response coming from "mock_accountsAndGoals.json"
    Integer valueStartIndex = validResponse.indexOf(
      '"',
      validResponse.indexOf('"accountNumber"') + 15
    );
    Integer valueEndIndex = validResponse.indexOf('"', valueStartIndex + 1);
    String accNumberValue = validResponse.substring(
      valueStartIndex + 1,
      valueEndIndex
    );
    String manipulatedResponse = validResponse.replace(accNumberValue, '');

    // THEN
    // resonse should be validated before it reaches the UI layer
    Test.startTest();
    AccountsAndGoalsModel modelInstance = new AccountsAndGoalsModel();
    modelInstance = AccountsAndGoalsModel.parse(manipulatedResponse);
    Test.stopTest();

    System.assert(
      !modelInstance.accountList[0].isValid,
      'Failed to validate missing "accountNumber" data at Financial Account record level on Accounts & Goals Fabric response.'
    );
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
    TransactionHistoryModel transactionModel = CoachBankingAPIRepository.getTransactionHistoryAura(
      '',
      '1111',
      '000000000',
      '2018-07-03 00:00:00',
      '2018-07-26 23:59:59'
    );
    Test.stopTest();

    System.assertEquals(12, transactionModel.embedded.transactions.size());
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
    TransactionHistoryModel transactionModel = CoachBankingAPIRepository.getTransactionHistoryAura(
      '',
      '1111',
      '000000000',
      '2018-07-03 00:00:00',
      '2018-07-26 23:59:59'
    );
    Test.stopTest();

    System.assertEquals(12, transactionModel.embedded.transactions.size());
  }

  /**
   * @description fetch valid card list, mocked values in force-app/main/default/staticresources/mock_cardList.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void cardListValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      CardListModel cardsModel = coachAPI.getCardList('1111');
      Test.stopTest();

      System.assertEquals(4, cardsModel.cards.size());
    }
  }

  /**
   * @description fetch valid card list with incomplet information
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void cardListInvalidInformation() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      CardListModel cardsModel;
      HttpCalloutResponse res = getCardListIncompleteInformation();
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      try {
        cardsModel = coachAPI.getCardList('1111');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals(
        'Card Information is invalid. Please reach out to your system administrator.',
        resultException.getMessage()
      );
    }
  }

  /**
   * @description fetch invalid card list
   */
  @isTest
  static void cardListInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      CardListModel cardsModel;
      HttpCalloutResponse res = getCardListInvalidResponse();
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      try {
        cardsModel = coachAPI.getCardList('1111');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals('Get card list failed', resultException.getMessage());
    }
  }

  @isTest
  static void replaceCardValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      String replaceNumber = coachAPI.replaceCard('1111', '1234', 'stolen');
      Test.stopTest();

      System.assertEquals('9741329257534100', replaceNumber);
    }
  }

  @isTest
  static void replaceCardInvalidReason() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      String errorMsg = '';
      try {
        String replaceNumber = coachAPI.replaceCard(
          '1111',
          '1234',
          'invalidReason'
        );
      } catch (CoachBankingAPIRepository.InvalidInformationException e) {
        errorMsg = e.getMessage();
      }
      System.assertEquals('The replace reason is not valid.', errorMsg);
      Test.stopTest();
    }
  }

  @isTest
  static void replaceCardWithInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      HttpCalloutResponse res = replaceCardInvalidResponse();
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      try {
        coachAPI.replaceCard('1111', '1234', 'stolen');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals('Replace card failed', resultException.getMessage());
    }
  }

  private static HttpCalloutResponse getCardListIncompleteInformation() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;
    response.successful = true;
    response.body = '{"cards":[{"name":"Bruce Willis","tokenizedCardNumber":"1234567890"}]}';
    return response;
  }

  private static HttpCalloutResponse getCardListInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Get card list failed');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  private static HttpCalloutResponse replaceCardInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Replace card failed');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
