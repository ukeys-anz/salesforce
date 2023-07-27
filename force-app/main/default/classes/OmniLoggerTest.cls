/**
 * @author Nagendra Singh
 * @since 06/2023
 * @description  Test clas for OmniLogger to check if callable interface calls correct method based on params.
 */
@isTest
private class OmniLoggerTest {
  static User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();

  @isTest
  static void testIfErrorLogsAreGettingCreated() {
    System.runAs(ccrmUser) {
      OmniLogger omniloggercallable = new OmniLogger();

      Map<String, Object> params = new Map<String, Object>();
      params.put(
        'input',
        new Map<String, Object>{ 'testparaminput' => 'testparaminputvalue' }
      );
      params.put('output', new Map<String, Object>());
      params.put('options', new Map<String, Object>());

      Test.startTest();
      omniloggercallable.call('insertError', params);
      Test.stopTest();
      System.assertEquals(
        1,
        [SELECT Id FROM Log__c].size(),
        'A Log should be created'
      );
    }
  }
}
