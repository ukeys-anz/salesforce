@SuppressWarnings('PMD.CyclomaticComplexity')
@IsTest
public with sharing class AutoKYCQACaseActionsTest {
  private static final Faker FAKER = new Faker('AU');
  private static final String RECTIFY_DEFECT_STATUS = 'Rectify Defect';
  private static final String UNDER_REVIEW_STATUS = 'Under Review';
  private static final String PENDING_DOCUMENTS_STATUS = 'Pending Documents';

  static Lib_MockProvider autoKYCQACaseRepoMock;
  static Lib_MockProvider profileStagingHandlerMock;

  static void registerMocks() {
    autoKYCQACaseRepoMock = Lib_MockProvider.forType(
      AutoKYCQACaseRepository.class
    );
    profileStagingHandlerMock = Lib_MockProvider.forType(
      ProfileStagingHandler.class
    );
  }

  private static final String PERSONA_ID1 = '0123456789';
  private static final String PERSONA_ID2 = '9876543210';

  private static final String PASSPORT_TYPE = 'Passport';
  private static final Map<String, String> PERSONA_ID_VERIFICATION_TYPES = new Map<String, String>{
    PERSONA_ID1 => 'STP',
    PERSONA_ID2 => 'ASSISTED'
  };

  private static final String FIRST_NAME = 'First Double';
  private static final String MIDDLE_NAMES = '  MiddleOne MiddleTwo  ';
  private static final String LAST_NAME = 'Last Double';
  private static final String DUMMY = 'DUMMY';
  private static final String EMPTY_STR = '';

  private static final String CURRENT = 'Current';
  private static final String DOCUMENTS_UPLOADED_STATUS = 'Documents Uploaded';

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

  static CustomerOnboardingApplication__c cob = new CustomerOnboardingApplication__c(
    PersonaId__c = PERSONA_ID1,
    VerificationType__c = PERSONA_ID_VERIFICATION_TYPES.get(PERSONA_ID1)
  );

  static Id cobId = Lib_FakeIdGenerator.getMockId(
    CustomerOnboardingApplication__c.SObjectType
  );
  static CustomerOnboardingApplication__c cobWithPIDPassport = (CustomerOnboardingApplication__c) TestUtil.setFields(
    new CustomerOnboardingApplication__c(
      Id = cobId,
      PersonaId__c = PERSONA_ID1,
      VerificationType__c = PERSONA_ID_VERIFICATION_TYPES.get(PERSONA_ID1)
    ),
    new Map<String, Object>{
      'COBPrimaryIDDocuments__r' => new List<COBPrimaryIDDocument__c>{
        new COBPrimaryIDDocument__c(IdDocumentType__c = PASSPORT_TYPE)
      }
    }
  );

  static COBPrimaryIDDocument__c pidPassport = new COBPrimaryIDDocument__c(
    IdDocumentType__c = PASSPORT_TYPE
  );

  static COBAddress__c addressQAS = new COBAddress__c();

  static CustomerOnboardingApplication__c cobWithAddressCurrent = (CustomerOnboardingApplication__c) TestUtil.setFields(
    new CustomerOnboardingApplication__c(
      Id = cobId,
      PersonaId__c = PERSONA_ID2,
      VerificationType__c = PERSONA_ID_VERIFICATION_TYPES.get(PERSONA_ID2)
    ),
    new Map<String, Object>{
      'COBAddresses__r' => new List<COBAddress__c>{
        new COBAddress__c(AddressType__c = 'Current')
      }
    }
  );

  static Case caseWithNoCob = new Case(CustomerOnboardingApplication__c = null);

  static Account acc = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
    Name = 'Sample Name',
    FinServ__KYCStatus__c = null,
    KYC_Verification_Level__c = null,
    OCV_ID__c = FAKER.randomString(6)
  );

  static Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
  static Case caseWithAccount = new Case(Id = caseId, AccountId = acc.Id);

  static Case caseWithCob = new Case(
    Id = caseId,
    CustomerOnboardingApplication__c = cobId,
    PersonaId__c = PERSONA_ID1
  );

  private static Case constuctCaseWithTestFields(String value) {
    return new Case(
      Id = caseId,
      Fraud_Customer_Details__c = value,
      Fraud_MiddleNameCheck__c = AutoKYCQACaseActions.YES,
      Fraud_Selfie_Comparison_Match__c = AutoKYCQACaseActions.YES,
      Fraud_PO_Box__c = AutoKYCQACaseActions.YES,
      Fraud_Address_Valid__c = AutoKYCQACaseActions.YES,
      Fraud_ID_Legible__c = AutoKYCQACaseActions.YES,
      Fraud_Customer_Photo_Modified__c = AutoKYCQACaseActions.YES,
      Fraud_ID_Not_Picture__c = AutoKYCQACaseActions.YES,
      Fraud_Security_Features__c = AutoKYCQACaseActions.YES
    );
  }

  @isTest
  private static void testSetKYCQAFieldsWithNoCOB() {
    Test.startTest();
    AutoKYCQACaseActions.setKYCQAFields(new List<Case>{ caseWithNoCob });
    Test.stopTest();

    Assert.isTrue(
      caseWithNoCob.hasErrors(),
      'Error should have been set: ' +
      AutoKYCQACaseActions.KYC_QA_CASE_MUST_BE_LINKED_TO_COB
    );
    Assert.areEqual(
      AutoKYCQACaseActions.KYC_QA_CASE_MUST_BE_LINKED_TO_COB,
      caseWithNoCob.getErrors()[0].getMessage(),
      'Error message should be: ' +
      AutoKYCQACaseActions.KYC_QA_CASE_MUST_BE_LINKED_TO_COB
    );
  }

  @isTest
  private static void testSetKYCQAFieldsCOBApp() {
    Map<String, Case> personaIDToKYCCasesMap = new Map<String, Case>{
      PERSONA_ID1 => caseWithCob
    };
    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppsMap = new Map<String, CustomerOnboardingApplication__c>{
      PERSONA_ID1 => cob
    };
    Test.startTest();
    AutoKYCQACaseActions.setKYCQAFieldsCOBApp(
      personaIDToKYCCasesMap,
      personaIDToCOBAppsMap
    );
    Test.stopTest();

    Assert.areEqual(
      AutoKYCQACaseActions.VERIFICATION_TYPE_PRIORITY_MAP.get(
        PERSONA_ID_VERIFICATION_TYPES.get(PERSONA_ID1)
      ),
      caseWithCob.Priority,
      'Priority should have been set to: ' +
      AutoKYCQACaseActions.VERIFICATION_TYPE_PRIORITY_MAP.get(
        PERSONA_ID_VERIFICATION_TYPES.get(PERSONA_ID1)
      )
    );
  }

  @isTest
  private static void testSetKYCQAFieldsCOBAppWitNoCOB() {
    Map<String, Case> personaIDToKYCCasesMap = new Map<String, Case>{
      PERSONA_ID1 => caseWithCob
    };
    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppsMap = new Map<String, CustomerOnboardingApplication__c>{};
    Test.startTest();
    AutoKYCQACaseActions.setKYCQAFieldsCOBApp(
      personaIDToKYCCasesMap,
      personaIDToCOBAppsMap
    );
    Test.stopTest();

    Assert.isNull(
      caseWithCob.Priority,
      'Priority should have been set to Null'
    );
  }

  @isTest
  private static void testSetKYCQAFieldsCOBPID() {
    Map<String, Case> personaIDToKYCCasesMap = new Map<String, Case>{
      PERSONA_ID1 => caseWithCob
    };
    Map<String, CustomerOnboardingApplication__c> personaIDToCOBAppsMap = new Map<String, CustomerOnboardingApplication__c>{
      PERSONA_ID1 => cob
    };
    constructCOBPidFullNameOCRServer(pidPassport, true, true);
    pidPassport.PassportNumberOCRMatch__c = true;
    Map<String, COBPrimaryIDDocument__c> personaIDToPrimaryDocumentMap = new Map<String, COBPrimaryIDDocument__c>{
      PERSONA_ID1 => pidPassport
    };

    Test.startTest();
    AutoKYCQACaseActions.setKYCQAFieldsCOBPID(
      personaIDToKYCCasesMap,
      personaIDToCOBAppsMap,
      personaIDToPrimaryDocumentMap
    );
    Test.stopTest();

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      caseWithCob.Fraud_MiddleNameCheck__c,
      'The First and Last Name OCR Server are blank - Middle Name Check should be \'None\''
    );

    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      caseWithCob.Fraud_Customer_Details__c,
      'The Verification Type is STP and Passport match, the KYC Information & ID Document Type Check should be \'YES\''
    );
  }

  @isTest
  private static void testSetKYCQAFieldsCOBAddress() {
    Map<String, Case> personaIDToKYCCasesMap = new Map<String, Case>{
      PERSONA_ID1 => caseWithCob
    };
    Map<String, COBAddress__c> personaIDToCOBAddresMap = new Map<String, COBAddress__c>{
      PERSONA_ID1 => addressQAS
    };

    Test.startTest();
    AutoKYCQACaseActions.setKYCQAFieldsCOBAddress(
      personaIDToKYCCasesMap,
      personaIDToCOBAddresMap
    );
    Test.stopTest();

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      caseWithCob.Fraud_PO_Box__c,
      'Residential Address - PO Box Check should have been set to: ' +
      AutoKYCQACaseActions.NONE
    );

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      caseWithCob.Fraud_Address_Valid__c,
      'Residential Address - Validity Check should have been set to: ' +
      AutoKYCQACaseActions.NONE
    );
  }

  @isTest
  private static void testSetKYCQAFieldsCOBAddressWithNoAddress() {
    Map<String, Case> personaIDToKYCCasesMap = new Map<String, Case>{
      PERSONA_ID1 => caseWithCob
    };
    Map<String, COBAddress__c> personaIDToCOBAddresMap = new Map<String, COBAddress__c>{};

    Test.startTest();
    AutoKYCQACaseActions.setKYCQAFieldsCOBAddress(
      personaIDToKYCCasesMap,
      personaIDToCOBAddresMap
    );
    Test.stopTest();

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      caseWithCob.Fraud_PO_Box__c,
      'Residential Address - PO Box Check should have been set to: ' +
      AutoKYCQACaseActions.NONE
    );

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      caseWithCob.Fraud_Address_Valid__c,
      'Residential Address - Validity Check should have been set to: ' +
      AutoKYCQACaseActions.NONE
    );
  }

  @isTest
  private static void testGetCOBAppsByPersonaIds() {
    registerMocks();
    autoKYCQACaseRepoMock.mock(
      'queryCOBByPersonaId',
      new List<CustomerOnboardingApplication__c>{ cob }
    );

    Test.startTest();
    Map<String, CustomerOnboardingApplication__c> cobAppsMap = AutoKYCQACaseActions.getCOBAppsByPersonaIds(
      new Set<String>{ PERSONA_ID1, PERSONA_ID2 }
    );
    Test.stopTest();

    Assert.isFalse(
      autoKYCQACaseRepoMock.getHistories('queryCOBByPersonaId').isEmpty(),
      'queryCOBByPersonaId should have been called.'
    );

    Set<String> personaIds = (Set<String>) autoKYCQACaseRepoMock.getHistory(
        'queryCOBByPersonaId'
      )
      .getParam('personaIds');
    Assert.isFalse(
      personaIds.isEmpty(),
      'queryCOBByPersonaId method should have received personaIds.'
    );

    Assert.areEqual(
      PERSONA_ID1,
      cobAppsMap.get(PERSONA_ID1).PersonaId__c,
      'Expected COB with PersonaId: ' + PERSONA_ID1
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
    registerMocks();
    autoKYCQACaseRepoMock.mock(
      'queryCOBWithPIDByPersonaId',
      new List<CustomerOnboardingApplication__c>{ cobWithPIDPassport }
    );

    Test.startTest();
    Map<String, COBPrimaryIDDocument__c> latestCOBPidsMap = AutoKYCQACaseActions.getCOBPIDsByPersonaIds(
      new Set<String>{ PERSONA_ID1, PERSONA_ID2 }
    );
    Test.stopTest();

    Assert.isFalse(
      autoKYCQACaseRepoMock.getHistories('queryCOBWithPIDByPersonaId')
        .isEmpty(),
      'queryCOBWithPIDByPersonaId should have been called.'
    );

    Set<String> personaIds = (Set<String>) autoKYCQACaseRepoMock.getHistory(
        'queryCOBWithPIDByPersonaId'
      )
      .getParam('personaIds');
    Assert.isFalse(
      personaIds.isEmpty(),
      'queryCOBWithPIDByPersonaId method should have received personaIds.'
    );

    Assert.areEqual(
      PASSPORT_TYPE,
      latestCOBPidsMap.get(PERSONA_ID1).IdDocumentType__c,
      'ID Document Type should be ' + PASSPORT_TYPE
    );
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
    registerMocks();
    autoKYCQACaseRepoMock.mock(
      'queryCOBWithCOBAddressByAddresTypeAndPersonaId',
      new List<CustomerOnboardingApplication__c>{ cobWithAddressCurrent }
    );

    Test.startTest();
    Map<String, COBAddress__c> latestCOBAddressesMap = AutoKYCQACaseActions.getCOBAddressByPersonaIdsAndAddressType(
      new Set<String>{ PERSONA_ID1, PERSONA_ID2 },
      CURRENT
    );
    Test.stopTest();

    Assert.isFalse(
      autoKYCQACaseRepoMock.getHistories(
          'queryCOBWithCOBAddressByAddresTypeAndPersonaId'
        )
        .isEmpty(),
      'queryCOBWithCOBAddressByAddresTypeAndPersonaId should have been called.'
    );

    String addressType = (String) autoKYCQACaseRepoMock.getHistory(
        'queryCOBWithCOBAddressByAddresTypeAndPersonaId'
      )
      .getParam('addressType');

    Assert.isFalse(
      String.IsBlank(addressType),
      'queryCOBWithCOBAddressByAddresTypeAndPersonaId method should have received addressType.'
    );

    Assert.areEqual(
      CURRENT,
      latestCOBAddressesMap.get(PERSONA_ID2).AddressType__c,
      'Address Type should be ' + CURRENT
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
    CustomerOnboardingApplication__c cobApp = null;
    COBPrimaryIDDocument__c cobPID = null;
    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      AutoKYCQACaseActions.populateFraudCustomerDetails(cobApp, cobPID),
      'None when the COB Application and COB Primary ID Document are null.'
    );

    cobApp = new CustomerOnboardingApplication__c(
      VerificationType__c = AutoKYCQACaseActions.VERIFICATION_TYPE_ASSISTED
    );
    cobPID = new COBPrimaryIDDocument__c(
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
    COBPrimaryIDDocument__c cobPid = null;
    Boolean areFirstAndLastNamesOCRServerBlank = AutoKYCQACaseActions.areFirstAndLastNamesOCRServerBlank(
      cobPid
    );
    Assert.isTrue(
      areFirstAndLastNamesOCRServerBlank,
      'Blank when the COB Primary ID Document is null'
    );

    cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidFullNameOCRServer(cobPid, true, true);
    areFirstAndLastNamesOCRServerBlank = AutoKYCQACaseActions.areFirstAndLastNamesOCRServerBlank(
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
    COBPrimaryIDDocument__c cobPid = null;
    Boolean doMiddleNamesMatch = AutoKYCQACaseActions.doMiddleNamesMatch(
      cobPid
    );
    Assert.isFalse(
      doMiddleNamesMatch,
      'The Middle Names shouldn\'t match - COB Primary ID Document is null'
    );

    cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidMiddleNames(cobPid, true, false);
    doMiddleNamesMatch = AutoKYCQACaseActions.doMiddleNamesMatch(cobPid);

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
    COBPrimaryIDDocument__c cobPid = null;
    Boolean doesFullNameMatch = AutoKYCQACaseActions.doesFullNameMatch(cobPid);
    Assert.isTrue(
      doesFullNameMatch,
      'The Full Name shouldn match - COB Primary ID Document is null'
    );

    cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidFullName(cobPid, true);
    constructCOBPidFullNameOCRServer(cobPid, false, false);
    doesFullNameMatch = AutoKYCQACaseActions.doesFullNameMatch(cobPid);

    Assert.isTrue(doesFullNameMatch, 'The Full Name should match');

    constructCOBPidFullName(cobPid, false);
    constructCOBPidFullNameOCRServer(cobPid, false, false);
    doesFullNameMatch = AutoKYCQACaseActions.doesFullNameMatch(cobPid);

    Assert.isFalse(doesFullNameMatch, 'The Full Name should not match');
  }

  @isTest
  private static void testDoesLicenceMatch() {
    COBPrimaryIDDocument__c cobPid = null;
    Boolean doesLicenceMatch = AutoKYCQACaseActions.doesLicenceMatch(cobPid);
    Assert.isFalse(
      doesLicenceMatch,
      'The Licence shouldn\'t match - COB Primary ID Document is null'
    );

    cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidLicence(cobPid, true);
    doesLicenceMatch = AutoKYCQACaseActions.doesLicenceMatch(cobPid);

    Assert.isTrue(doesLicenceMatch, 'The Licence should match');

    constructCOBPidLicence(cobPid, false);
    doesLicenceMatch = AutoKYCQACaseActions.doesLicenceMatch(cobPid);

    Assert.isFalse(doesLicenceMatch, 'The Licence should not match');
  }

  @isTest
  private static void testDoesPassportMatch() {
    COBPrimaryIDDocument__c cobPid = null;
    Boolean doesPassportMatch = AutoKYCQACaseActions.doesPassportMatch(cobPid);
    Assert.isFalse(
      doesPassportMatch,
      'The Passport shouldn\'t match - COB Primary ID Document is null'
    );

    cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidPassport(cobPid, true);
    doesPassportMatch = AutoKYCQACaseActions.doesPassportMatch(cobPid);

    Assert.isTrue(doesPassportMatch, 'The Licence should match');

    constructCOBPidLicence(cobPid, false);
    doesPassportMatch = AutoKYCQACaseActions.doesPassportMatch(cobPid);

    Assert.isFalse(doesPassportMatch, 'The Licence should not match');
  }

  @isTest
  private static void testPopulateMiddleNameCheck() {
    COBPrimaryIDDocument__c cobPid = null;
    String middleNameCheck = AutoKYCQACaseActions.populateMiddleNameCheck(
      cobPid
    );

    Assert.areEqual(
      AutoKYCQACaseActions.NONE,
      middleNameCheck,
      'Middle Name Check should be \'None\''
    );

    cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidFullNameOCRServer(cobPid, true, true);
    middleNameCheck = AutoKYCQACaseActions.populateMiddleNameCheck(cobPid);

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
    registerMocks();
    autoKYCQACaseRepoMock.mock(
      'queryKYCQACasesByAccountIds',
      new List<Case>{ caseWithAccount }
    );

    Test.startTest();
    AutoKYCQACaseActions.validateDuplicateKYCQACasePerAccount(
      new List<Case>{ caseWithAccount }
    );
    Test.stopTest();

    Assert.isFalse(
      autoKYCQACaseRepoMock.getHistories('queryKYCQACasesByAccountIds')
        .isEmpty(),
      'queryKYCQACasesByAccountIds should have been called.'
    );

    Assert.isTrue(
      caseWithAccount.hasErrors(),
      'Error should have been set: ' +
      AutoKYCQACaseActions.DUPLICATE_KYCQA_ERROR
    );

    Assert.isTrue(
      caseWithAccount.getErrors()[0]
        .getMessage()
        .contains(AutoKYCQACaseActions.DUPLICATE_KYCQA_ERROR),
      'Error message should be: ' + AutoKYCQACaseActions.DUPLICATE_KYCQA_ERROR
    );
  }

  @isTest
  private static void testValidateDuplicateKYCQACasePerAccountEmpty() {
    registerMocks();
    autoKYCQACaseRepoMock.mock('queryKYCQACasesByAccountIds', new List<Case>());

    Test.startTest();
    AutoKYCQACaseActions.validateDuplicateKYCQACasePerAccount(new List<Case>());
    Test.stopTest();

    Set<Id> accountIds = (Set<Id>) autoKYCQACaseRepoMock.getHistory(
        'queryKYCQACasesByAccountIds'
      )
      .getParam('accountIds');
    Assert.isTrue(accountIds.isEmpty(), 'Query param should be empty');
  }

  @isTest
  private static void testValidateDuplicateKYCQACasePerCOBApp() {
    registerMocks();
    autoKYCQACaseRepoMock.mock(
      'queryKYCQACasesByCOBAppIds',
      new List<Case>{ caseWithCob }
    );

    Test.startTest();
    AutoKYCQACaseActions.validateDuplicateKYCQACasePerCOBApp(
      new List<Case>{ caseWithCob }
    );
    Test.stopTest();

    Assert.isFalse(
      autoKYCQACaseRepoMock.getHistories('queryKYCQACasesByCOBAppIds')
        .isEmpty(),
      'queryKYCQACasesByCOBAppIds should have been called.'
    );

    Assert.isTrue(
      caseWithCob.hasErrors(),
      'Error should have been set: ' +
      AutoKYCQACaseActions.DUPLICATE_KYCQA_ERROR
    );

    Assert.isTrue(
      caseWithCob.getErrors()[0]
        .getMessage()
        .contains(AutoKYCQACaseActions.DUPLICATE_KYCQA_ERROR),
      'Error message should be: ' + AutoKYCQACaseActions.DUPLICATE_KYCQA_ERROR
    );
  }

  @isTest
  private static void testValidateDuplicateKYCQACasePerCOBAppEmpty() {
    registerMocks();
    autoKYCQACaseRepoMock.mock('queryKYCQACasesByCOBAppIds', new List<Case>());

    Test.startTest();
    AutoKYCQACaseActions.validateDuplicateKYCQACasePerCOBApp(new List<Case>());
    Test.stopTest();

    Set<Id> cobAppIds = (Set<Id>) autoKYCQACaseRepoMock.getHistory(
        'queryKYCQACasesByCOBAppIds'
      )
      .getParam('cobAppIds');
    Assert.isTrue(cobAppIds.isEmpty(), 'Query param should be empty');
  }

  @isTest
  private static void testHasKycCheckCompleted() {
    Case theCase = null;
    Boolean hasKycCheckCompleted = AutoKYCQACaseActions.hasKycCheckCompleted(
      theCase
    );
    Assert.isFalse(hasKycCheckCompleted, 'The Case is null');

    theCase = constuctCaseWithTestFields(null);
    hasKycCheckCompleted = AutoKYCQACaseActions.hasKycCheckCompleted(theCase);
    Assert.isFalse(hasKycCheckCompleted, 'Some fields are empty');

    theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.YES);
    hasKycCheckCompleted = AutoKYCQACaseActions.hasKycCheckCompleted(theCase);
    Assert.isTrue(hasKycCheckCompleted, 'All fields are not empty');
  }

  @isTest
  private static void testCanPopulateTestedDate() {
    Case theCase = null;
    Boolean canPopulateTestedDate = AutoKYCQACaseActions.canPopulateTestedDate(
      theCase
    );
    Assert.isFalse(canPopulateTestedDate, 'The Case is null');

    theCase = constuctCaseWithTestFields(null);
    canPopulateTestedDate = AutoKYCQACaseActions.canPopulateTestedDate(theCase);
    Assert.isFalse(canPopulateTestedDate, 'Some fields are empty');

    theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.YES);
    theCase.Fraud_Restraint_Status__c = 'N/A';
    canPopulateTestedDate = AutoKYCQACaseActions.canPopulateTestedDate(theCase);
    Assert.isTrue(canPopulateTestedDate, 'All fields are not empty');
  }

  @isTest
  private static void testUpdateTestedDate() {
    Case theCase = constuctCaseWithTestFields(null);
    AutoKYCQACaseActions.updateTestedDate(new List<Case>{ theCase });
    Assert.isNull(theCase.TestedDate__c, 'The Tasted Date should be null');

    theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.YES);
    theCase.Fraud_Restraint_Status__c = 'N/A';
    AutoKYCQACaseActions.updateTestedDate(new List<Case>{ theCase });
    Assert.isNotNull(
      theCase.TestedDate__c,
      'The Tasted Date should not be null'
    );
  }

  @isTest
  private static void testDowngradeWithNoRecords() {
    registerMocks();
    autoKYCQACaseRepoMock.mock('queryAccounts', new List<Account>());

    Test.startTest();
    AutoKYCQACaseActions.downgrade(new List<Case>(), new Map<Id, Case>());
    Test.stopTest();

    List<Account> records = (List<Account>) profileStagingHandlerMock.getHistory(
        'process'
      )
      .getParam('records');
    Assert.isTrue(records.isEmpty(), 'No records should have been processed');
  }

  @isTest
  private static void testDowngrade() {
    registerMocks();
    autoKYCQACaseRepoMock.mock('queryAccounts', new List<Account>{ acc });

    Case oldCase = new Case();
    oldCase.Id = caseId;

    oldCase.Status = GetHelpConstants.OPEN_STATUS;
    Case theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.NO);
    theCase.Status = RECTIFY_DEFECT_STATUS;

    AutoKYCQACaseActions.downgrade(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );

    Assert.isFalse(
      autoKYCQACaseRepoMock.getHistories('queryAccounts').isEmpty(),
      'queryAccounts should have been called.'
    );

    Assert.isFalse(
      profileStagingHandlerMock.getHistories('process').isEmpty(),
      'processCases should have been called.'
    );

    List<Account> newAccList = (List<Account>) profileStagingHandlerMock.getHistory(
        'process'
      )
      .getParam('records');

    Assert.areEqual(
      AutoKYCQACaseActions.DOWNGRADE_KYC_STATUS,
      newAccList[0].FinServ__KYCStatus__c,
      'KYC Statius should be set to: ' +
      AutoKYCQACaseActions.DOWNGRADE_KYC_STATUS
    );
    Assert.areEqual(
      AutoKYCQACaseActions.DOWNGRADE_KYC_VERIFICATION_LEVEL,
      newAccList[0].KYC_Verification_Level__c,
      'KYC Verification Level should be set to: ' +
      AutoKYCQACaseActions.DOWNGRADE_KYC_VERIFICATION_LEVEL
    );
  }

  @isTest
  private static void testHasKycCheckCompletedWithDefect() {
    Case theCase = constuctCaseWithTestFields(null);
    Boolean hasDefect = AutoKYCQACaseActions.hasKycCheckCompletedWithDefect(
      theCase
    );
    Assert.isFalse(hasDefect, 'One of the test fields is empty');

    theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.NO);
    hasDefect = AutoKYCQACaseActions.hasKycCheckCompletedWithDefect(theCase);
    Assert.isTrue(
      hasDefect,
      'All test fields are not empty and one of them is NO'
    );

    theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.YES);
    hasDefect = AutoKYCQACaseActions.hasKycCheckCompletedWithDefect(theCase);
    Assert.isFalse(
      hasDefect,
      'All test fields are not empty and all of them are YES'
    );
  }

  @isTest
  private static void testFilterDowngradeCases() {
    Case theCase = constuctCaseWithTestFields(null);
    List<Case> downgradeCases = AutoKYCQACaseActions.filterDowngradeCases(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Assert.isTrue(
      downgradeCases.isEmpty(),
      'No defects - One of the test fields is empty'
    );

    theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.YES);
    downgradeCases = AutoKYCQACaseActions.filterDowngradeCases(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Assert.isTrue(
      downgradeCases.isEmpty(),
      'No defects - All test fields are YES'
    );

    Case oldCase = new Case();
    oldCase.Id = caseId;

    oldCase.Status = DOCUMENTS_UPLOADED_STATUS;
    theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.NO);
    theCase.Status = RECTIFY_DEFECT_STATUS;

    downgradeCases = AutoKYCQACaseActions.filterDowngradeCases(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Assert.isTrue(
      downgradeCases.isEmpty(),
      'There are defects - One of the test fields is NO, the case destinatoin staus is Rectify Defect but the case source status is not Open Or Under Review'
    );

    oldCase.Status = GetHelpConstants.OPEN_STATUS;
    theCase = constuctCaseWithTestFields(AutoKYCQACaseActions.NO);
    theCase.Status = RECTIFY_DEFECT_STATUS;

    downgradeCases = AutoKYCQACaseActions.filterDowngradeCases(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Assert.isFalse(
      downgradeCases.isEmpty(),
      'There are defects - One of the test fields is NO, the case destinatoin staus is Rectify Defect and the case source status is Open'
    );
  }

  @isTest
  private static void testCheckValidStatusForDowngrade() {
    Case oldCase = new Case();
    oldCase.Status = DOCUMENTS_UPLOADED_STATUS;

    Case theCase = new Case();
    theCase.Status = RECTIFY_DEFECT_STATUS;
    Boolean isValidStatusForDowngrade = AutoKYCQACaseActions.checkValidStatusForDowngrade(
      theCase,
      oldCase
    );

    Assert.isFalse(
      isValidStatusForDowngrade,
      'The case destinatoin staus is Rectify Defect but the case source status is not Open Or Under Review'
    );

    theCase.Status = PENDING_DOCUMENTS_STATUS;
    isValidStatusForDowngrade = AutoKYCQACaseActions.checkValidStatusForDowngrade(
      theCase,
      oldCase
    );

    Assert.isFalse(
      isValidStatusForDowngrade,
      'The case destinatoin staus is Pending Document but the case source status is not Open Or Under Review'
    );

    oldCase.Status = GetHelpConstants.OPEN_STATUS;
    theCase.Status = RECTIFY_DEFECT_STATUS;
    isValidStatusForDowngrade = AutoKYCQACaseActions.checkValidStatusForDowngrade(
      theCase,
      oldCase
    );

    Assert.isTrue(
      isValidStatusForDowngrade,
      'The case destinatoin staus is Rectify Defect and the case source status is Open'
    );

    oldCase.Status = GetHelpConstants.OPEN_STATUS;
    theCase.Status = PENDING_DOCUMENTS_STATUS;
    isValidStatusForDowngrade = AutoKYCQACaseActions.checkValidStatusForDowngrade(
      theCase,
      oldCase
    );

    Assert.isTrue(
      isValidStatusForDowngrade,
      'The case destinatoin staus is Pending Document and the case source status is Open'
    );

    oldCase.Status = UNDER_REVIEW_STATUS;
    theCase.Status = RECTIFY_DEFECT_STATUS;
    isValidStatusForDowngrade = AutoKYCQACaseActions.checkValidStatusForDowngrade(
      theCase,
      oldCase
    );

    Assert.isTrue(
      isValidStatusForDowngrade,
      'The case destinatoin staus is Rectify Defect and the case source status is Under Review'
    );

    oldCase.Status = UNDER_REVIEW_STATUS;
    theCase.Status = PENDING_DOCUMENTS_STATUS;
    isValidStatusForDowngrade = AutoKYCQACaseActions.checkValidStatusForDowngrade(
      theCase,
      oldCase
    );

    Assert.isTrue(
      isValidStatusForDowngrade,
      'The case destinatoin staus is Pending Document and the case source status is Under Review'
    );
  }

  @isTest
  private static void testBuildDowngradedAccounts() {
    Test.startTest();
    List<Account> accounts = AutoKYCQACaseActions.buildDowngradedAccounts(
      new List<Account>{ acc }
    );
    Test.stopTest();

    Assert.areEqual(
      AutoKYCQACaseActions.DOWNGRADE_KYC_STATUS,
      accounts[0].FinServ__KYCStatus__c,
      'KYC Statius should be set to: ' +
      AutoKYCQACaseActions.DOWNGRADE_KYC_STATUS
    );
    Assert.areEqual(
      AutoKYCQACaseActions.DOWNGRADE_KYC_VERIFICATION_LEVEL,
      accounts[0].KYC_Verification_Level__c,
      'KYC Verification Level should be set to: ' +
      AutoKYCQACaseActions.DOWNGRADE_KYC_VERIFICATION_LEVEL
    );
  }

  @isTest
  private static void testUpgradeWithNoInitialRecords() {
    registerMocks();
    autoKYCQACaseRepoMock.mock('queryAccountsNotExited', new List<Account>());
    autoKYCQACaseRepoMock.mock(
      'queryExitedAccountsByOcvIds',
      new List<Account>()
    );

    Test.startTest();
    AutoKYCQACaseActions.upgrade(new List<Case>(), new Map<Id, Case>());
    Test.stopTest();

    List<Account> records = (List<Account>) profileStagingHandlerMock.getHistory(
        'process'
      )
      .getParam('records');
    Assert.isTrue(records.isEmpty(), 'No records should have been processed');
  }

  @isTest
  private static void testUpgradeWitNoFinalRecordsStatusClosedNotChanged() {
    registerMocks();
    autoKYCQACaseRepoMock.mock('queryAccountsNotExited', new List<Account>());
    autoKYCQACaseRepoMock.mock(
      'queryExitedAccountsByOcvIds',
      new List<Account>()
    );

    Case oldCase = new Case();
    oldCase.Id = caseId;

    oldCase.Status = GetHelpConstants.CLOSED_STATUS;
    caseWithAccount.Fraud_Defects_Rectified__c = AutoKYCQACaseActions.YES;
    caseWithAccount.Status = GetHelpConstants.CLOSED_STATUS;

    Test.startTest();
    AutoKYCQACaseActions.upgrade(
      new List<Case>{ caseWithAccount },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    Set<Id> accountIds = (Set<Id>) autoKYCQACaseRepoMock.getHistory(
        'queryAccountsNotExited'
      )
      .getParam('accountIds');
    Assert.isTrue(accountIds.isEmpty(), 'No accounts should have been queried');
    List<Account> records = (List<Account>) profileStagingHandlerMock.getHistory(
        'process'
      )
      .getParam('records');
    Assert.isTrue(records.isEmpty(), 'No records should have been processed');
  }

  @isTest
  private static void testUpgradeWitNoFinalRecordsExitFlagTrue() {
    registerMocks();
    autoKYCQACaseRepoMock.mock('queryAccountsNotExited', new List<Account>());
    autoKYCQACaseRepoMock.mock(
      'queryExitedAccountsByOcvIds',
      new List<Account>()
    );

    Case oldCase = new Case();
    oldCase.Id = caseId;

    oldCase.Status = RECTIFY_DEFECT_STATUS;
    caseWithAccount.Fraud_Defects_Rectified__c = AutoKYCQACaseActions.YES;
    caseWithAccount.Status = GetHelpConstants.CLOSED_STATUS;

    Test.startTest();
    AutoKYCQACaseActions.upgrade(
      new List<Case>{ caseWithAccount },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    List<Account> records = (List<Account>) profileStagingHandlerMock.getHistory(
        'process'
      )
      .getParam('records');
    Assert.isTrue(records.isEmpty(), 'No records should have been processed');
  }

  @isTest
  private static void testUpgrade() {
    registerMocks();
    autoKYCQACaseRepoMock.mock(
      'queryAccountsNotExited',
      new List<Account>{ acc }
    );
    autoKYCQACaseRepoMock.mock(
      'queryExitedAccountsByOcvIds',
      new List<Account>()
    );

    Case oldCase = new Case(Id = caseId, Status = RECTIFY_DEFECT_STATUS);
    caseWithAccount.Fraud_Defects_Rectified__c = AutoKYCQACaseActions.YES;
    caseWithAccount.Status = GetHelpConstants.CLOSED_STATUS;

    AutoKYCQACaseActions.upgrade(
      new List<Case>{ caseWithAccount },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Assert.isFalse(
      autoKYCQACaseRepoMock.getHistories('queryAccountsNotExited').isEmpty(),
      'queryAccountsNotExited should have been called.'
    );

    Assert.isFalse(
      profileStagingHandlerMock.getHistories('process').isEmpty(),
      'processCases should have been called.'
    );

    List<Account> newAccList = (List<Account>) profileStagingHandlerMock.getHistory(
        'process'
      )
      .getParam('records');

    Assert.areEqual(
      AutoKYCQACaseActions.UPGRADE_KYC_STATUS,
      newAccList[0].FinServ__KYCStatus__c,
      'KYC Statius should be set to: ' + AutoKYCQACaseActions.UPGRADE_KYC_STATUS
    );
    Assert.areEqual(
      AutoKYCQACaseActions.UPGRADE_KYC_VERIFICATION_LEVEL,
      newAccList[0].KYC_Verification_Level__c,
      'KYC Verification Level should be set to: ' +
      AutoKYCQACaseActions.UPGRADE_KYC_VERIFICATION_LEVEL
    );
  }

  @isTest
  private static void testFilterUpgradeCases() {
    Case oldCase = new Case();
    oldCase.Id = caseId;

    oldCase.Status = RECTIFY_DEFECT_STATUS;
    caseWithAccount.Status = GetHelpConstants.CLOSED_STATUS;
    caseWithAccount.Fraud_Defects_Rectified__c = 'Not Applicable';

    List<Case> upgradeCases = AutoKYCQACaseActions.filterUpgradeCases(
      new List<Case>{ caseWithAccount },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Assert.isTrue(
      upgradeCases.isEmpty(),
      'The \'Have All Defects Been Rectified\' is Not Applicable'
    );

    oldCase.Status = GetHelpConstants.CLOSED_STATUS;
    caseWithAccount.Status = GetHelpConstants.CLOSED_STATUS;
    caseWithAccount.Fraud_Defects_Rectified__c = AutoKYCQACaseActions.YES;

    upgradeCases = AutoKYCQACaseActions.filterUpgradeCases(
      new List<Case>{ caseWithAccount },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Assert.isTrue(
      upgradeCases.isEmpty(),
      'The status is Closed but wasn\'t changed'
    );

    oldCase.Status = RECTIFY_DEFECT_STATUS;
    caseWithAccount.Status = GetHelpConstants.CLOSED_STATUS;
    caseWithAccount.Fraud_Defects_Rectified__c = AutoKYCQACaseActions.YES;
    upgradeCases = AutoKYCQACaseActions.filterUpgradeCases(
      new List<Case>{ caseWithAccount },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Assert.isFalse(
      upgradeCases.isEmpty(),
      'The \'Have All Defects Been Rectified\' is YES and the case is closed.'
    );
  }

  @isTest
  private static void testFilterAccountsNotExitedAllValid() {
    Test.startTest();
    List<Account> oldAccounts = AutoKYCQACaseActions.filterAccountsNotExited(
      new List<Account>{ acc },
      new List<Account>{ new Account(OCV_ID__c = FAKER.randomString(5)) }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      oldAccounts.size(),
      'Should return 1 account, no other exited account of the same OCV ID'
    );
  }

  @isTest
  private static void testFilterAccountsNotExitedNotValid() {
    Test.startTest();
    List<Account> oldAccounts = AutoKYCQACaseActions.filterAccountsNotExited(
      new List<Account>{ acc },
      new List<Account>{ new Account(OCV_ID__c = acc.OCV_ID__c) }
    );
    Test.stopTest();
    Assert.isTrue(
      oldAccounts.isEmpty(),
      'Should return no account, there is an exited account of the same OCV ID'
    );
  }

  @isTest
  private static void testBuildUpgradedAccounts() {
    Test.startTest();
    List<Account> accounts = AutoKYCQACaseActions.buildUpgradedAccounts(
      new List<Account>{ acc }
    );
    Test.stopTest();

    Assert.areEqual(
      AutoKYCQACaseActions.UPGRADE_KYC_STATUS,
      accounts[0].FinServ__KYCStatus__c,
      'KYC Statius should be set to: ' + AutoKYCQACaseActions.UPGRADE_KYC_STATUS
    );
    Assert.areEqual(
      AutoKYCQACaseActions.UPGRADE_KYC_VERIFICATION_LEVEL,
      accounts[0].KYC_Verification_Level__c,
      'KYC Verification Level should be set to: ' +
      AutoKYCQACaseActions.UPGRADE_KYC_VERIFICATION_LEVEL
    );
  }

  @IsTest
  static void testPopulateClosedNoDefectDefaults() {
    Case newCase = new Case(
      Sub_Status__c = GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT
    );
    List<Case> records = new List<Case>{ newCase };

    Test.startTest();
    AutoKYCQACaseActions.populateClosedNoDefectDefaults(records, null);
    Test.stopTest();

    Assert.areEqual(
      'Not Applicable',
      newCase.Fraud_Defects_Rectified__c,
      'Have All Defects Been Rectified should be set to "Not Applicable"'
    );
  }

  @IsTest
  static void testCheckClosedAsNoDefectStatusOnNew() {
    Case record = new Case(
      Sub_Status__c = GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT
    );

    Test.startTest();
    Boolean result = AutoKYCQACaseActions.checkClosedAsNoDefect(record, null);
    Test.stopTest();

    Assert.isTrue(result, 'Should be true');
  }

  @IsTest
  static void testCheckClosedAsNoDefectStatusOnUpdate() {
    Case oldrecord = new Case();
    Case record = new Case(
      Sub_Status__c = GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT
    );

    Test.startTest();
    Boolean result = AutoKYCQACaseActions.checkClosedAsNoDefect(
      record,
      oldrecord
    );
    Test.stopTest();

    Assert.isTrue(result, 'Should be true');
  }

  @IsTest
  static void testCheckClosedAsNoDefectStatusWasNotDowngraded() {
    Case record = constuctCaseWithTestFields(null);
    record.Sub_Status__c = GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT;

    Test.startTest();
    Boolean result = AutoKYCQACaseActions.checkClosedAsNoDefect(record, null);
    Test.stopTest();

    Assert.isTrue(result, 'Should be true');
  }

  @IsTest
  static void testCheckClosedAsNoDefectStatusWasDowngraded() {
    Case record = constuctCaseWithTestFields(AutoKYCQACaseActions.NO);
    record.Sub_Status__c = GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT;
    record.Fraud_Defects_Rectified__c = AutoKYCQACaseActions.YES;

    Test.startTest();
    Boolean result = AutoKYCQACaseActions.checkClosedAsNoDefect(record, null);
    Test.stopTest();

    Assert.isFalse(result, 'Should be false if case was downgraded');
  }
}
