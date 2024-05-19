/**
 * @author Anuja Vats
 * @since May 2024
 * @description test class for SNOWIntegrationModel class
 * @group Models
 */
@isTest
public with sharing class SNOWIntegrationModelTest {
  static String responseJson = '{ "result": [ { "number": "IRE0073261", "event_type": "1", "argument": "xyz"} ] }';

  static String emptyResponseJson = '{ "result": [] }';

  @isTest
  static void testParseResponseJson() {
    SNOWIntegrationModel obj = SNOWIntegrationModel.parse(responseJson);
    System.assert(obj != null, 'The SNOWIntegrationModel should not be null.');
    System.assertEquals(
      obj.result.size(),
      1,
      'The size of the result should be 1'
    );
  }

  @isTest
  static void testParseEmptyResponseJson() {
    SNOWIntegrationModel obj = SNOWIntegrationModel.parse(emptyResponseJson);
    System.assert(obj != null, 'The SNOWIntegrationModel should not be null.');
    System.assertEquals(
      obj.result.size(),
      0,
      'The size of the result should be 0 for empty response'
    );
  }
}
