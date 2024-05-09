/**
 * @author Anuja Vats
 * @since May 2024
 * @description test class for IDRSNOWIntegrationModal class
 * @group Models
 */
@isTest
public with sharing class IDRSNOWIntegrationModalTest {
   static String json =
      '{ "result": [ { "number": "IRE0073261", "event_type": "1", "argument": "xyz"} ] }';
    
@isTest
  static void testParse() {
      System.debug('json '+json);
   		IDRSNOWIntegrationModal obj = IDRSNOWIntegrationModal.parse(json);
   	 System.assert(obj != null,
      'The IDRSNOWIntegrationModalTest should not be null.'
    );
  }
}