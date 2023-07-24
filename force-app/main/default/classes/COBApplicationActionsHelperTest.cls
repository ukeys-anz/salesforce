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

  private static final String FIRST_NAME = 'First Double';
  private static final String MIDDLE_NAMES = '  MiddleOne MiddleTwo  ';
  private static final String LAST_NAME = 'Last Double';
  private static final String DUMMY = 'DUMMY';
  private static final String EMPTY_STR = '';

  @TestSetup
  private static void makeData() {
    List<Account> personAccounts = new List<Account>();
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    List<COBPrimaryIDDocument__c> cobPids = new List<COBPrimaryIDDocument__c>();
    List<COBAddress__c> cobAddresses = new List<COBAddress__c>();

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
      cobAddresses.add(
        new COBAddress__c(
          CustomerOnboardingApplication__c = cobApp.id,
          AddressQASId__c = FAKER.randomString(15),
          AddressType__c = COBApplicationActions.CURRENT
        )
      );
    }

    insert cobPids;
    insert cobAddresses;
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
      : CommonUtil.buildTrimedConcatenatedString(
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
    cobPid.IdDocumentType__c = COBApplicationActionsHelper.LICENCE;
    cobPid.LicenceNumberOCRMatch__c = doesMatch;
  }

  private static void constructCOBPidPassport(
    COBPrimaryIDDocument__c cobPid,
    Boolean doesMatch
  ) {
    cobPid.IdDocumentType__c = COBApplicationActionsHelper.PASSPORT;
    cobPid.PassportNumberOCRMatch__c = doesMatch;
  }

  @isTest
  private static void testSetKYCQACaseBaseFields() {
    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();

    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      Case kycQACase = COBApplicationActionsHelper.setKYCQACaseBaseFields(
        cobApp
      );
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
    Map<String, Account> accountsByOCVIds = COBApplicationActionsHelper.getAccountsByOCVIds(
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
    Map<String, Account> accountsByOCVIds = COBApplicationActionsHelper.getAccountsByOCVIds(
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
    Map<String, COBPrimaryIDDocument__c> latestCOBPIDs = COBApplicationActionsHelper.getCOBPIDsByOCVIds(
      OCV_IDS
    );
    Test.stopTest();

    Assert.areEqual(
      OCV_IDS_COUNT,
      latestCOBPIDs.size(),
      'There should be only one (latest) COB Primary ID Document per COB App'
    );

    for (COBPrimaryIDDocument__c cobPid : latestCOBPIDs.values()) {
      Assert.areEqual(
        PASSPORT_TYPE,
        cobPid.IdDocumentType__c,
        'ID Document Type should be ' + PASSPORT_TYPE
      );
    }
  }

  @isTest
  private static void testGetCOBPIDsByOCVIdsEmptySet() {
    Map<String, COBPrimaryIDDocument__c> cobPIDs = COBApplicationActionsHelper.getCOBPIDsByOCVIds(
      new Set<String>()
    );

    Assert.isTrue(
      cobPIDs.isEmpty(),
      'There should be an empty list of COB Primary ID Documents.'
    );
  }

  @isTest
  private static void testGetCOBAddressByOCVIdAddressType() {
    Test.startTest();
    Map<String, COBAddress__c> cobAddresses = COBApplicationActionsHelper.getCOBAddressByOCVIdAddressType(
      OCV_IDS,
      COBApplicationActions.CURRENT
    );
    Test.stopTest();

    for (COBAddress__c cobAddress : cobAddresses.values()) {
      Assert.isTrue(cobAddress.QASAddress__c, 'QASAddress should be true.');
    }
  }

  @isTest
  private static void testGetCOBAddressByOCVIdAddressTypeEmptySet() {
    Map<String, COBAddress__c> cobPIDs = COBApplicationActionsHelper.getCOBAddressByOCVIdAddressType(
      new Set<String>(),
      COBApplicationActions.CURRENT
    );

    Assert.isTrue(
      cobPIDs.isEmpty(),
      'There should be an empty list of COB Address.'
    );
  }

  @isTest
  private static void testPopulateFraudCustomerDetails() {
    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
      VerificationType__c = COBApplicationActionsHelper.VERIFICATION_TYPE_ASSISTED
    );
    COBPrimaryIDDocument__c cobPID = new COBPrimaryIDDocument__c(
      IdDocumentType__c = COBApplicationActionsHelper.LICENCE,
      LicenceNumberOCRMatch__c = true
    );
    Assert.areEqual(
      COBApplicationActionsHelper.YES,
      COBApplicationActionsHelper.populateFraudCustomerDetails(cobApp, cobPID),
      'Yes when the Verification Type is STP or Assisted and the match on ID Document Numbers.'
    );

    cobPID.LicenceNumberOCRMatch__c = false;
    Assert.areEqual(
      COBApplicationActionsHelper.NONE,
      COBApplicationActionsHelper.populateFraudCustomerDetails(cobApp, cobPID),
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
      COBApplicationActionsHelper.YES,
      COBApplicationActionsHelper.populateFraudCustomerDetails(cobApp, cobPID),
      'Yes when the Verification Type is not STP or Assisted and Licence ID customer values matches with Licence ID OCR Server Values, FirstNameOCRServer included firstName and middleName'
    );

    cobPID.FirstNameOCRServer__c = firstName;
    cobPID.MiddleNamesOCRServer__c = middleName;
    Assert.areEqual(
      COBApplicationActionsHelper.YES,
      COBApplicationActionsHelper.populateFraudCustomerDetails(cobApp, cobPID),
      'Yes when the Verification Type is not STP or Assisted and Licence ID customer values matches with Licence ID OCR Server Values.'
    );

    cobPID.LicenceNumberOCRMatch__c = false;
    Assert.areEqual(
      COBApplicationActionsHelper.NONE,
      COBApplicationActionsHelper.populateFraudCustomerDetails(cobApp, cobPID),
      'None when the Verification Type is not STP or Assisted and Licence ID customer values mismatches with Licence ID OCR Server Values.'
    );

    cobPID.PassportNumberOCRMatch__c = true;
    cobPID.IdDocumentType__c = COBApplicationActionsHelper.PASSPORT;
    Assert.areEqual(
      COBApplicationActionsHelper.YES,
      COBApplicationActionsHelper.populateFraudCustomerDetails(cobApp, cobPID),
      'Yes when the Verification Type is not STP or Assisted and Passport ID customer values matches with Passport ID OCR Server Values.'
    );

    cobPID.PassportNumberOCRMatch__c = false;
    Assert.areEqual(
      COBApplicationActionsHelper.NONE,
      COBApplicationActionsHelper.populateFraudCustomerDetails(cobApp, cobPID),
      'None when the Verification Type is not STP or Assisted and Passport ID customer values mismatches with Licence ID OCR Server Values.'
    );
  }

  @isTest
  private static void testAreFirstAndLastNamesOCRServerBlank() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidFullNameOCRServer(cobPid, true, true);
    Boolean areFirstAndLastNamesOCRServerBlank = COBApplicationActionsHelper.areFirstAndLastNamesOCRServerBlank(
      cobPid
    );

    Assert.isTrue(
      areFirstAndLastNamesOCRServerBlank,
      'The First and Last Name OCR Server are blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, true, false);
    areFirstAndLastNamesOCRServerBlank = COBApplicationActionsHelper.areFirstAndLastNamesOCRServerBlank(
      cobPid
    );

    Assert.isFalse(
      areFirstAndLastNamesOCRServerBlank,
      'The First Name OCR Server is blank, Last Name OCR Server is not blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    areFirstAndLastNamesOCRServerBlank = COBApplicationActionsHelper.areFirstAndLastNamesOCRServerBlank(
      cobPid
    );

    Assert.isFalse(
      areFirstAndLastNamesOCRServerBlank,
      'The First Name OCR Server is not blank, Last Name OCR Server is blank'
    );

    constructCOBPidFullNameOCRServer(cobPid, false, false);
    areFirstAndLastNamesOCRServerBlank = COBApplicationActionsHelper.areFirstAndLastNamesOCRServerBlank(
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
    Boolean doMiddleNamesMatch = COBApplicationActionsHelper.doMiddleNamesMatch(
      cobPid
    );

    Assert.isTrue(
      doMiddleNamesMatch,
      'The Middle Names should match - both provided Middle Names and Middle Names OCR Server are matching'
    );

    constructCOBPidMiddleNames(cobPid, false, false);
    doMiddleNamesMatch = COBApplicationActionsHelper.doMiddleNamesMatch(cobPid);

    Assert.isFalse(
      doMiddleNamesMatch,
      'The Middle Names should not match - both provided Middle Names and Middle Names OCR Server are not matching'
    );

    constructCOBPidMiddleNames(cobPid, true, true);
    doMiddleNamesMatch = COBApplicationActionsHelper.doMiddleNamesMatch(cobPid);

    Assert.isFalse(
      doMiddleNamesMatch,
      'The Middle Names should not match - both provided Middle Names and Middle Names OCR Server are empty'
    );

    constructCOBPidMiddleNames(cobPid, false, true);
    doMiddleNamesMatch = COBApplicationActionsHelper.doMiddleNamesMatch(cobPid);

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
    Boolean doesFullNameMatch = COBApplicationActionsHelper.doesFullNameMatch(
      cobPid
    );

    Assert.isTrue(doesFullNameMatch, 'The Full Name should match');

    constructCOBPidFullName(cobPid, false);
    constructCOBPidFullNameOCRServer(cobPid, false, false);
    doesFullNameMatch = COBApplicationActionsHelper.doesFullNameMatch(cobPid);

    Assert.isFalse(doesFullNameMatch, 'The Full Name should not match');
  }

  @isTest
  private static void testDoesLicenceMatch() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidLicence(cobPid, true);
    Boolean doesLicenceMatch = COBApplicationActionsHelper.doesLicenceMatch(
      cobPid
    );

    Assert.isTrue(doesLicenceMatch, 'The Licence should match');

    constructCOBPidLicence(cobPid, false);
    doesLicenceMatch = COBApplicationActionsHelper.doesLicenceMatch(cobPid);

    Assert.isFalse(doesLicenceMatch, 'The Licence should not match');
  }

  @isTest
  private static void testDoesPassportMatch() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidPassport(cobPid, true);
    Boolean doesPassportMatch = COBApplicationActionsHelper.doesPassportMatch(
      cobPid
    );

    Assert.isTrue(doesPassportMatch, 'The Licence should match');

    constructCOBPidLicence(cobPid, false);
    doesPassportMatch = COBApplicationActionsHelper.doesPassportMatch(cobPid);

    Assert.isFalse(doesPassportMatch, 'The Licence should not match');
  }

  @isTest
  private static void testPopulateMiddleNameCheck() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c();

    constructCOBPidFullNameOCRServer(cobPid, true, true);
    String middleNameCheck = COBApplicationActionsHelper.populateMiddleNameCheck(
      cobPid
    );

    Assert.areEqual(
      COBApplicationActionsHelper.NONE,
      middleNameCheck,
      'The First and Last Name OCR Server are blank - Middle Name Check should be \'None\''
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, true, false);
    middleNameCheck = COBApplicationActionsHelper.populateMiddleNameCheck(
      cobPid
    );

    Assert.areEqual(
      COBApplicationActionsHelper.YES,
      middleNameCheck,
      'Both provided Middle Names and Middle Names OCR Server are matching and not empty - Middle Name Check should be \'Yes\''
    );

    constructCOBPidFullNameOCRServer(cobPid, false, false);
    constructCOBPidMiddleNames(cobPid, false, true);
    constructCOBPidFullName(cobPid, true);
    constructCOBPidLicence(cobPid, true);
    middleNameCheck = COBApplicationActionsHelper.populateMiddleNameCheck(
      cobPid
    );

    Assert.areEqual(
      COBApplicationActionsHelper.YES,
      middleNameCheck,
      'The Full Name and Licence Number are matching - Middle Name Check should be \'Yes\''
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, false, true);
    constructCOBPidFullName(cobPid, false);
    middleNameCheck = COBApplicationActionsHelper.populateMiddleNameCheck(
      cobPid
    );

    Assert.areEqual(
      COBApplicationActionsHelper.NONE,
      middleNameCheck,
      'The First Name OCR Server is blank, Middle Names and Full Names not matching - Middle Name Check should be \'None\''
    );

    constructCOBPidFullNameOCRServer(cobPid, false, true);
    constructCOBPidMiddleNames(cobPid, true, true);
    constructCOBPidFullName(cobPid, true);
    constructCOBPidLicence(cobPid, false);
    middleNameCheck = COBApplicationActionsHelper.populateMiddleNameCheck(
      cobPid
    );

    Assert.areEqual(
      COBApplicationActionsHelper.NONE,
      middleNameCheck,
      'The First Name OCR Server is blank, Middle Names are empty and Full Names are matching, Licence Number is not matching - Middle Name Check should be \'None\''
    );
  }
}
