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
   * @description fetch valid accounts, mocked values in force-app/main/default/staticresources/mock_financialAccount.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void financialAccountValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
      FinancialAccountModel model = coachapi.getAccounts(
        '1111',
        new List<String>()
      );
      Test.stopTest();

      System.assertEquals(
        2,
        model.account_list.size(),
        'Account list size should be as expected.'
      );
      System.assertEquals(
        '000000000',
        model.account_list[0].account_number,
        'Account number should be as expected.'
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
      FinancialAccountModel model;
      HttpCalloutResponse res = getFinancialAccountInvalidResponse();
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
      try {
        model = coachapi.getAccounts('1111', new List<String>());
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
      '2018-07-26 23:59:59',
      new List<String>()
    );
    Test.stopTest();

    System.assertEquals(
      17,
      transactionModel.embedded.transactions.size(),
      'Transactions size should be as expected.'
    );
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
      transactionModel = coachAPI.getTransactionHistory('1111', '');
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    System.assertEquals(
      'Get transaction history failed',
      resultException.getMessage(),
      'Error message should be as expected.'
    );
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
      '2018-07-26 23:59:59',
      new List<String>()
    );
    Test.stopTest();

    System.assertEquals(
      17,
      transactionModel.embedded.transactions.size(),
      'Transactions size should be as expected.'
    );
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
      System.assertEquals(
        8,
        cardsModel.cards.size(),
        'The number of cards should be as expected.'
      );
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
        resultException.getMessage(),
        'Error message should be as expected.'
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
      System.assertEquals(
        'Get card list failed',
        resultException.getMessage(),
        'Error message should be as expected.'
      );
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

      System.assertEquals(
        '9741329257534100',
        replaceNumber,
        'Replace number should be as expected.'
      );
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
      System.assertEquals(
        'The replace reason is not valid.',
        errorMsg,
        'Error message should be as expected.'
      );
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
      System.assertEquals(
        'Replace card failed',
        resultException.getMessage(),
        'Error message should be as expected.'
      );
    }
  }

  /**
   * @description fetch invalid card list
   */
  @isTest
  static void cardListCheckNullOnWalletAttribute() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      // GIVEN
      // a user clicks on "Get Card Details" button resulting in a call to getCardList()
      CardListModel cardsModel;

      // WHEN
      // the card Fabric API does not return the 'wallet' attribute at all in the payload for at least one card
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      cardsModel = coachAPI.getCardList('1111');
      Test.stopTest();

      // THEN
      // parsing data on to CardListModel should not fail
      System.assertEquals(
        8,
        cardsModel.cards.size(),
        'Error occured while parsing JSON payload related to cards'
      );
    }
  }

  /**
   * @description fetch valid account buckets, mocked values in force-app/main/default/staticresources/mock_accountBuckets.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void accountBucketsValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      AccountBucketsModel response = coachAPI.getAccountBuckets('1111', 7, '');
      Test.stopTest();

      System.assertEquals(
        7,
        response.account_buckets.size(),
        'Response account buckets size should be as expected.'
      );
    }
  }

  /**
   * @description fetch invalid account buckets
   */
  @isTest
  static void accountBucketsInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      AccountBucketsModel accountBucketsModel;
      HttpCalloutResponse res = getAccountBucketsInvalidResponse();
      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      try {
        accountBucketsModel = coachAPI.getAccountBuckets('1111', 4, '');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals(
        'Get account buckets failed',
        resultException.getMessage(),
        'Error message should be as expected.'
      );
    }
  }

  /**
   * @description fetch valid card control list, mocked values in force-app/main/default/staticresources/mock_cardControlList.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void cardControlListValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    System.runAs(thisUser) {
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      CardControlModel cardControlModel = coachAPI.getCardControlsList('1111');
      Test.stopTest();

      System.assertEquals(
        6,
        cardControlModel.card_controls.size(),
        'Card control mock response should be received'
      );
    }
  }

  /**
   * @description fetch invalid card controls list
   */
  @isTest
  static void cardControlListInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    System.runAs(thisUser) {
      CardControlModel cardControlModel;
      HttpCalloutResponse res = getCardControlsListInvalidResponse();

      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;

      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      try {
        cardControlModel = coachAPI.getCardControlsList('1111');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals(
        'Get card control list failed',
        resultException.getMessage(),
        'Exception should be returned for failed call'
      );
    }
  }

  /**
   * @description call card controls to place temp lock on card, mocked values in force-app/main/default/staticresources/mock_cardControl.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void testLockCardValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    System.runAs(thisUser) {
      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      CardControlModel.CardControlWrapper lockCardResponse = coachAPI.lockCard(
        '746352948',
        '1111'
      );
      Test.stopTest();

      System.assertEquals(
        CardTempLockController.GCT_GLOBAL_CONTROL_STRING,
        lockCardResponse?.card_controls[0].control_type,
        'Successful lock card control response should be received'
      );
    }
  }
  /**
   * @description invalid lock card response
   */
  @isTest
  static void testLockCardInvalidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    System.runAs(thisUser) {
      CardControlModel.CardControlWrapper lockCardResponse;
      HttpCalloutResponse res = lockCardInvalidResponse();

      Service s = ServiceProvider.getService(FabricService.class);
      s.setCalloutResponse(res);
      Exception resultException;

      Test.startTest();
      CoachBankingAPIRepository coachAPI = new CoachBankingAPIRepository();
      try {
        lockCardResponse = coachAPI.lockCard('746352948', '1111');
      } catch (Exception e) {
        resultException = e;
      }
      Test.stopTest();
      System.assertEquals(
        'Place lock on card failed',
        resultException.getMessage(),
        'Exception should be returned for failed call'
      );
    }
  }

  private static HttpCalloutResponse getFinancialAccountInvalidResponse() {
    return generateInvalidResponse('Get accounts failed');
  }

  private static HttpCalloutResponse getTransactionHistoryInvalidResponse() {
    return generateInvalidResponse('Get transaction history failed');
  }

  private static HttpCalloutResponse getAccountBucketsInvalidResponse() {
    return generateInvalidResponse('Get account buckets failed');
  }

  private static HttpCalloutResponse getCardListIncompleteInformation() {
    String responseBody = '{"cards":[{"name":"Bruce Willis","tokenizedCardNumber":"1234567890"}]}';
    return generateValidResponse(responseBody);
  }

  private static HttpCalloutResponse getCardListInvalidResponse() {
    return generateInvalidResponse('Get card list failed');
  }

  private static HttpCalloutResponse replaceCardInvalidResponse() {
    return generateInvalidResponse('Replace card failed');
  }

  private static HttpCalloutResponse getCardControlsValidResponse() {
    String responseBody = '{"card_controls": [{"tokenized_card_number": "5444345466667776","card_controls": {"control_type": "GCT_GLOBAL"}}]}';
    return generateValidResponse(responseBody);
  }

  private static HttpCalloutResponse getCardControlsListInvalidResponse() {
    return generateInvalidResponse('Get card control list failed');
  }

  private static HttpCalloutResponse lockCardInvalidResponse() {
    return generateInvalidResponse('Place lock on card failed');
  }

  private static HttpCalloutResponse generateValidResponse(String bodyString) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = bodyString;
    response.statusCode = 200;
    response.successful = true;
    return response;
  }

  private static HttpCalloutResponse generateInvalidResponse(
    String exceptionMsg
  ) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(exceptionMsg);
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
