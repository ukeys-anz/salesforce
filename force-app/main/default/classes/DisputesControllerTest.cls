/**
 * @author Emma Bindi
 * @date July 2022
 * @description Test class for {@link DisputesController}
 */
@isTest
public with sharing class DisputesControllerTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'Raise_Dispute' });
  }

  /**
   * @description fetch search tokenized card, mocked values in force-app/main/default/staticresources/mock_searchTokenizedCard.json
   * called in force-app/main/default/classes/services/FabricServiceMock.cls
   */
  @isTest
  static void getTokenizedCardNumberValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    System.runAs(thisUser) {
      Test.startTest();
      String tokenizedCardNumber = DisputesController.getTokenizedCardNumber(
        '1111',
        'f5491d5d-06fa-48ba-af94-ccaddebfe744'
      );

      Test.stopTest();
      System.assertEquals(
        '8051997368527878',
        tokenizedCardNumber,
        'Tokenized card number from mock response should be received'
      );
    }
  }
}
