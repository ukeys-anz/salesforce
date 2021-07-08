/**
 * @description Test class for {@link CommonUtil}
 * @author Olivier Saier
 * @since May 2021
 * @group Utils
 */
@isTest
public with sharing class CommonUtilTest {
  @isTest
  static void logAndThrowIAETest() {
    Test.startTest();
    try {
      //WHEN I call logAndThrowIAE
      CommonUtil.logAndThrowIAE(
        'CommonUtilTest',
        'logAndThrowTest',
        'Error message'
      );

      //THEN an InsufficientAccessException exception is thrown
      System.assertEquals(
        true,
        false,
        'An exception should have been caught before reaching this assert.'
      );
    } catch (Exception ex) {
      System.assertEquals(
        'Error message',
        ex.getMessage(),
        'Error message should be thrown'
      );
      System.assertEquals(
        'CommonUtil.InsufficientAccessException',
        ex.getTypeName(),
        'InsufficientAccessException should be thrown'
      );
    }
    Test.stopTest();
  }
}
