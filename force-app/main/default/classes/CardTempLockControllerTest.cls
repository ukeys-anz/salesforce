/**
 * @author Peter Charalambous
 * @since 2021
 * @description CardTempLockControllerTest is the test class to cover tests for {@link CardTempLockController}
 */
@isTest
public with sharing class CardTempLockControllerTest {
  /**
   * @description test method for lockCard when successful
   */
  @isTest
  public static void validResponse() {
    Test.startTest();
    Boolean response = CardTempLockController.lockCard('746352948', '1111');
    System.assertEquals(true, response, 'Card should be locked');
    Test.stopTest();
  }
}
