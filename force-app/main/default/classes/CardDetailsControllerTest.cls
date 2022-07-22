@isTest
public with sharing class CardDetailsControllerTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'View_Card_Details' });
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
}
