/**
 * @author Sneha Malik
 * @since  Jan 2023
 * @description Test class to cover tests for {@link AegisController}
 */
@isTest
public with sharing class AegisControllerTest {
  private final static Faker TESTFAKER = new Faker('AU');
  private final static string TEST_MOBILE = TESTFAKER.person.phone();
  private static final String TOKEN_ERROR = 'Oh dear! Looks like we\'ve messed up and lost a connection downstream.\nThe quick fix is to sign in again and all should be right.';

  /**
   * @description Setup common test data
   */
  @testSetup
  public static void setup() {
    // Create Person Account with mobile
    Account personAccWithMobile = createPersonAccount(true);
    insert personAccWithMobile;

    CustomerOnboardingApplication__c cobAppWithNoMobile = createCOBApp(false);
    insert cobAppWithNoMobile;

    Aegis_Env_Setting__c aegisEnvSettings = createAegisEnvSettings();
    insert aegisEnvSettings;
  }

  private static Account createPersonAccount(Boolean withMobile) {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account personAcc = new Account();
    personAcc.RecordTypeId = personAccountRecordTypeId;
    personAcc.FirstName = TESTFAKER.randomString(5);
    personAcc.LastName = TESTFAKER.randomString(5);
    personAcc.OCV_ID__c = TESTFAKER.randomString(10);
    personAcc.ANZx_Customer__c = true;
    personAcc.External_Id__c = TESTFAKER.randomString(15);

    if (withMobile == true) {
      personAcc.PersonMobilePhone = TEST_MOBILE;
    }

    return personAcc;
  }

  private static Aegis_Env_Setting__c createAegisEnvSettings() {
    Aegis_Env_Setting__c aegisEnvSettings = new Aegis_Env_Setting__c();
    aegisEnvSettings.Name = AegisController.DATA_SET_NAME;
    aegisEnvSettings.Env_Name__c = 'Prod';
    aegisEnvSettings.Aegis_URL__c = 'https://Prod.com';

    return aegisEnvSettings;
  }

  private static CustomerOnboardingApplication__c createCOBApp(
    Boolean withMobile
  ) {
    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c();

    if (withMobile == true) {
      cobApp.SecurityMobile__c = TEST_MOBILE;
    }

    return cobApp;
  }

  private static Account getPersonAccountWithMobile() {
    Account personAcc = [
      SELECT Id, Name, PersonMobilePhone
      FROM Account
      WHERE PersonMobilePhone != NULL
    ];

    return personAcc;
  }

  private static CustomerOnboardingApplication__c getCobAppWithNoMobile() {
    CustomerOnboardingApplication__c cobApp = [
      SELECT Id, SecurityMobile__c
      FROM CustomerOnboardingApplication__c
      WHERE SecurityMobile__c = NULL
    ];

    return cobApp;
  }

  /**
   * @description Test all parameters exist in URL for redirect.
   */
  @isTest
  static void testURLparameters() {
    String identifierVal = AegisController.getIdentifier(TEST_MOBILE);

    String aegisUrl = AegisController.buildAegisURL(
      identifierVal,
      'SampleTokenID'
    );

    String expectedAegisURL = Aegis_Env_Setting__c.getValues(
        AegisController.DATA_SET_NAME
      )
      ?.Aegis_URL__c;

    expectedAegisURL +=
      '/search-users?identifier=' +
      identifierVal +
      '&azure_token=SampleTokenID';

    Assert.areEqual(
      expectedAegisURL,
      aegisUrl,
      'AegisUrl should have been constracted correctly and be: ' +
      expectedAegisURL
    );
  }

  @isTest
  static void testNoMobileException() {
    CustomerOnboardingApplication__c cobApp = getCobAppWithNoMobile();

    Test.StartTest();
    try {
      AegisController.getAegisUrl(cobApp.Id, AegisController.COB_TYPE);
      Assert.areEqual(
        true,
        false,
        'A NO_MOBILE_ERROR exception should have been thrown'
      );
    } catch (Exception ex) {
      Assert.areEqual(
        AegisController.NO_MOBILE_ERROR,
        ex.getMessage(),
        'A NO_MOBILE_ERROR exception should have been thrown'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testTokenException() {
    Account personAcc = getPersonAccountWithMobile();

    Test.StartTest();
    try {
      //Visualforce page ref with Account ID parameter and Type
      AegisController.getAegisUrl(personAcc.Id, AegisController.ACCOUNT_TYPE);
      Assert.areEqual(
        true,
        false,
        'A TOKEN_ERROR exception should have been thrown'
      );
    } catch (Exception ex) {
      Assert.areEqual(
        TOKEN_ERROR,
        ex.getMessage(),
        'Error message should be: ' + TOKEN_ERROR
      );
    }
    Test.stopTest();
  }
}
