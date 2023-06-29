/**
 * @description Test class for {@link COBApplicationTriggerHandler}
 * @author Batya Aisman Sufrin
 * @since 05/2023
 */
@isTest
public with sharing class COBApplicationTriggerHandlerTest {
  private static final Faker FAKER = new Faker('AU');

  private static final String OCV_ID1 = '0123456789';
  private static final String OCV_ID2 = '9876543210';
  private static final String OCV_ID3 = '1237894560';

  private static final List<String> OCV_IDS = new List<String>{
    OCV_ID1,
    OCV_ID2,
    OCV_ID3
  };

  //The number of Accounts with OCV IDS can be less or equal to OCV_IDS_COUNT
  private static final List<String> LINKED_OCV_IDS = new List<String>{
    OCV_ID1
  };

  private static final Integer OCV_IDS_COUNT = OCV_IDS.size();

  private static final String NON_OCR_MIDDLE_NAME = 'Hunky Dory';
  private static final String MATCHING_SERVER_OCR_MIDDLE_NAME = 'Hunky Dory';
  private static final String NON_MATCHING_SERVER_OCR_MIDDLE_NAME = 'Hunky Mory';

  private static final List<String> MATCHING_MIDDLE_NAMES = new List<String>{
    NON_OCR_MIDDLE_NAME,
    MATCHING_SERVER_OCR_MIDDLE_NAME
  };

  private static final List<String> NON_MATCHING_MIDDLE_NAMES = new List<String>{
    NON_OCR_MIDDLE_NAME,
    NON_MATCHING_SERVER_OCR_MIDDLE_NAME
  };

  private static final Map<String, String> OCV_ID_MIDDLE_NAME_TEST = new Map<String, String>{
    OCV_ID1 => COBApplicationActions.YES,
    OCV_ID2 => COBApplicationActions.YES,
    OCV_ID3 => COBApplicationActions.NONE
  };

  private static final Map<String, String> FRAUD_CUSTOMER_DETAILS_TEST = new Map<String, String>{
    OCV_ID1 => COBApplicationActions.YES,
    OCV_ID2 => COBApplicationActions.YES,
    OCV_ID3 => COBApplicationActions.NONE
  };

  private static final Map<String, String> QASADDRESS_TEST = new Map<String, String>{
    OCV_ID1 => COBApplicationActions.YES,
    OCV_ID2 => COBApplicationActions.YES,
    OCV_ID3 => COBApplicationActions.NONE
  };

  private static final Map<String, List<String>> OCV_ID_MIDDLE_NAME_MATCHING = new Map<String, List<String>>{
    OCV_ID1 => MATCHING_MIDDLE_NAMES,
    OCV_ID2 => MATCHING_MIDDLE_NAMES,
    OCV_ID3 => NON_MATCHING_MIDDLE_NAMES
  };

  @testSetup
  static void setup() {
    User integrationUser = createTestUsers();
    assignRelatedPSs(integrationUser);

    System.runAs(integrationUser) {
      List<CustomerOnboardingApplication__c> cobApps = createCOBApps();
      List<COBPrimaryIDDocument__c> cobPIDs = new List<COBPrimaryIDDocument__c>();
      List<COBAddress__c> cobAddresses = new List<COBAddress__c>();
      for (CustomerOnboardingApplication__c cobApp : cobApps) {
        cobPIDs.add(createCOBPid(cobApp));
        cobAddresses.add(createCOBAddress(cobApp));
      }
      insert cobPIDs;
      insert cobAddresses;
    }

    //Create Person Accounts
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      List<AccountShare> accountShareRecords = new List<AccountShare>();
      List<Account> accounts = createPersonAccounts();
      // Criteria-based sharing rule cannot be tested using Apex, hence manually created AccountShare records
      // so Customer Onboarding Integration User can query accounts in test context
      for (Account acc : accounts) {
        accountShareRecords.add(
          new AccountShare(
            AccountId = acc.Id,
            RowCause = Schema.Accountshare.RowCause.Manual,
            UserOrGroupId = integrationUser.Id,
            AccountAccessLevel = 'Read',
            OpportunityAccessLevel = 'None',
            CaseAccessLevel = 'None'
          )
        );
      }
      insert accountShareRecords;
    }
  }

  private static User createTestUsers() {
    Profile profile = CommonUtil.getProfileByName(
      'Minimum Access - External Apps'
    );

    // Create a Customer Onboarding Integration users with 'FraudX Agent' role
    UserRole role = CommonUtil.getUserRoleByDevName('ANZx');

    User testUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'IntegrationUser',
        'ProfileId' => profile.Id,
        'UserRoleId' => role.Id
      }
    );

    insert testUser;
    return testUser;
  }

  private static void assignRelatedPSs(User testUser) {
    // Assign related PSs
    List<String> integrationUserXPSs = new List<String>{
      'API_Only',
      'Customer_Onboarding_Integration',
      'Case_Read_Write_Customer_Onboarding_Integration',
      'Case_Read_Write_KYC_QA',
      //This PS is set to overcome restrictions of System.runAs() that runs the test in USER_MODE
      'Customer_Read_Only'
    };

    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :integrationUserXPSs
    ];

    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      psaList.add(TestUtil.createPSAssignment(testUser.Id, ps.Id));
    }

    insert psaList;
  }

  private static List<CustomerOnboardingApplication__c> createCOBApps() {
    // Create Customer Onboarding applications with OCV IDs
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    for (String ocvId : OCV_IDS) {
      CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
        OCVId__c = ocvId,
        PersonaId__c = FAKER.randomString(15),
        ElectronicVerificationAcknowledged__c = false,
        EquifaxDVSResult__c = COBApplicationActionsHelper.PASS
      );
      cobApps.add(cobApp);
    }

    insert cobApps;
    return cobApps;
  }

  private static List<Account> createPersonAccounts() {
    List<Account> accounts = new List<Account>();
    for (String ocvId : LINKED_OCV_IDS) {
      Account acc = new Account(
        FirstName = FAKER.person.firstName(),
        LastName = FAKER.person.lastName(),
        OCV_ID__c = ocvId,
        ANZx_Customer__c = true,
        RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
      );
      accounts.add(acc);
    }

    insert accounts;
    return accounts;
  }

  private static COBPrimaryIDDocument__c createCOBPid(
    CustomerOnboardingApplication__c cobApp
  ) {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();
    cobPid.CustomerOnboardingApplication__c = cobApp.Id;

    cobPid.MiddleNames__c = OCV_ID_MIDDLE_NAME_MATCHING.get(cobApp.OCVId__c)[0];
    cobPid.MiddleNamesOCRServer__c = OCV_ID_MIDDLE_NAME_MATCHING.get(
      cobApp.OCVId__c
    )[1];

    Boolean isMatched = FRAUD_CUSTOMER_DETAILS_TEST.get(cobApp.OCVId__c) ==
      COBApplicationActions.YES
      ? true
      : false;
    cobPid.IdDocumentType__c = COBApplicationActionsHelper.LICENCE;
    cobPid.LicenceNumber__c = FAKER.randomString(10);
    cobPid.LicenceNumberOCRServer__c = isMatched
      ? cobPid.LicenceNumber__c
      : FAKER.randomString(10);
    cobPid.LicenceCardNumber__c = FAKER.randomString(10);
    cobPid.LicenceCardNumberOCRServer__c = isMatched
      ? cobPid.LicenceCardNumber__c
      : FAKER.randomString(10);
    cobPid.FirstName__c = FAKER.randomString(5);

    return cobPid;
  }

  private static COBAddress__c createCOBAddress(
    CustomerOnboardingApplication__c cobApp
  ) {
    COBAddress__c cobAddress = new COBAddress__c(
      CustomerOnboardingApplication__c = cobApp.id,
      AddressType__c = COBApplicationActions.CURRENT
    );
    cobAddress.AddressQASId__c = QASADDRESS_TEST.get(cobApp.OCVId__c) ==
      COBApplicationActions.YES
      ? FAKER.randomString(15)
      : null;
    return cobAddress;
  }

  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [
      SELECT
        Id,
        OCVId__c,
        PersonaId__c,
        ElectronicVerificationAcknowledged__c,
        VerificationType__c,
        EquifaxDVSResult__c
      FROM CustomerOnboardingApplication__c
    ];
  }

  private static List<Case> getKYCQACases() {
    return [
      SELECT Id, AccountId, OCV_Id__c
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
    ];
  }

  private static List<Case> getKYCQACasesLinkedToAccount() {
    return [
      SELECT Id, AccountId, OCV_Id__c
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.KYCQA_RT_ID AND AccountId != NULL
    ];
  }

  private static Map<String, Case> createKYCQACases(
    List<CustomerOnboardingApplication__c> cobApps
  ) {
    Map<String, Case> ocvIdsKYCQACases = new Map<String, Case>();

    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      Case kycQACase = new Case(
        CustomerOnboardingApplication__c = cobApp.Id,
        RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
        OCV_Id__c = cobApp.OCVId__c
      );

      ocvIdsKYCQACases.put(cobApp.OCVId__c, kycQACase);
    }

    return ocvIdsKYCQACases;
  }

  //Test create KYC QA Case when ElectronicVerificationAcknowledged__c of CustomerOnboardingApplication__c changes to true
  @isTest
  public static void testCreateKYCQACase() {
    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();

    //Set ElectronicVerificationAcknowledged__c to true
    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      cobApp.ElectronicVerificationAcknowledged__c = true;
    }

    User integrationUser = TestUtil.getUserByFirstName('IntegrationUser');

    System.runAs(integrationUser) {
      Test.startTest();
      update cobApps;
      Test.stopTest();
    }

    //get all KYC QA case created
    List<Case> kycQACases = getKYCQACases();
    //get KYC QA case linked to PersonAccount
    List<Case> kycQACasesWithAccount = getKYCQACasesLinkedToAccount();
    Assert.areEqual(
      OCV_IDS_COUNT,
      kycQACases.size(),
      OCV_IDS_COUNT + ' new KYC QA cases should have been created.'
    );

    Assert.areEqual(
      LINKED_OCV_IDS.size(),
      kycQACasesWithAccount.size(),
      LINKED_OCV_IDS.size() +
      ' new Person Account linked KYC QA case(s) should have been created.'
    );
  }

  @isTest
  public static void testCreateBaseKYCQACase() {
    Map<Id, CustomerOnboardingApplication__c> oldMap = new Map<Id, CustomerOnboardingApplication__c>(
      getCOBApps()
    );

    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();
    //Set ElectronicVerificationAcknowledged__c to true
    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      cobApp.ElectronicVerificationAcknowledged__c = true;
    }

    Map<String, Case> ocvIdsKYCQACases = COBApplicationActions.createBaseKYCQACase(
      cobApps,
      oldMap
    );

    Assert.isFalse(
      ocvIdsKYCQACases.isEmpty(),
      'The map of OCVIds with Cases shouldn\'t be empty'
    );

    Assert.areEqual(
      OCV_IDS_COUNT,
      ocvIdsKYCQACases.size(),
      'There should be ' +
      OCV_IDS_COUNT +
      ' cases in the map.'
    );
  }

  @isTest
  public static void testCreateBaseKYCQACaseEmptyMap() {
    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();
    Map<Id, CustomerOnboardingApplication__c> oldMap = new Map<Id, CustomerOnboardingApplication__c>(
      cobApps
    );

    Map<String, Case> ocvIdsKYCQACases = COBApplicationActions.createBaseKYCQACase(
      cobApps,
      oldMap
    );

    Assert.isTrue(
      ocvIdsKYCQACases.isEmpty(),
      'The map of OCVIds with Cases should be empty'
    );
  }

  @isTest
  public static void testSetKYCQATestFields() {
    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();
    Map<String, Case> ocvIdsKYCQACases = createKYCQACases(getCOBApps());

    Test.startTest();
    COBApplicationActions.setKYCQAFields(cobApps, ocvIdsKYCQACases);
    Test.stopTest();

    List<Case> linkedKYCQACases = new List<Case>();
    for (Case kycQACase : ocvIdsKYCQACases.values()) {
      if (kycQACase.AccountId != null) {
        linkedKYCQACases.add(kycQACase);
      }

      Assert.areEqual(
        OCV_ID_MIDDLE_NAME_TEST.get(kycQACase.OCV_Id__c),
        kycQACase.Fraud_MiddleNameCheck__c,
        'Middle Name Check should have been set to ' +
        OCV_ID_MIDDLE_NAME_TEST.get(kycQACase.OCV_Id__c)
      );

      Assert.areEqual(
        FRAUD_CUSTOMER_DETAILS_TEST.get(kycQACase.OCV_Id__c),
        kycQACase.Fraud_Customer_Details__c,
        'Fraud Customer Details should have been set to ' +
        FRAUD_CUSTOMER_DETAILS_TEST.get(kycQACase.OCV_Id__c)
      );

      Assert.areEqual(
        QASADDRESS_TEST.get(kycQACase.OCV_Id__c),
        kycQACase.Fraud_PO_Box__c,
        'Fraud PO Box should have been set to ' +
        QASADDRESS_TEST.get(kycQACase.OCV_Id__c)
      );

      Assert.areEqual(
        QASADDRESS_TEST.get(kycQACase.OCV_Id__c),
        kycQACase.Fraud_Address_Valid__c,
        'Fraud Address Valid should have been set to ' +
        QASADDRESS_TEST.get(kycQACase.OCV_Id__c)
      );
    }

    Assert.areEqual(
      LINKED_OCV_IDS.size(),
      linkedKYCQACases.size(),
      LINKED_OCV_IDS.size() +
      ' new Person Account linked KYC QA case(s) should have been created.'
    );
  }
}
