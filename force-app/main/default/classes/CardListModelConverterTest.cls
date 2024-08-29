/**
 *
 * @author Nilesh
 * @since 08/2024
 * @description CardListModelConverterTest is the test class to cover tests for CardListModelV1 and CardListModelConverterTest
 */
@isTest
public with sharing class CardListModelConverterTest {
  private static final StaticResource STATIC_RESOURCE_FOR_CARD_LIST_MOCK = [
    SELECT body
    FROM StaticResource
    WHERE Name = 'mock_cardList'
  ];
  private static final Map<String, String> MAP_OF_ACCOUNT_NUMBER_AND_OWNERSHIP = new Map<String, String>{
    '390992614' => 'SOLE'
  };
  @isTest
  static void testParse() {
    Test.startTest();
    CardListModel cardListModelObj = CardListModelV1.parse(
      STATIC_RESOURCE_FOR_CARD_LIST_MOCK.body.toString(),
      MAP_OF_ACCOUNT_NUMBER_AND_OWNERSHIP
    );
    Test.stopTest();
    String statusOfCard = cardListModelObj.cards[0].status;
    Assert.isTrue(statusOfCard != null, 'Account Number should not be null');
  }

  @isTest
  static void testSetAccountTypeOfCard() {
    List<String> listOfAccountNumbers = new List<String>{
      '390992614',
      '390992615'
    };
    Test.startTest();
    String updatedAccoutType = CardListModelConverter.setAccountTypeOfCard(
      listOfAccountNumbers,
      MAP_OF_ACCOUNT_NUMBER_AND_OWNERSHIP
    );
    Test.stopTest();
    Assert.isTrue(
      updatedAccoutType == 'Sole',
      'Account type should be Sole for this Account'
    );
  }

  @isTest
  static void testTrimAccountNumber() {
    List<String> listOfAccountNumbers = new List<String>{
      'accounts/390992614',
      'accounts/390992615'
    };
    Test.startTest();
    List<String> listOfTrimmedAccountNumbers = CardListModelConverter.trimAccountNumber(
      listOfAccountNumbers
    );
    Test.stopTest();
    Assert.isTrue(
      listOfTrimmedAccountNumbers[0] == '390992614',
      'Account Number should be trimmed'
    );
  }
}
