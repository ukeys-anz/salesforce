@isTest
public with sharing class CardDetailsControllerTest {
  
  public static final String MOCK_TOKENIZED_CARD_NUMBER = '8051997368527878';
  public static final String MOCK_PRIVATE_KEY = 'O0zkiWYRjkrVisuHCb3iUzp3E9CekUH6R7s6lpp2XZE=';
  
  static Lib_MockProvider vaultServiceRepoMock;

  static void registerMocks() {
    vaultServiceRepoMock = Lib_MockProvider.forType(VaultServiceRepository.class);
  }
  
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'View_Card_Details', 'View_Card_Number' });
  }
  /**
   * @description test method for getCardList when successful
   */
  @isTest
  public static void testGetCardList() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      CardListModel cardList = CardDetailsController.getCardList('1234');
      Test.stopTest();

      System.assertNotEquals(
        cardList,
        null,
        'Mock card list should be returned'
      );

      System.assertNotEquals(
        cardList.cards[0].cardControlsList,
        null,
        'Mock card control list should be returned'
      );
      System.assertNotEquals(
        cardList.cards[1].cardControlsList,
        null,
        'Mock card control list should be returned'
      );
      System.assertEquals(
        cardList.cards[2].cardControlsList,
        null,
        'Mocked card control list should be null when card_controls_enabled is false'
      );
    }
  }

  /**
   * @description test method for getCardControlsList when successful
   */
  @isTest
  public static void testGetCardControlsList() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    System.runAs(thisUser) {
      Test.startTest();
      CardControlModel result = CardDetailsController.getCardControlsList(
        '1111'
      );
      Test.stopTest();

      System.assertEquals(
        6,
        result.card_controls.size(),
        'Card control mock response should be received'
      );
    }
  }

    /**
   * @description test method for getFullCardNumberDetails when successful
   */
  @isTest
  public static void testGetFullCardNumberDetailsValid() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
    registerMocks();
    vaultServiceRepoMock.mock(
      'retrievePrivateKey',
      MOCK_PRIVATE_KEY
    );
      Test.startTest();
      String detokenizedCardNumber = CardDetailsController.getFullCardNumberDetails(
        '1111',
        MOCK_TOKENIZED_CARD_NUMBER
      );
      Test.stopTest();

      Assert.areEqual(
        MOCK_TOKENIZED_CARD_NUMBER, 
        detokenizedCardNumber,
        'Full Card Number mock response should be received'
      );
    }
  }
  /**
   * @description test method for getFullCardNumberDetails when successful
   */
  @isTest
  public static void testGetFullCardNumberDetailsInValid() {
    Exception resultException;
    Test.startTest();
    try{
        CardDetailsController.getFullCardNumberDetails(
            '1111',
            MOCK_TOKENIZED_CARD_NUMBER
        );
    }
    catch (Exception objException) {
        resultException = objException;
    }
    Test.stopTest();
    Assert.areEqual(
        resultException.getMessage(),
        'User does not have the get full card number permission',
        'Exception was expected'
    );
  }
}