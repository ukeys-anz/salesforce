@SuppressWarnings('PMD.CyclomaticComplexity')
@IsTest
public with sharing class AutoKYCQACaseActionsTest {
  private static final Faker FAKER = new Faker('AU');

  private static final String RECTIFY_DEFECT_STATUS = 'Rectify Defect';
  private static final String UNDER_REVIEW_STATUS = 'Under Review';
  private static final String PENDING_DOCUMENTS_STATUS = 'Pending Documents';
  private static final String FIRST_NAME = 'First Double';
  private static final String MIDDLE_NAMES = '  MiddleOne MiddleTwo  ';
  private static final String LAST_NAME = 'Last Double';
  private static final String DUMMY = 'DUMMY';
  private static final String DOCUMENTS_UPLOADED_STATUS = 'Documents Uploaded';
  private static final String PERSONA_ID1 = '0123456789';
  private static final String PERSONA_ID2 = '9876543210';
  private static final String PASSPORT_TYPE = 'Passport';
  private static final Map<String, String> PERSONA_ID_VERIFICATION_TYPES = new Map<String, String>{
    PERSONA_ID1 => 'STP',
    PERSONA_ID2 => 'ASSISTED'
  };

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

  private static void constructCOBPidFullName(
    COBPrimaryIDDocument__c cobPid,
    Boolean doesMatch
  ) {
    cobPid.FirstName__c = FIRST_NAME;
    cobPid.MiddleNames__c = MIDDLE_NAMES + (doesMatch ? '' : DUMMY);
    cobPid.LastName__c = LAST_NAME;
  }

  private static void constructCOBPidMiddleNames(
    COBPrimaryIDDocument__c cobPid,
    Boolean doesMatch,
    Boolean isMiddleNamesOCRServerEmpty
  ) {
    cobPid.MiddleNamesOCRMatch__c = doesMatch;
    cobPid.MiddleNamesOCRServer__c = isMiddleNamesOCRServerEmpty
      ? ''
      : MIDDLE_NAMES;
  }

  private static void constructCOBPidFullNameOCRServer(
    COBPrimaryIDDocument__c cobPid,
    Boolean isFirstNameOCRServerEmpty,
    Boolean isLastNameOCRServerEmpty
  ) {
    cobPid.FirstNameOCRServer__c = isFirstNameOCRServerEmpty
      ? ''
      : CommonUtil.buildTrimmedConcatenatedString(
          new List<String>{ FIRST_NAME, MIDDLE_NAMES }
        );
    cobPid.LastNameOCRServer__c = isLastNameOCRServerEmpty ? '' : LAST_NAME;
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

  private static CustomerOnboardingApplication__c addAddressToCob(
    CustomerOnboardingApplication__c cob,
    COBAddress__c address
  ) {
    return (CustomerOnboardingApplication__c) TestUtil.setFields(
      cob,
      new Map<String, Object>{
        'COBAddresses__r' => new List<COBAddress__c>{ address }
      }
    );
  }

  private static CustomerOnboardingApplication__c addPidToCob(
    CustomerOnboardingApplication__c cob,
    COBPrimaryIDDocument__c pid
  ) {
    return (CustomerOnboardingApplication__c) TestUtil.setFields(
      cob,
      new Map<String, Object>{
        'COBPrimaryIDDocuments__r' => new List<COBPrimaryIDDocument__c>{ pid }
      }
    );
  }

  @isTest
  private static void testValidateCob() {
    Test.startTest();
    AutoKYCQACaseActions.validateCobExist(new List<Case>{ caseWithNoCob });
    Test.stopTest();

    Assert.isTrue(
      caseWithNoCob.hasErrors(),
      'Error should have been set: ' + AutoKYCQACaseActions.ERROR_NO_COB
    );
    Assert.areEqual(
      AutoKYCQACaseActions.ERROR_NO_COB,
      caseWithNoCob.getErrors()[0].getMessage(),
      'Error message should be: ' + AutoKYCQACaseActions.ERROR_NO_COB
    );
  }

  @isTest
  private static void testSetFieldsFromCob() {
    Test.startTest();
    AutoKYCQACaseActions.setFieldsFromCob(
      new List<Case>{ caseWithCob },
      new Map<String, CustomerOnboardingApplication__c>{ PERSONA_ID1 => cob }
    );
    Test.stopTest();

    Assert.areEqual(
      AutoKYCQACaseActions.VERIFICATION_PRIORITY.get(
        PERSONA_ID_VERIFICATION_TYPES.get(PERSONA_ID1)
      ),
      caseWithCob.Priority,
      'Priority should have been set to: ' +
      AutoKYCQACaseActions.VERIFICATION_PRIORITY.get(
        PERSONA_ID_VERIFICATION_TYPES.get(PERSONA_ID1)
      )
    );
  }

  @isTest
  private static void testSetFieldsFromCobWitNoCOB() {
    Test.startTest();
    AutoKYCQACaseActions.setFieldsFromCob(
      new List<Case>{ caseWithCob },
      new Map<String, CustomerOnboardingApplication__c>()
    );
    Test.stopTest();

    Assert.isNull(
      caseWithCob.Priority,
      'Priority should have been set to Null'
    );
  }

  @isTest
  private static void testSetCustomerChecks() {
    constructCOBPidFullNameOCRServer(pidPassport, true, true);
    pidPassport.PassportNumberOCRMatch__c = true;

    Test.startTest();
    AutoKYCQACaseActions.setCustomerChecks(
      caseWithCob,
      addPidToCob(cob, pidPassport)
    );
    Test.stopTest();

    Assert.isNull(
      caseWithCob.Fraud_MiddleNameCheck__c,
      'The First and Last Name OCR Server are blank - Middle Name Check should be null'
    );

    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      caseWithCob.Fraud_Customer_Details__c,
      'The Verification Type is STP and Passport match, the KYC Information & ID Document Type Check should be Yes'
    );
  }

  @isTest
  private static void testSetAddressChecks() {
    Test.startTest();
    AutoKYCQACaseActions.setAddressChecks(
      caseWithCob,
      addAddressToCob(cob, addressQAS)
    );
    Test.stopTest();

    Assert.isNull(
      caseWithCob.Fraud_PO_Box__c,
      'Residential Address - PO Box Check should have been set to: null'
    );

    Assert.isNull(
      caseWithCob.Fraud_Address_Valid__c,
      'Residential Address - Validity Check should have been set to: null'
    );
  }

  @isTest
  private static void testSetAddressChecksWithNoAddress() {
    Test.startTest();
    AutoKYCQACaseActions.setAddressChecks(caseWithCob, cob);
    Test.stopTest();

    Assert.isNull(
      caseWithCob.Fraud_PO_Box__c,
      'Residential Address - PO Box Check should have been set to: null'
    );

    Assert.isNull(
      caseWithCob.Fraud_Address_Valid__c,
      'Residential Address - Validity Check should have been set to: null'
    );
  }

  @isTest
  private static void testCheckCustomer() {
    COBPrimaryIDDocument__c cobPID = new COBPrimaryIDDocument__c(
      IdDocumentType__c = AutoKYCQACaseActions.LICENCE,
      LicenceNumberOCRMatch__c = true
    );
    Assert.isTrue(
      AutoKYCQACaseActions.checkPrimaryId(
        cobPID,
        AutoKYCQACaseActions.VERIFICATION_TYPE_ASSISTED
      ),
      'Yes when the Verification Type is STP or Assisted and the match on ID Document Numbers.'
    );

    cobPID.LicenceNumberOCRMatch__c = false;
    Assert.isFalse(
      AutoKYCQACaseActions.checkPrimaryId(
        cobPID,
        AutoKYCQACaseActions.VERIFICATION_TYPE_ASSISTED
      ),
      'None when the Verification Type is STP or Assisted and mismatch on ID Document Numbers.'
    );

    String firstName = FAKER.randomString(5);
    String middleName = FAKER.randomString(5);
    String lastName = FAKER.randomString(5);
    cobPID.FirstName__c = firstName;
    cobPID.MiddleNames__c = middleName;
    cobPID.LastName__c = lastName;
    cobPID.FirstNameOCRServer__c = firstName + ' ' + middleName;
    cobPID.LastNameOCRServer__c = lastName;
    cobPID.DateOfBirthOCRMatch__c = true;
    cobPID.ExpiryDateOCRMatch__c = true;
    cobPID.LicenceNumberOCRMatch__c = true;
    Assert.isTrue(
      AutoKYCQACaseActions.checkPrimaryId(cobPID, 'MANUAL'),
      'Yes when the Verification Type is not STP or Assisted and Licence ID customer values matches with Licence ID OCR Server Values, FirstNameOCRServer included firstName and middleName'
    );

    cobPID.FirstNameOCRServer__c = firstName;
    cobPID.MiddleNamesOCRServer__c = middleName;
    Assert.isTrue(
      AutoKYCQACaseActions.checkPrimaryId(cobPID, 'MANUAL'),
      'Yes when the Verification Type is not STP or Assisted and Licence ID customer values matches with Licence ID OCR Server Values.'
    );

    cobPID.LicenceNumberOCRMatch__c = false;
    Assert.isFalse(
      AutoKYCQACaseActions.checkPrimaryId(cobPID, 'MANUAL'),
      'None when the Verification Type is not STP or Assisted and Licence ID customer values mismatches with Licence ID OCR Server Values.'
    );

    cobPID.PassportNumberOCRMatch__c = true;
    cobPID.IdDocumentType__c = AutoKYCQACaseActions.PASSPORT;
    Assert.isTrue(
      AutoKYCQACaseActions.checkPrimaryId(cobPID, 'MANUAL'),
      'Yes when the Verification Type is not STP or Assisted and Passport ID customer values matches with Passport ID OCR Server Values.'
    );

    cobPID.PassportNumberOCRMatch__c = false;
    Assert.isFalse(
      AutoKYCQACaseActions.checkPrimaryId(cobPID, 'MANUAL'),
      'None when the Verification Type is not STP or Assisted and Passport ID customer values mismatches with Licence ID OCR Server Values.'
    );
  }

  @isTest
  private static void testFirstAndLastNamesOCRServerBlank() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidFullNameOCRServer(cobPid, true, true);
    constructCOBPidMiddleNames(cobPid, true, false);

    Boolean checkMiddleName = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isFalse(
      checkMiddleName,
      'Should be false when First and Last Name OCR Server are blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, true, false);
    checkMiddleName = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isTrue(
      checkMiddleName,
      'Should be true when Last Name OCR Server is not blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    checkMiddleName = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isTrue(
      checkMiddleName,
      'Should be true when First Name OCR Server is not blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, false);
    checkMiddleName = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isTrue(
      checkMiddleName,
      'Should be true when First and Last Name OCR Server are not blank'
    );
  }

  @isTest
  private static void testDoMiddleNamesMatch() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidFullNameOCRServer(cobPid, false, false);
    constructCOBPidMiddleNames(cobPid, true, false);
    Boolean doMiddleNamesMatch = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isTrue(
      doMiddleNamesMatch,
      'The Middle Names should match - both provided Middle Names and Middle Names OCR Server are matching'
    );

    constructCOBPidMiddleNames(cobPid, false, false);
    doMiddleNamesMatch = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isFalse(
      doMiddleNamesMatch,
      'The Middle Names should not match - both provided Middle Names and Middle Names OCR Server are not matching'
    );

    constructCOBPidMiddleNames(cobPid, true, true);
    doMiddleNamesMatch = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isFalse(
      doMiddleNamesMatch,
      'The Middle Names should not match - both provided Middle Names and Middle Names OCR Server are empty'
    );

    constructCOBPidMiddleNames(cobPid, false, true);
    doMiddleNamesMatch = AutoKYCQACaseActions.checkMiddleName(cobPid);

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
    Boolean doesLicenceMatch = AutoKYCQACaseActions.doesDocumentMatch(cobPid);

    Assert.isTrue(doesLicenceMatch, 'The Licence should match');

    constructCOBPidLicence(cobPid, false);
    doesLicenceMatch = AutoKYCQACaseActions.doesDocumentMatch(cobPid);

    Assert.isFalse(doesLicenceMatch, 'The Licence should not match');
  }

  @isTest
  private static void testDoesPassportMatch() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidPassport(cobPid, true);
    Boolean doesPassportMatch = AutoKYCQACaseActions.doesDocumentMatch(cobPid);

    Assert.isTrue(doesPassportMatch, 'The Passport should match');

    constructCOBPidLicence(cobPid, false);
    doesPassportMatch = AutoKYCQACaseActions.doesDocumentMatch(cobPid);

    Assert.isFalse(doesPassportMatch, 'The Passport should not match');
  }

  @isTest
  private static void testCheckMiddleName() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();
    constructCOBPidFullNameOCRServer(cobPid, true, true);
    Boolean middleNameCheck = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isFalse(
      middleNameCheck,
      'The First and Last Name OCR Server are blank - Middle Name Check should be false'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, true, false);
    middleNameCheck = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isTrue(
      middleNameCheck,
      'Both provided Middle Names and Middle Names OCR Server are matching and not empty - Middle Name Check should be true'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, false);
    constructCOBPidMiddleNames(cobPid, false, true);
    constructCOBPidFullName(cobPid, true);
    constructCOBPidLicence(cobPid, true);
    middleNameCheck = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isTrue(
      middleNameCheck,
      'The Full Name and Licence Number are matching - Middle Name Check should be true'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, false, true);
    constructCOBPidFullName(cobPid, false);
    middleNameCheck = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isFalse(
      middleNameCheck,
      'The First Name OCR Server is blank, Middle Names and Full Names not matching - Middle Name Check should be false'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, true, true);
    constructCOBPidFullName(cobPid, true);
    constructCOBPidLicence(cobPid, false);
    middleNameCheck = AutoKYCQACaseActions.checkMiddleName(cobPid);

    Assert.isFalse(
      middleNameCheck,
      'The First Name OCR Server is blank, Middle Names are empty and Full Names are matching, Licence Number is not matching - Middle Name Check should be false'
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
    AutoKYCQACaseActions.populateClosedNoDefectDefaults(
      records,
      new Map<Id, Case>()
    );
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

  @IsTest
  static void testSetCheckFields() {
    Case record = new Case(
      Id = caseId,
      Fraud_MiddleNameCheck__c = AutoKYCQACaseActions.NO
    );

    Test.startTest();
    AutoKYCQACaseActions.setCheckFields(new List<Case>{ record });
    Test.stopTest();

    //The check field initially set to NO should not be updated
    Assert.areEqual(
      AutoKYCQACaseActions.NO,
      record.Fraud_MiddleNameCheck__c,
      'The Fraud_MiddleNameCheck__c should remained ' + AutoKYCQACaseActions.NO
    );

    //All other empty check fields should be updated with YES
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      record.Fraud_Customer_Details__c,
      'The Fraud_Customer_Details__c should be set to ' +
      AutoKYCQACaseActions.YES
    );
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      record.Fraud_Selfie_Comparison_Match__c,
      'The Fraud_Selfie_Comparison_Match__c should be set to ' +
      AutoKYCQACaseActions.YES
    );
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      record.Fraud_PO_Box__c,
      'The Fraud_PO_Box__c should be set to ' + AutoKYCQACaseActions.YES
    );
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      record.Fraud_Address_Valid__c,
      'The Fraud_Address_Valid__c should be set to ' + AutoKYCQACaseActions.YES
    );
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      record.Fraud_ID_Legible__c,
      'The Fraud_ID_Legible__c should be set to ' + AutoKYCQACaseActions.YES
    );
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      record.Fraud_Customer_Photo_Modified__c,
      'The Fraud_Customer_Photo_Modified__c should be set to ' +
      AutoKYCQACaseActions.YES
    );
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      record.Fraud_ID_Not_Picture__c,
      'The Fraud_ID_Not_Picture__c should be set to ' + AutoKYCQACaseActions.YES
    );
    Assert.areEqual(
      AutoKYCQACaseActions.YES,
      record.Fraud_Security_Features__c,
      'The Fraud_Security_Features__c should be set to ' +
      AutoKYCQACaseActions.YES
    );
  }

  //#region validateOwnerChange
  @IsTest
  static void testValidateOwnerChange() {
    Id cobId1 = Lib_FakeIdGenerator.getMockId(
      CustomerOnboardingApplication__c.SObjectType
    );
    Id cobId2 = Lib_FakeIdGenerator.getMockId(
      CustomerOnboardingApplication__c.SObjectType
    );
    List<Case> cases = new List<Case>{
      new Case(
        OwnerId = UserInfo.getUserId(),
        CustomerOnboardingApplication__c = cobId1
      ),
      new Case(
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        CustomerOnboardingApplication__c = cobId2
      )
    };

    Lib_MockProvider.forType(AutoKYCQACaseRepository.class)
      .mock(
        'queryCobsWithLatestIdOpsCase',
        new List<CustomerOnboardingApplication__c>{
          (CustomerOnboardingApplication__c) TestUtil.setFields(
            new CustomerOnboardingApplication__c(Id = cobId1),
            new Map<String, Object>{
              'Cases__r' => new List<Case>{
                new Case(OwnerId = UserInfo.getUserId())
              }
            }
          ),
          (CustomerOnboardingApplication__c) TestUtil.setFields(
            new CustomerOnboardingApplication__c(Id = cobId2),
            new Map<String, Object>{
              'Cases__r' => new List<Case>{ new Case() }
            }
          )
        }
      );

    Test.startTest();
    AutoKYCQACaseActions.validateOwnerChange(cases, new Map<Id, Case>());
    Test.stopTest();

    Assert.isTrue(
      cases[0].hasErrors(),
      'Should not be able to assign KYC QA case to the same owner as ID OPS case'
    );
    Assert.isFalse(cases[1].hasErrors(), 'Should be able to assign owner');
  }

  @IsTest
  static void testPreventSameOwnerAsIdOpsCases() {
    Id cobId1 = Lib_FakeIdGenerator.getMockId(
      CustomerOnboardingApplication__c.SObjectType
    );
    Id cobId2 = Lib_FakeIdGenerator.getMockId(
      CustomerOnboardingApplication__c.SObjectType
    );
    List<Case> cases = new List<Case>{
      new Case(
        OwnerId = UserInfo.getUserId(),
        CustomerOnboardingApplication__c = cobId1
      ),
      new Case(
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        CustomerOnboardingApplication__c = cobId2
      )
    };
    Map<Id, CustomerOnboardingApplication__c> cobMap = new Map<Id, CustomerOnboardingApplication__c>{
      cobId1 => (CustomerOnboardingApplication__c) TestUtil.setFields(
        new CustomerOnboardingApplication__c(),
        new Map<String, Object>{
          'Cases__r' => new List<Case>{
            new Case(OwnerId = UserInfo.getUserId())
          }
        }
      ),
      cobId2 => (CustomerOnboardingApplication__c) TestUtil.setFields(
        new CustomerOnboardingApplication__c(),
        new Map<String, Object>{ 'Cases__r' => new List<Case>{ new Case() } }
      )
    };

    Test.startTest();
    AutoKYCQACaseActions.preventSameOwnerAsIdOpsCases(cases, cobMap);
    Test.stopTest();

    Assert.isTrue(
      cases[0].hasErrors(),
      'Should not be able to assign KYC QA case to the same owner as ID OPS case'
    );
    Assert.isFalse(cases[1].hasErrors(), 'Should be able to assign owner');
  }
  //#endregion
}
