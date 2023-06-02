/**
 * @author Batya Aisman Sufrin
 * @date May 2023
 * @description Test class for {@link COBApplicationActionsHelper}
 * @group ANZx
 */
@isTest
public with sharing class COBApplicationActionsHelperTest {
  private static final Faker FAKER = new Faker('AU');
  private static final Set<String> OCV_IDS = new Set<String>{
    '0123456789',
    '9876543210'
  };

  private static final Integer OCV_IDS_COUNT = OCV_IDS.size();

  @TestSetup
  private static void makeData() {
    List<Account> personAccounts = new List<Account>();
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();

    for (String ocvId : OCV_IDS) {
      personAccounts.add(createPersonAccount(ocvId));
      cobApps.add(createCOBApp(ocvId));
    }

    insert personAccounts;
    insert cobApps;
  }

  private static Account createPersonAccount(String ocvId) {
    Account acc = new Account(
      FirstName = FAKER.person.firstName(),
      LastName = FAKER.person.lastName(),
      OCV_ID__c = ocvId,
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    );

    return acc;
  }

  private static CustomerOnboardingApplication__c createCOBApp(String ocvId) {
    return new CustomerOnboardingApplication__c(
      OCVId__c = ocvId,
      PersonaId__c = FAKER.randomString(15)
    );
  }

  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [
      SELECT Id, OCVId__c, PersonaId__c
      FROM CustomerOnboardingApplication__c
    ];
  }

  @isTest
  private static void testCreateKYCQACase() {
    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();

    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      Case kycQACase = COBApplicationActionsHelper.createKYCQACase(cobApp);

      Assert.areEqual(
        cobApp.OCVId__c,
        kycQACase.OCV_Id__c,
        'The Case OCV ID should have been the same as COB App OCV Id'
      );
      Assert.areEqual(
        cobApp.PersonaId__c,
        kycQACase.PersonaId__c,
        'The Case Persona Id should have been the same as COB App Persona Id'
      );
      Assert.areEqual(
        cobApp.id,
        kycQACase.CustomerOnboardingApplication__c,
        'The Case COB App lookup should have been the same as COB App Id'
      );
    }
  }

  @isTest
  private static void testGetAccountsByOCVID() {
    Test.startTest();
    List<Account> accountsByOCVIds = COBApplicationActionsHelper.getAccountsByOCVID(
      OCV_IDS
    );
    Test.stopTest();

    Assert.areEqual(
      OCV_IDS_COUNT,
      accountsByOCVIds.size(),
      'There should be ' +
      OCV_IDS_COUNT +
      ' accounts.'
    );
  }

  @isTest
  private static void testGetAccountsByOCVIDEmptySet() {
    List<Account> accountsByOCVIds = COBApplicationActionsHelper.getAccountsByOCVID(
      new Set<String>()
    );

    Assert.isTrue(
      accountsByOCVIds.isEmpty(),
      'There should be an empty list of Accounts.'
    );
  }
}
