@SuppressWarnings('PMD.CyclomaticComplexity')
@IsTest
public with sharing class AutoKYCQACaseActionsTest {
  private static final Faker FAKER = new Faker('AU');
  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static final String MOBILE1 = '61412121212';
  private static final String MOBILE2 = '61413131313';
  private static final String MOBILE3 = '61415151515';

  private static final List<String> COB_MATCHING_MOBILE_NUMBERS = new List<String>{
    MOBILE1,
    MOBILE2,
    MOBILE3
  };

  private static final List<String> CUSTOMER_MATCHING_MOBILE_NUMBERS = new List<String>{
    '+' + MOBILE1,
    '+' + MOBILE2,
    '+' + MOBILE3
  };

  private static final List<String> COB_NOT_MATCHING_MOBILE_NUMBERS = new List<String>{
    '61499999999',
    '61488888888'
  };

  private static final List<String> CUSTOMER_NOT_MATCHING_MOBILE_NUMBERS = new List<String>{
    '+61422222222',
    '+61433333333'
  };
  //---------------------------------------------------

  private static final Group PENDING_KYC_QA_QUEUE = CommonUtil.getQueueByName(
    'Pending_KYC_QA'
  );

  private static final String PERSONA_ID1 = '0123456789';
  private static final String PERSONA_ID2 = '9876543210';
  private static final String PERSONA_ID3 = '9876543211';
  private static final String PERSONA_ID4 = '9876543212';

  private static final Set<String> PERSONA_IDS = new Set<String>{
    PERSONA_ID1,
    PERSONA_ID2,
    PERSONA_ID3,
    PERSONA_ID4
  };
  private static final Integer PERSONA_IDS_COUNT = PERSONA_IDS.size();

  private static final String LICENCE_TYPE = 'Licence';
  private static final String PASSPORT_TYPE = 'Passport';

  private static final List<String> ID_DOC_TYPE = new List<String>{
    LICENCE_TYPE,
    PASSPORT_TYPE
  };

  private static final Map<String, String> PERSONA_ID_VERIFICATION_TYPES = new Map<String, String>{
    PERSONA_ID1 => 'MANUAL',
    PERSONA_ID2 => 'UNSPECIFIED',
    PERSONA_ID3 => 'ASSISTED',
    PERSONA_ID4 => 'STP'
  };

  private static final String FIRST_NAME = 'First Double';
  private static final String MIDDLE_NAMES = '  MiddleOne MiddleTwo  ';
  private static final String LAST_NAME = 'Last Double';
  private static final String DUMMY = 'DUMMY';
  private static final String EMPTY_STR = '';

  @TestSetup
  static void setup() {
    List<CustomerOnboardingApplication__c> cobAppsList = new List<CustomerOnboardingApplication__c>();
    List<COBPrimaryIDDocument__c> cobPidsList = new List<COBPrimaryIDDocument__c>();
    List<COBAddress__c> cobAddressesList = new List<COBAddress__c>();

    for (String personaId : PERSONA_IDS) {
      cobAppsList.add(createCOBAppDetails(personaId));
    }

    insert cobAppsList;

    for (CustomerOnboardingApplication__c cobApp : cobAppsList) {
      for (String idDocType : ID_DOC_TYPE) {
        cobPidsList.add(createCOBPidDetails(cobApp.id, idDocType));
      }
      cobAddressesList.add(
        new COBAddress__c(
          CustomerOnboardingApplication__c = cobApp.id,
          AddressQASId__c = FAKER.randomString(15),
          AddressType__c = COBApplicationActions.CURRENT
        )
      );
    }

    insert cobPidsList;
    insert cobAddressesList;

    makeData(); // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static void makeData() {
    // Insert Account & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      List<CustomerOnboardingApplication__c> cobAppsList = new List<CustomerOnboardingApplication__c>();

      List<Account> personAccsWithMobile = new List<Account>();
      for (String mobileNumber : COB_MATCHING_MOBILE_NUMBERS) {
        cobAppsList.add(createCOBApp(mobileNumber));
      }

      for (String mobileNumber : CUSTOMER_MATCHING_MOBILE_NUMBERS) {
        personAccsWithMobile.add(createPersonAccount(mobileNumber));
      }

      //Add COB apps with not matching mobile Numbers
      for (String mobileNumber : COB_NOT_MATCHING_MOBILE_NUMBERS) {
        cobAppsList.add(createCOBApp(mobileNumber));
      }

      insert cobAppsList;
      insert personAccsWithMobile;

      List<Entitlement> entitlements = CommonUtil.addPersonAccountEntitlements(
        personAccsWithMobile,
        GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME,
        GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
      );
      insert entitlements;

      TestDataFactory.createANZxUser('FraudX_Agent');
    }
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static CustomerOnboardingApplication__c createCOBApp(
    String mobileNumber
  ) {
    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
      SecurityMobile__c = mobileNumber
    );

    return cobApp;
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [SELECT Id, SecurityMobile__c FROM CustomerOnboardingApplication__c];
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static Case createKYCQACase(Id cobAppId, Id caseOwnerId) {
    Case c = new Case(
      Status = GetHelpConstants.OPEN_STATUS,
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      CustomerOnboardingApplication__c = cobAppid,
      OwnerId = caseOwnerId
    );

    return c;
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static List<Case> getKYCQACases() {
    return [
      SELECT Id, AccountId, ContactId, ContactMobile, EntitlementId
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
    ];
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static List<Case> getCasesLinkedWithAccount() {
    return [
      SELECT Id, AccountId, ContactId, ContactMobile, EntitlementId
      FROM Case
      WHERE AccountId != NULL AND ContactId != NULL AND EntitlementId != NULL
    ];
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static List<Case> getCasesWithNoAccount() {
    return [SELECT Id, OwnerId FROM Case WHERE AccountId = NULL];
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static Account createPersonAccount(String mobileNumber) {
    Account acc = new Account(
      FirstName = FAKER.person.firstName(),
      LastName = FAKER.person.lastName(),
      OCV_ID__c = FAKER.randomString(10),
      PersonMobilePhone = mobileNumber,
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    );

    return acc;
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static List<Account> getPersonAccountByMobile(
    List<String> mobilePhones
  ) {
    return [SELECT Id FROM Account WHERE PersonMobilePhone IN :mobilePhones];
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static List<Case> createKYCQACases(Id caseOwnerId) {
    List<CustomerOnboardingApplication__c> cobAppsList = getCOBApps();

    List<Case> kycCases = new List<Case>();
    for (CustomerOnboardingApplication__c cobApp : cobAppsList) {
      kycCases.add(createKYCQACase(cobApp.Id, caseOwnerId));
    }

    insert kycCases;
    return kycCases;
  }

  // TO BE CLEANED UP AFTER NEW KYC IMPLEMENTATION IS RELEASED
  private static List<Case> createKYCQACasesWithAccountAndCOB(Id caseOwnerId) {
    List<Account> accs = getPersonAccountByMobile(
      CUSTOMER_MATCHING_MOBILE_NUMBERS
    );

    List<CustomerOnboardingApplication__c> cobAppsList = getCOBApps();

    List<Case> kycCases = new List<Case>();
    for (Integer i = 0; i < accs.size(); i++) {
      Case c = createKYCQACase(cobAppsList[i].id, caseOwnerId);
      c.AccountId = accs[i].Id;
      kycCases.add(c);
    }

    insert kycCases;
    return kycCases;
  }

  private static CustomerOnboardingApplication__c createCOBAppDetails(
    String personaId
  ) {
    return new CustomerOnboardingApplication__c(
      PersonaId__c = personaId,
      VerificationType__c = PERSONA_ID_VERIFICATION_TYPES.get(personaId)
    );
  }

  private static List<CustomerOnboardingApplication__c> getCOBAppsDetatils() {
    return [
      SELECT Id, OCVId__c, PersonaId__c, VerificationType__c
      FROM CustomerOnboardingApplication__c
    ];
  }

  private static COBPrimaryIDDocument__c createCOBPidDetails(
    Id cobAppId,
    String idDocType
  ) {
    return new COBPrimaryIDDocument__c(
      CustomerOnboardingApplication__c = cobAppId,
      IdDocumentType__c = idDocType
    );
  }

  private static List<COBPrimaryIDDocument__c> getCOBPIdsDetails(
    String idDocType
  ) {
    return [
      SELECT Id, CustomerOnboardingApplication__c, IdDocumentType__c
      FROM COBPrimaryIDDocument__c
      WHERE IdDocumentType__c = :idDocType
    ];
  }

  private static Case createKYCQACaseDetails(Id cobAppId, String personaId) {
    Case c = new Case(
      Status = GetHelpConstants.OPEN_STATUS,
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      CustomerOnboardingApplication__c = cobAppid,
      OwnerId = PENDING_KYC_QA_QUEUE.Id,
      OCV_ID__c = FAKER.randomString(10),
      PersonaAttemptCount__c = personaId,
      PersonaID__c = personaId
    );

    return c;
  }

  private static void constructCOBPidFullName(
    COBPrimaryIDDocument__c cobPid,
    Boolean doesMatch
  ) {
    cobPid.FirstName__c = FIRST_NAME;
    cobPid.MiddleNames__c = MIDDLE_NAMES + (doesMatch ? EMPTY_STR : DUMMY);
    cobPid.LastName__c = LAST_NAME;
  }

  private static void constructCOBPidMiddleNames(
    COBPrimaryIDDocument__c cobPid,
    Boolean doesMatch,
    Boolean isMiddleNamesOCRServerEmpty
  ) {
    cobPid.MiddleNamesOCRMatch__c = doesMatch;
    cobPid.MiddleNamesOCRServer__c = isMiddleNamesOCRServerEmpty
      ? EMPTY_STR
      : MIDDLE_NAMES;
  }

  private static void constructCOBPidFullNameOCRServer(
    COBPrimaryIDDocument__c cobPid,
    Boolean isFirstNameOCRServerEmpty,
    Boolean isLastNameOCRServerEmpty
  ) {
    cobPid.FirstNameOCRServer__c = isFirstNameOCRServerEmpty
      ? EMPTY_STR
      : CommonUtil.buildTrimmedConcatenatedString(
          new List<String>{ FIRST_NAME, MIDDLE_NAMES }
        );
    cobPid.LastNameOCRServer__c = isLastNameOCRServerEmpty
      ? EMPTY_STR
      : LAST_NAME;
  }

  private static void constructCOBPidLicence(
    COBPrimaryIDDocument__c cobPid,
    Boolean doesMatch
  ) {
    cobPid.IdDocumentType__c = AutoKYCQACaseActions.LICENCE;
    cobPid.LicenceNumberOCRMatch__c = doesMatch;
  }

  private static void constructCOBPidPassport(
    COBPrimaryIDDocument__c cobPid,
    Boolean doesMatch
  ) {
    cobPid.IdDocumentType__c = AutoKYCQACaseActions.PASSPORT;
    cobPid.PassportNumberOCRMatch__c = doesMatch;
  }

  private static CustomerOnboardingApplication__c getSharedCOBApp(User usr) {
    List<CustomerOnboardingApplication__c> cobApps = getCOBAppsDetatils();

    // Manually share the COB application with FraudX Agent since criteria based sharing rules are not applied in test context
    CustomerOnboardingApplication__Share cobAppShare = new CustomerOnboardingApplication__Share(
      AccessLevel = 'Read',
      ParentID = cobApps[0].Id,
      UserOrGroupId = usr.Id
    );
    insert cobAppShare;
    return cobApps[0];
  }

  @isTest
  private static void testSetKYCQAFieldsWithNoCOB() {
    Case kycCase = createKYCQACaseDetails(null, null);

    Test.startTest();
    try {
      insert kycCase;
      Assert.fail(
        'Exception should be thrown: ' +
        AutoKYCQACaseActions.KYC_QA_CASE_MUST_BE_LINKED_TO_COB
      );
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage()
          .contains(AutoKYCQACaseActions.KYC_QA_CASE_MUST_BE_LINKED_TO_COB),
        'Error message should be: ' +
        AutoKYCQACaseActions.KYC_QA_CASE_MUST_BE_LINKED_TO_COB
      );
    }
    Test.stopTest();
  }

  @isTest
  private static void testGetCOBAppsByPersonaIds() {
    Test.startTest();
    Map<String, CustomerOnboardingApplication__c> cobAppsMap = AutoKYCQACaseActions.getCOBAppsByPersonaIds(
      PERSONA_IDS
    );
    Test.stopTest();

    Assert.areEqual(
      PERSONA_IDS_COUNT,
      cobAppsMap.size(),
      'There should be a matching number of COB Apps as PersonaId count'
    );
  }

  @isTest
  private static void testGetCOBAppsByPersonaIdsEmptySet() {
    Map<String, CustomerOnboardingApplication__c> cobAppsMap = AutoKYCQACaseActions.getCOBAppsByPersonaIds(
      new Set<String>()
    );

    Assert.isTrue(
      cobAppsMap.isEmpty(),
      'There should be an empty list of COB Applications.'
    );
  }

  @isTest
  private static void testGetCOBPIDsByPersonaIds() {
    DateTime testCreatedDate = DateTime.now().addDays(-1);

    List<COBPrimaryIDDocument__c> licenceCOBPidsList = getCOBPIdsDetails(
      LICENCE_TYPE
    );
    for (COBPrimaryIDDocument__c cobPid : licenceCOBPidsList) {
      Test.setCreatedDate(cobPid.Id, testCreatedDate);
    }

    Test.startTest();
    Map<String, COBPrimaryIDDocument__c> latestCOBPidsMap = AutoKYCQACaseActions.getCOBPIDsByPersonaIds(
      PERSONA_IDS
    );
    Test.stopTest();

    Assert.areEqual(
      PERSONA_IDS_COUNT,
      latestCOBPidsMap.size(),
      'There should be only one (latest) COB Primary ID Document per COB App'
    );

    for (COBPrimaryIDDocument__c cobPid : latestCOBPidsMap.values()) {
      Assert.areEqual(
        PASSPORT_TYPE,
        cobPid.IdDocumentType__c,
        'ID Document Type should be ' + PASSPORT_TYPE
      );
    }
  }

  @isTest
  private static void testGetCOBPIDsByPersonaIdsEmptySet() {
    Map<String, COBPrimaryIDDocument__c> cobPIDsMap = AutoKYCQACaseActions.getCOBPIDsByPersonaIds(
      new Set<String>()
    );

    Assert.isTrue(
      cobPIDsMap.isEmpty(),
      'There should be an empty list of COB Primary ID Documents.'
    );
  }

  @isTest
  private static void testGetCOBAddressByPersonaIdsAddressType() {
    Test.startTest();
    Map<String, COBAddress__c> latestCOBAddressesMap = AutoKYCQACaseActions.getCOBAddressByPersonaIdsAndAddressType(
      PERSONA_IDS,
      AutoKYCQACaseActions.CURRENT
    );
    Test.stopTest();

    Assert.areEqual(
      PERSONA_IDS_COUNT,
      latestCOBAddressesMap.size(),
      'There should be only one (latest) COB Address per COB App'
    );
  }

  @isTest
  private static void testGetCOBAddressByPersonaIdsAddressTypeEmptySet() {
    Map<String, COBAddress__c> cobAddressesMap = AutoKYCQACaseActions.getCOBAddressByPersonaIdsAndAddressType(
      new Set<String>(),
      COBApplicationActions.CURRENT
    );

    Assert.isTrue(
      cobAddressesMap.isEmpty(),
      'There should be an empty list of COB Address.'
    );
  }

  @isTest
  private static void testPopulateFraudCustomerDetails() {
    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
      VerificationType__c = AutoKYCQACaseActions.VERIFICATION_TYPE_ASSISTED
    );
    COBPrimaryIDDocument__c cobPID = new COBPrimaryIDDocument__c(
      IdDocumentType__c = AutoKYCQACaseActions.LICENCE,
      LicenceNumberOCRMatch__c = true
    );
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      AutoKYCQACaseActions.populateFraudCustomerDetails(cobApp, cobPID),
      'Yes when the Verification Type is STP or Assisted and the match on ID Document Numbers.'
    );

    cobPID.LicenceNumberOCRMatch__c = false;
    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      AutoKYCQACaseActions.populateFraudCustomerDetails(cobApp, cobPID),
      'None when the Verification Type is STP or Assisted and mismatch on ID Document Numbers.'
    );

    String firstName = FAKER.randomString(5);
    String middleName = FAKER.randomString(5);
    String lastName = FAKER.randomString(5);
    cobApp.VerificationType__c = 'MANUAL';
    cobPID.FirstName__c = firstName;
    cobPID.MiddleNames__c = middleName;
    cobPID.LastName__c = lastName;
    cobPID.FirstNameOCRServer__c = firstName + ' ' + middleName;
    cobPID.LastNameOCRServer__c = lastName;
    cobPID.DateOfBirthOCRMatch__c = true;
    cobPID.ExpiryDateOCRMatch__c = true;
    cobPID.LicenceNumberOCRMatch__c = true;
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      AutoKYCQACaseActions.populateFraudCustomerDetails(cobApp, cobPID),
      'Yes when the Verification Type is not STP or Assisted and Licence ID customer values matches with Licence ID OCR Server Values, FirstNameOCRServer included firstName and middleName'
    );

    cobPID.FirstNameOCRServer__c = firstName;
    cobPID.MiddleNamesOCRServer__c = middleName;
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      AutoKYCQACaseActions.populateFraudCustomerDetails(cobApp, cobPID),
      'Yes when the Verification Type is not STP or Assisted and Licence ID customer values matches with Licence ID OCR Server Values.'
    );

    cobPID.LicenceNumberOCRMatch__c = false;
    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      AutoKYCQACaseActions.populateFraudCustomerDetails(cobApp, cobPID),
      'None when the Verification Type is not STP or Assisted and Licence ID customer values mismatches with Licence ID OCR Server Values.'
    );

    cobPID.PassportNumberOCRMatch__c = true;
    cobPID.IdDocumentType__c = AutoKYCQACaseActions.PASSPORT;
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      AutoKYCQACaseActions.populateFraudCustomerDetails(cobApp, cobPID),
      'Yes when the Verification Type is not STP or Assisted and Passport ID customer values matches with Passport ID OCR Server Values.'
    );

    cobPID.PassportNumberOCRMatch__c = false;
    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      AutoKYCQACaseActions.populateFraudCustomerDetails(cobApp, cobPID),
      'None when the Verification Type is not STP or Assisted and Passport ID customer values mismatches with Licence ID OCR Server Values.'
    );
  }

  @isTest
  private static void testAreFirstAndLastNamesOCRServerBlank() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidFullNameOCRServer(cobPid, true, true);
    Boolean areFirstAndLastNamesOCRServerBlank = AutoKYCQACaseActions.areFirstAndLastNamesOCRServerBlank(
      cobPid
    );

    Assert.isTrue(
      areFirstAndLastNamesOCRServerBlank,
      'The First and Last Name OCR Server are blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, true, false);
    areFirstAndLastNamesOCRServerBlank = AutoKYCQACaseActions.areFirstAndLastNamesOCRServerBlank(
      cobPid
    );

    Assert.isFalse(
      areFirstAndLastNamesOCRServerBlank,
      'The First Name OCR Server is blank, Last Name OCR Server is not blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    areFirstAndLastNamesOCRServerBlank = AutoKYCQACaseActions.areFirstAndLastNamesOCRServerBlank(
      cobPid
    );

    Assert.isFalse(
      areFirstAndLastNamesOCRServerBlank,
      'The First Name OCR Server is not blank, Last Name OCR Server is blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, false);
    areFirstAndLastNamesOCRServerBlank = AutoKYCQACaseActions.areFirstAndLastNamesOCRServerBlank(
      cobPid
    );

    Assert.isFalse(
      areFirstAndLastNamesOCRServerBlank,
      'The First and Last Name OCR Server are not blank'
    );
  }

  @isTest
  private static void testDoMiddleNamesMatch() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidMiddleNames(cobPid, true, false);
    Boolean doMiddleNamesMatch = AutoKYCQACaseActions.doMiddleNamesMatch(
      cobPid
    );

    Assert.isTrue(
      doMiddleNamesMatch,
      'The Middle Names should match - both provided Middle Names and Middle Names OCR Server are matching'
    );

    constructCOBPidMiddleNames(cobPid, false, false);
    doMiddleNamesMatch = AutoKYCQACaseActions.doMiddleNamesMatch(cobPid);

    Assert.isFalse(
      doMiddleNamesMatch,
      'The Middle Names should not match - both provided Middle Names and Middle Names OCR Server are not matching'
    );

    constructCOBPidMiddleNames(cobPid, true, true);
    doMiddleNamesMatch = AutoKYCQACaseActions.doMiddleNamesMatch(cobPid);

    Assert.isFalse(
      doMiddleNamesMatch,
      'The Middle Names should not match - both provided Middle Names and Middle Names OCR Server are empty'
    );

    constructCOBPidMiddleNames(cobPid, false, true);
    doMiddleNamesMatch = AutoKYCQACaseActions.doMiddleNamesMatch(cobPid);

    Assert.isFalse(
      doMiddleNamesMatch,
      'The Middle Names should not match - Middle Names OCR Server are empty'
    );
  }

  @isTest
  private static void testDoesFullNameMatch() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidFullName(cobPid, true);
    constructCOBPidFullNameOCRServer(cobPid, false, false);
    Boolean doesFullNameMatch = AutoKYCQACaseActions.doesFullNameMatch(cobPid);

    Assert.isTrue(doesFullNameMatch, 'The Full Name should match');

    constructCOBPidFullName(cobPid, false);
    constructCOBPidFullNameOCRServer(cobPid, false, false);
    doesFullNameMatch = AutoKYCQACaseActions.doesFullNameMatch(cobPid);

    Assert.isFalse(doesFullNameMatch, 'The Full Name should not match');
  }

  @isTest
  private static void testDoesLicenceMatch() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidLicence(cobPid, true);
    Boolean doesLicenceMatch = AutoKYCQACaseActions.doesLicenceMatch(cobPid);

    Assert.isTrue(doesLicenceMatch, 'The Licence should match');

    constructCOBPidLicence(cobPid, false);
    doesLicenceMatch = AutoKYCQACaseActions.doesLicenceMatch(cobPid);

    Assert.isFalse(doesLicenceMatch, 'The Licence should not match');
  }

  @isTest
  private static void testDoesPassportMatch() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidPassport(cobPid, true);
    Boolean doesPassportMatch = AutoKYCQACaseActions.doesPassportMatch(cobPid);

    Assert.isTrue(doesPassportMatch, 'The Licence should match');

    constructCOBPidLicence(cobPid, false);
    doesPassportMatch = AutoKYCQACaseActions.doesPassportMatch(cobPid);

    Assert.isFalse(doesPassportMatch, 'The Licence should not match');
  }

  @isTest
  private static void testPopulateMiddleNameCheck() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidFullNameOCRServer(cobPid, true, true);
    String middleNameCheck = AutoKYCQACaseActions.populateMiddleNameCheck(
      cobPid
    );

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      middleNameCheck,
      'The First and Last Name OCR Server are blank - Middle Name Check should be \'None\''
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, true, false);
    middleNameCheck = AutoKYCQACaseActions.populateMiddleNameCheck(cobPid);

    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      middleNameCheck,
      'Both provided Middle Names and Middle Names OCR Server are matching and not empty - Middle Name Check should be \'Yes\''
    );

    constructCOBPidFullNameOCRServer(cobPid, false, false);
    constructCOBPidMiddleNames(cobPid, false, true);
    constructCOBPidFullName(cobPid, true);
    constructCOBPidLicence(cobPid, true);
    middleNameCheck = AutoKYCQACaseActions.populateMiddleNameCheck(cobPid);

    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      middleNameCheck,
      'The Full Name and Licence Number are matching - Middle Name Check should be \'Yes\''
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, false, true);
    constructCOBPidFullName(cobPid, false);
    middleNameCheck = AutoKYCQACaseActions.populateMiddleNameCheck(cobPid);

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      middleNameCheck,
      'The First Name OCR Server is blank, Middle Names and Full Names not matching - Middle Name Check should be \'None\''
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, true, true);
    constructCOBPidFullName(cobPid, true);
    constructCOBPidLicence(cobPid, false);
    middleNameCheck = AutoKYCQACaseActions.populateMiddleNameCheck(cobPid);

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      middleNameCheck,
      'The First Name OCR Server is blank, Middle Names are empty and Full Names are matching, Licence Number is not matching - Middle Name Check should be \'None\''
    );
  }

  @isTest
  private static void testValidateDuplicateKYCQACasePerAccount() {
    // GIVEN KYC QA Case linked to the account
    List<Account> accounts = [
      SELECT Id, Name
      FROM Account
      WHERE ANZx_Customer__c = TRUE
    ];
    Account customerAccount1 = accounts[0];

    User usr = TestDataFactory.getANZxUser('FraudX_Agent');

    // Manually share the account with FraudX Agent since criteria based sharing rules are not applied in test context
    AccountShare accShare = new AccountShare();
    accShare.AccountId = customerAccount1.id;
    accShare.UserOrGroupId = usr.Id;
    accShare.AccountAccessLevel = 'Read';
    accShare.OpportunityAccessLevel = 'Read';
    insert accShare;

    CustomerOnboardingApplication__c cobApp = getSharedCOBApp(usr);

    System.runAs(usr) {
      Case kycqa1 = new Case(
        AccountId = customerAccount1.Id,
        CustomerOnboardingApplication__c = cobApp.id,
        RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
        Status = GetHelpConstants.OPEN_STATUS,
        Origin = 'Origination',
        Priority = 'Medium'
      );
      insert kycqa1;

      // WHEN Try to insert more KYC QA Cases will be linked to the Account
      Case kycqa2 = new Case(
        AccountId = customerAccount1.Id,
        CustomerOnboardingApplication__c = cobApp.id,
        RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
        Status = GetHelpConstants.OPEN_STATUS,
        Origin = 'Origination',
        Priority = 'Medium'
      );

      Test.startTest();
      try {
        insert kycqa2;
        Assert.fail('Failed to detect existing KYC QA case');
      } catch (DmlException e) {
        // THEN the KYC QA is inserted unsuccessful, the exception thrown
        Assert.isTrue(
          e.getMessage().contains(AutoKYCQACaseActions.DUPLICATE_KYCQA_ERROR),
          'Exception thrown, error message does not reflect duplicate KYC QA error'
        );
      }
      Test.stopTest();
    }
  }

  // Test Prevent Duplicate KYC QA Against an COB Application
  @isTest
  private static void testValidateDuplicateKYCQACasePerCOBApp() {
    User usr = TestDataFactory.getANZxUser('FraudX_Agent');
    // GIVEN KYC QA Case linked to the COB application
    CustomerOnboardingApplication__c cobApp = getSharedCOBApp(usr);

    System.runAs(usr) {
      Case kycqa1 = new Case(
        CustomerOnboardingApplication__c = cobApp.Id,
        RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
        Status = GetHelpConstants.OPEN_STATUS,
        Origin = 'Origination',
        Priority = 'Medium'
      );
      insert kycqa1;

      // WHEN Try to insert more KYC QA Cases will be linked to the COB application
      Case kycqa2 = new Case(
        CustomerOnboardingApplication__c = cobApp.Id,
        RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
        Status = GetHelpConstants.OPEN_STATUS,
        Origin = 'Origination',
        Priority = 'Medium'
      );

      Test.startTest();
      try {
        insert kycqa2;
        Assert.fail('Failed to detect existing KYC QA case');
      } catch (DmlException e) {
        // THEN the KYC QA is inserted unsuccessful, the exception thrown
        Assert.isTrue(
          e.getMessage().contains(AutoKYCQACaseActions.DUPLICATE_KYCQA_ERROR),
          'Exception thrown, error message does not reflect duplicate KYC QA error'
        );
      }
      Test.stopTest();
    }
  }
}
