/**
 * @description Test class for {@link COBApplicationTriggerHandler}
 * @author Batya Aisman Sufrin
 * @since 05/2023
 */
@isTest
public with sharing class COBApplicationTriggerHandlerTest {
  private static final Faker FAKER = new Faker('AU');
  private static final List<String> OCV_IDS = new List<String>{
    '0123456789',
    '9876543210',
    '1237894560'
  };

  private static final Integer OCV_IDS_COUNT = OCV_IDS.size();

  //The number of Accounts with OCV IDS can be less or equal to OCV_IDS_COUNT
  private static final Integer ACCOUNTS_WITH_OCV_IDS_NUMBER = 1;

  @testSetup
  static void setup() {
    User integrationUser = createTestUsers();
    assignRelatedPSs(integrationUser);

    System.runAs(integrationUser) {
      createCOBApps();
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
      'Case_Read_Write_KYC_QA'
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

  private static void createCOBApps() {
    // Create Customer Onboarding applications with OCV IDs
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    for (String ocvId : OCV_IDS) {
      CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
        OCVId__c = ocvId,
        PersonaId__c = FAKER.randomString(15),
        ElectronicVerificationAcknowledged__c = false
      );
      cobApps.add(cobApp);
    }

    insert cobApps;
  }

  private static List<Account> createPersonAccounts() {
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < ACCOUNTS_WITH_OCV_IDS_NUMBER; i++) {
      Account acc = new Account(
        FirstName = FAKER.person.firstName(),
        LastName = FAKER.person.lastName(),
        OCV_ID__c = OCV_IDS[i],
        ANZx_Customer__c = true,
        RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
      );
      accounts.add(acc);
    }

    insert accounts;
    return accounts;
  }

  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [
      SELECT Id, OCVId__c, PersonaId__c, ElectronicVerificationAcknowledged__c
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
  }
}
