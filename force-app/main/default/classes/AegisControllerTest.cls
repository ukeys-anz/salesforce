/**
 * @author Sneha Malik
 * @since  Jan 2023
 * @description Test class to cover tests for {@link AegisController}
 */
@isTest
public with sharing class AegisControllerTest {
  /**
   * @description Setup common test data
   */

  @testSetup
  public static void setup() {
    Faker faker = new Faker('AU');
    // Insert Person Account
    Account personAcc = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId(),
      FirstName = Faker.randomString(5),
      LastName = Faker.randomString(5),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = faker.randomString(15),
      PersonMobilePhone = '0434222333',
      PPID__C = 'CHc6ad9b34eb3e4788a12eb1caa07aefd5'
    );
    insert personAcc;
    Aegis_Env_Setting__c aegisList = new Aegis_Env_Setting__c(
      Name = 'Prod',
      Env_Name__c = 'Prod',
      Aegis_URL__c = 'https://Prod.com'
    );
    insert aegisList;
  }

  /**
   * @description Test all parameters exist in URL for redirect.
   */
  @isTest
  static void testURLparameters() {
    Test.StartTest();
    List<Account> al = [
      SELECT ID, Name, PersonMobilePhone
      FROM Account
      LIMIT 1
    ];
    Account testAccount = al[0];
    //Visualforce page ref with Account ID parameter
    String test1Str = AegisController.getAccount(testAccount.Id);
    String identifierVal = EncodingUtil.base64Encode(
      blob.valueof(testAccount.PersonMobilePhone)
    );
    Map<String, Aegis_Env_Setting__c> customSettingMap = Aegis_Env_Setting__c.getAll();
    String aegisURL = '';
    for (Aegis_Env_Setting__c custSetting : customSettingMap.values()) {
      aegisURL = custSetting.Aegis_URL__c;
    }
    aegisURL +=
      '/search-users?identifier=' +
      identifierVal +
      '&azure_token=SampleTokenID';
    String errorStr = 'Error in fetching session token. Please try sign in again or Contact your Salesforce administrator for help.';
    system.assertEquals(errorStr, test1Str);

    String test2Str = AegisController.getAegisURL(
      identifierVal,
      'SampleTokenID'
    );
    system.assertEquals(aegisURL, test2Str);
    Test.stopTest();
  }
}
