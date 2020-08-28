/**
 *
 * @author Lance Shi
 * @since 04/2020
 * @description TransactionHistoryControllerTest is the test class to cover tests for {@link TransactionHistoryController}
 */
@isTest
public with sharing class TransactionHistoryControllerTest {
  /**
   * @description testGetResponse is to test the generation of transaction history string is valid
   */
  @isTest
  public static void testGetResponse() {
    String resp = TransactionHistoryController.getJsonResponse(); //The actuall controller class will be written when he endpoint is ready. This is a dummy test method only
    System.assertNotEquals(null, resp);
  }
}
