/**
 * @author Peter Charalambous
 * @since 2021
 * @description CardReplaceControllerTest is the test class to cover tests for {@link CardReplaceController}
 */
@isTest
public with sharing class CardReplaceControllerTest {
  /**
   * @description test method for replaceCard when successful
   */
  @isTest
  public static void validResponse() {
    Test.startTest();
    String result = CardReplaceController.replaceCard('1111', '1234', 'stolen');
    Test.stopTest();

    System.assertEquals('9741329257534100', result);
  }
}
