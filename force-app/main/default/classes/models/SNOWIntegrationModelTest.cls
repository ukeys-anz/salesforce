/**
 * @author Anuja Vats
 * @since May 2024
 * @description test class for SNOWIntegrationModel class
 * @group Models
 */
@isTest
public with sharing class SNOWIntegrationModelTest {
  static String responseJson = '{ "result": [ { "number": "IRE0073261", "event_type": "1", "argument": "xyz"} ] }';
    
@isTest
static void testParseResponseJson() {
   	SNOWIntegrationModel obj = SNOWIntegrationModel.parse(responseJson);
    System.assertEquals(obj.result.size(), 1,
      'The size of the result should be 1'
    );
    System.assertEquals('IRE0073261',
       obj.result[0].eventNumber,
       'Risk Event Id Matches'
    );
  } 
}