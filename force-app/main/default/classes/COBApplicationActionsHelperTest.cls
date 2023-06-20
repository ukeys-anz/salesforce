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
    '9876543210',
    '9876543211',
    '9876543212'
  };

  private static final String LICENCE_TYPE = 'Licence';
  private static final String PASSPORT_TYPE = 'Passport';

  private static final List<String> ID_DOC_TYPE = new List<String>{
    LICENCE_TYPE,
    PASSPORT_TYPE
  };

  private static final Integer OCV_IDS_COUNT = OCV_IDS.size();
  private static final Map<String, String> OCV_ID_VERIFICATION_TYPES = new Map<String, String>{
    '0123456789' => 'MANUAL',
    '9876543210' => 'UNSPECIFIED',
    '9876543211' => 'ASSISTED',
    '9876543212' => 'STP'
  };

  @TestSetup
  private static void makeData() {
    List<Account> personAccounts = new List<Account>();
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    List<COBPrimaryIDDocument__c> cobPids = new List<COBPrimaryIDDocument__c>();

    for (String ocvId : OCV_IDS) {
      personAccounts.add(createPersonAccount(ocvId));
      cobApps.add(createCOBApp(ocvId));
    }

    insert personAccounts;
    insert cobApps;

    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      for (String idDocType : ID_DOC_TYPE) {
        cobPids.add(createCOBPid(cobApp.id, idDocType));
      }
    }
    insert cobPids;
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
      PersonaId__c = FAKER.randomString(15),
      VerificationType__c = OCV_ID_VERIFICATION_TYPES.get(ocvId)
    );
  }

  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [
      SELECT Id, OCVId__c, PersonaId__c, VerificationType__c
      FROM CustomerOnboardingApplication__c
    ];
  }

  private static COBPrimaryIDDocument__c createCOBPid(
    Id cobAppId,
    String idDocType
  ) {
    return new COBPrimaryIDDocument__c(
      CustomerOnboardingApplication__c = cobAppId,
      IdDocumentType__c = idDocType
    );
  }

  private static List<COBPrimaryIDDocument__c> getCOBPIds(String idDocType) {
    return [
      SELECT Id, CustomerOnboardingApplication__c, IdDocumentType__c
      FROM COBPrimaryIDDocument__c
      WHERE IdDocumentType__c = :idDocType
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

      Assert.areEqual(
        COBApplicationActionsHelper.VERIFICATION_TYPE_PRIORITY.get(
          cobApp.VerificationType__c
        ),
        kycQACase.Priority,
        'The priority should be ' + kycQACase.Priority
      );
    }
  }

  @isTest
  private static void testGetAccountsByOCVIds() {
    Test.startTest();
    List<Account> accountsByOCVIds = COBApplicationActionsHelper.getAccountsByOCVIds(
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
  private static void testGetAccountsByOCVIdsEmptySet() {
    List<Account> accountsByOCVIds = COBApplicationActionsHelper.getAccountsByOCVIds(
      new Set<String>()
    );

    Assert.isTrue(
      accountsByOCVIds.isEmpty(),
      'There should be an empty list of Accounts.'
    );
  }

  @isTest
  private static void testGetCOBPIDsByOCVIds() {
    DateTime testCreatedDate = DateTime.now().addDays(-1);

    List<COBPrimaryIDDocument__c> licenceCOBPids = getCOBPIds(LICENCE_TYPE);
    for (COBPrimaryIDDocument__c cobPid : licenceCOBPids) {
      Test.setCreatedDate(cobPid.Id, testCreatedDate);
    }

    Test.startTest();
    List<COBPrimaryIDDocument__c> latestCOBPIDs = COBApplicationActionsHelper.getCOBPIDsByOCVIds(
      OCV_IDS
    );
    Test.stopTest();

    Assert.areEqual(
      OCV_IDS_COUNT,
      latestCOBPIDs.size(),
      'There should be only one (latest) COB Primary ID Document per COB App'
    );

    for (COBPrimaryIDDocument__c cobPid : latestCOBPIDs) {
      Assert.areEqual(
        PASSPORT_TYPE,
        cobPid.IdDocumentType__c,
        'ID Document Type should be ' + PASSPORT_TYPE
      );
    }
  }

  @isTest
  private static void testGetCOBPIDsByOCVIdsEmptySet() {
    List<COBPrimaryIDDocument__c> cobPIDs = COBApplicationActionsHelper.getCOBPIDsByOCVIds(
      new Set<String>()
    );

    Assert.isTrue(
      cobPIDs.isEmpty(),
      'There should be an empty list of COB Primary ID Documents.'
    );
  }
}
