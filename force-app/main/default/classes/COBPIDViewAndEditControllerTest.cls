/**
 * @description Test class for COBPIDViewAndEditController
 * @author Karen Valeriano
 * @since 07/2024
 */
@isTest
private class COBPIDViewAndEditControllerTest {
  static final String PASSPORT_TYPE = 'Passport';
  static final String LICENSE_TYPE = 'Licence';
  static final String ASSERT_MSG_AURA_EXCEPTION = 'An AuraHandledException should be thrown';
  static final String ASSERT_MSG_NO_EXCEPTION = 'Code should run successfully';

  static final String PASSPORT_PID_DATA_RESPONSE =
    '{' +
    '  "passport": {' +
    '    "firstName": "Adam",' +
    '    "middleNames": "Foo Bar",' +
    '    "lastName": "Baz",' +
    '    "dateOfBirth": {' +
    '      "year": 2000,' +
    '      "month": 10,' +
    '      "day": 16' +
    '     },' +
    '    "expiryDate": {' +
    '      "year": 2000,' +
    '      "month": 10,' +
    '      "day": 16' +
    '     },' +
    '    "countryOfIssue": "Australia",' +
    '    "passportNumberToken": {' +
    '      "value": "PASSPORTOKEN393939",' +
    '      "transform": "fpe.personal-identifier"' +
    '     }' +
    '  }' +
    '}';

  static final String LICENCE_PID_DATA_RESPONSE =
    '{' +
    '  "australianDriverLicence": {' +
    '    "firstName": "Adam",' +
    '    "middleNames": "Foo Bar",' +
    '    "lastName": "Baz",' +
    '    "dateOfBirth": {' +
    '      "year": 2000,' +
    '      "month": 10,' +
    '      "day": 16' +
    '     },' +
    '    "expiryDate": {' +
    '      "year": 2000,' +
    '      "month": 10,' +
    '      "day": 16' +
    '     },' +
    '    "stateOfIssue": "NSW",' +
    '    "licenceNumberToken": {' +
    '      "value": "LICTOKEN292929",' +
    '      "transform": "fpe.personal-identifier"' +
    '     },' +
    '    "licenceCardNumberToken": {' +
    '      "value": "LICCARDTOKEN2929",' +
    '      "transform": "fpe.personal-identifier"' +
    '     }' +
    '  } ' +
    '}';

  static final String PASSPORT_PID_DETOKENIZED_RESPONSE =
    '{' +
    ' "values": [' +
    '   {"tokenized":"126d2gj1","detokenized":"126d2gj1"},' +
    '   {"tokenized":"64PefL","detokenized":"148062"},' +
    '   {"tokenized":"A0LZldBD","detokenized":"29087612"}' +
    ' ]' +
    '}';

  static final String LICENCE_PID_DETOKENIZED_RESPONSE =
    '{' +
    '  "values": [' +
    '     {"tokenized":"DZ75wQVeX","detokenized":"87654321A"},' +
    '     {"tokenized":"64PefL","detokenized":"148062"},' +
    '     {"tokenized":"A0LZldBD","detokenized":"29087612"},' +
    '     {"tokenized":"qG3E6ZtU3o","detokenized":"1842035745"},' +
    '     {"tokenized":"9sgkMO3mUr","detokenized":"1612425932"},' +
    '     {"tokenized":"4SWTzU1VaV","detokenized":"2045109312"}' +
    ' ] ' +
    '}';

  static DetokenizeModel detokenizedLicenseModel = DetokenizeModel.parse(
    LICENCE_PID_DETOKENIZED_RESPONSE
  );
  static DetokenizeModel detokenizedPassportModel = DetokenizeModel.parse(
    PASSPORT_PID_DETOKENIZED_RESPONSE
  );
  static COBPrimaryIDDocumentModel licenseDocModel = COBPrimaryIDDocumentModel.parse(
    LICENCE_PID_DATA_RESPONSE
  );
  static COBPrimaryIDDocumentModel passportDocModel = COBPrimaryIDDocumentModel.parse(
    PASSPORT_PID_DATA_RESPONSE
  );

  static Exception error;
  static COBPrimaryIDDocument__c cobPid;
  static DetokenizeModel detokenizedModelResponse;
  static COBPrimaryIDDocument__c tokenizedData;
  static Faker faker = new Faker('AU');
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider cobPidViewEditRepoMock;
  static Lib_MockProvider stravinskyApiRepoMock;
  static Set<String> fieldValues;
  static Set<SObjectField> fields;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    cobPidViewEditRepoMock = Lib_MockProvider.forType(
      COBPIDViewAndEditRepository.class
    );
    stravinskyApiRepoMock = Lib_MockProvider.forType(
      StravinskyAPIRepository.class
    );
  }

  static COBPrimaryIDDocument__c pidPassport = new COBPrimaryIDDocument__c(
    Id = Lib_FakeIdGenerator.getMockId(COBPrimaryIDDocument__c.SObjectType),
    IdDocumentType__c = PASSPORT_TYPE,
    PersonaId__c = faker.randomString(10),
    CountryOfIssue__c = 'Australia',
    DateOfBirth__c = Date.today(),
    ExpiryDate__c = Date.today(),
    FirstName__c = faker.randomString(5),
    LastName__c = faker.randomString(5),
    MiddleNames__c = faker.randomString(5),
    PassportNumber__c = '126d2gj1',
    PassportNumberOCRClient__c = '148062',
    PassportNumberOCRServer__c = '29087612'
  );

  static COBPrimaryIDDocument__c pidLicense = new COBPrimaryIDDocument__c(
    Id = Lib_FakeIdGenerator.getMockId(COBPrimaryIDDocument__c.SObjectType),
    IdDocumentType__c = LICENSE_TYPE,
    PersonaId__c = faker.randomString(10),
    DateOfBirth__c = Date.today(),
    ExpiryDate__c = Date.today(),
    FirstName__c = faker.randomString(5),
    LastName__c = faker.randomString(5),
    MiddleNames__c = faker.randomString(5),
    LicenceNumber__c = '87654321A',
    LicenceNumberOCRClient__c = '148062',
    LicenceNumberOCRServer__c = '29087612',
    LicenceCardNumber__c = '1842035745',
    LicenceCardNumberOCRClient__c = '1612425932',
    LicenceCardNumberOCRServer__c = '2045109312',
    StateOfIssue__c = 'NSW'
  );

  @isTest
  static void testGetCobPidDocumentWithNoPersonaId() {
    registerMocks();
    pidPassport.PersonaId__c = null;

    cobPidViewEditRepoMock.mock('getCOBPIDByRecordId', pidPassport);

    Test.startTest();
    try {
      COBPIDViewAndEditController.getCobPidDocument(pidPassport.Id);
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        ASSERT_MSG_AURA_EXCEPTION
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetCobPidDocument() {
    registerMocks();
    cobPidViewEditRepoMock.mock('getCOBPIDByRecordId', pidPassport);

    Test.startTest();
    try {
      cobPid = COBPIDViewAndEditController.getCobPidDocument(pidPassport.Id);
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isNull(error, ASSERT_MSG_NO_EXCEPTION);
    Assert.isNotNull(
      cobPid,
      'A COB primary document record should be returned'
    );
  }

  @isTest
  static void testGetTokenizedFieldsLicense() {
    Test.startTest();
    fields = COBPIDViewAndEditController.getTokenizedFields(
      pidLicense.IdDocumentType__c
    );
    Test.stopTest();

    Assert.areEqual(
      fields.size(),
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size(),
      'Should tokenized ' +
        COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size() +
        ' fields.'
    );
  }

  @isTest
  static void testGetTokenizedFieldsPassport() {
    Test.startTest();
    fields = COBPIDViewAndEditController.getTokenizedFields(
      pidPassport.IdDocumentType__c
    );
    Test.stopTest();

    Assert.areEqual(
      fields.size(),
      COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS.size(),
      'Should tokenized ' +
        COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS.size() +
        ' fields.'
    );
  }

  @isTest
  static void testGetTokenizedFieldValuesLicence() {
    Test.startTest();
    fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      pidLicense,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );
    Test.stopTest();

    Assert.areEqual(
      fieldValues.size(),
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size(),
      'Should tokenized ' +
        COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size() +
        ' fields.'
    );
  }

  @isTest
  static void testGetTokenizedFieldValuesPassport() {
    Test.startTest();
    fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      pidPassport,
      COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS
    );
    Test.stopTest();

    Assert.areEqual(
      fieldValues.size(),
      COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS.size(),
      'Should tokenized ' +
        COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS.size() +
        ' fields.'
    );
  }

  @isTest
  static void testDetokenizeCobPidLicence() {
    registerMocks();
    stravinskyApiRepoMock.mock('detokenize', detokenizedLicenseModel);

    fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      pidLicense,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );

    Test.startTest();
    try {
      detokenizedModelResponse = COBPIDViewAndEditController.detokenizeCobPid(
        pidLicense,
        fieldValues
      );
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isNull(error, ASSERT_MSG_NO_EXCEPTION);
    Assert.isFalse(
      stravinskyApiRepoMock.getHistories('detokenize').isEmpty(),
      'detokenize call should have been made.'
    );
    Assert.areEqual(
      6,
      detokenizedModelResponse.values.size(),
      'Should have 6 detokenized values'
    );
  }

  @isTest
  static void testDetokenizeCobPidPassport() {
    registerMocks();
    stravinskyApiRepoMock.mock('detokenize', detokenizedPassportModel);

    fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      pidPassport,
      COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS
    );

    Test.startTest();
    try {
      detokenizedModelResponse = COBPIDViewAndEditController.detokenizeCobPid(
        pidPassport,
        fieldValues
      );
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isNull(error, ASSERT_MSG_NO_EXCEPTION);
    Assert.isFalse(
      stravinskyApiRepoMock.getHistories('detokenize').isEmpty(),
      'detokenize call should have been made.'
    );
    Assert.areEqual(
      3,
      detokenizedModelResponse.values.size(),
      'Should have 3 detokenized values'
    );
  }

  @isTest
  static void testSetDetokenizedFieldsLicense() {
    registerMocks();
    stravinskyApiRepoMock.mock('detokenize', detokenizedLicenseModel);

    fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      pidLicense,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );
    detokenizedModelResponse = COBPIDViewAndEditController.detokenizeCobPid(
      pidLicense,
      fieldValues
    );

    Test.startTest();
    try {
      cobPid = COBPIDViewAndEditController.setDetokenizedFields(
        detokenizedModelResponse,
        pidLicense,
        COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
      );
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isNull(error, ASSERT_MSG_NO_EXCEPTION);
    Assert.areEqual(
      pidLicense.LicenceCardNumber__c,
      cobPid.LicenceCardNumber__c,
      'LicenceCardNumber__c should be detokenized'
    );
    Assert.areEqual(
      pidLicense.LicenceCardNumberOCRClient__c,
      cobPid.LicenceCardNumberOCRClient__c,
      'LicenceCardNumberOCRClient__c should be detokenized'
    );
    Assert.areEqual(
      pidLicense.LicenceCardNumberOCRServer__c,
      cobPid.LicenceCardNumberOCRServer__c,
      'LicenceCardNumberOCRServer__c should be detokenized'
    );
    Assert.areEqual(
      pidLicense.LicenceNumber__c,
      cobPid.LicenceNumber__c,
      'LicenceNumber__c should be detokenized'
    );
    Assert.areEqual(
      pidLicense.LicenceNumberOCRClient__c,
      cobPid.LicenceNumberOCRClient__c,
      'LicenceNumberOCRClient__c should be detokenized'
    );
    Assert.areEqual(
      pidLicense.LicenceNumberOCRServer__c,
      cobPid.LicenceNumberOCRServer__c,
      'LicenceNumberOCRServer__c should be detokenized'
    );
  }

  @isTest
  static void testSetDetokenizedFieldsPassport() {
    registerMocks();
    stravinskyApiRepoMock.mock('detokenize', detokenizedPassportModel);

    fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      pidPassport,
      COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS
    );
    detokenizedModelResponse = COBPIDViewAndEditController.detokenizeCobPid(
      pidPassport,
      fieldValues
    );

    Test.startTest();
    try {
      cobPid = COBPIDViewAndEditController.setDetokenizedFields(
        detokenizedModelResponse,
        pidPassport,
        COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS
      );
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isNull(error, ASSERT_MSG_NO_EXCEPTION);
    Assert.areEqual(
      pidPassport.PassportNumber__c,
      cobPid.PassportNumber__c,
      'PassportNumber__c should be detokenized'
    );
    Assert.areEqual(
      pidPassport.PassportNumberOCRClient__c,
      cobPid.PassportNumberOCRClient__c,
      'PassportNumberOCRClient__c should be detokenized'
    );
    Assert.areEqual(
      pidPassport.PassportNumberOCRServer__c,
      cobPid.PassportNumberOCRServer__c,
      'PassportNumberOCRServer__c should be detokenized'
    );
  }

  @isTest
  static void testTriggerTemporalPIDWorklowSuccess() {
    registerMocks();
    stravinskyApiRepoMock.mock('updatePrimaryIDDocument', licenseDocModel);
    cobPidViewEditRepoMock.mock(
      'getIdOpsCase',
      new Case(Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType))
    );

    COBPrimaryIDDocumentModel response;
    Test.startTest();
    try {
      response = COBPIDViewAndEditController.triggerTemporalPIDWorklow(
        pidLicense
      );
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isNull(error, ASSERT_MSG_NO_EXCEPTION);
    Assert.isNotNull(response, 'A tokenized cob pid should be returned.');
    Assert.isFalse(
      cobPidViewEditRepoMock.getHistories('getIdOpsCase').isEmpty(),
      'getIdOpsCase call should have been made.'
    );
    Assert.isFalse(
      stravinskyApiRepoMock.getHistories('updatePrimaryIDDocument').isEmpty(),
      'updatePrimaryIDDocument call should have been made.'
    );
  }

  @isTest
  static void testTriggerTemporalPIDWorklowDFailed() {
    HttpCalloutResponse httpCallOutResponse = new HttpCalloutResponse();
    httpCallOutResponse.successful = false;
    httpCallOutResponse.statusCode = 400;

    registerMocks();
    stravinskyApiRepoMock.mock('updatePrimaryIDDocument', httpCallOutResponse);
    cobPidViewEditRepoMock.mock(
      'getIdOpsCase',
      new Case(Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType))
    );

    Test.startTest();
    try {
      COBPIDViewAndEditController.triggerTemporalPIDWorklow(pidLicense);
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isTrue(
      error instanceof AuraHandledException,
      ASSERT_MSG_AURA_EXCEPTION
    );
    Assert.isFalse(
      cobPidViewEditRepoMock.getHistories('getIdOpsCase').isEmpty(),
      'getIdOpsCase call should have been made.'
    );
    Assert.isFalse(
      stravinskyApiRepoMock.getHistories('updatePrimaryIDDocument').isEmpty(),
      'updatePrimaryIDDocument call should have been made.'
    );
  }

  @isTest
  static void testGetErrorMessageFound() {
    String apiErrorMessage = 'FirstName must match pattern';
    String errorMessage =
      'failed to validate primaryId Info: ' + apiErrorMessage;

    Test.startTest();
    String readableErrorMessage = COBPIDViewAndEditController.getErrorMessage(
      errorMessage
    );
    Test.stopTest();

    Assert.areEqual(
      COBPIDViewAndEditController.PID_ERRORS_USER_MSG.get(apiErrorMessage),
      readableErrorMessage,
      'Error message should be ' + readableErrorMessage
    );
  }

  @isTest
  static void testGetErrorMessageNotFound() {
    String errorMessage = 'error messagee';

    Test.startTest();
    String readableErrorMessage = COBPIDViewAndEditController.getErrorMessage(
      errorMessage
    );
    Test.stopTest();

    Assert.areEqual(
      COBPIDViewAndEditController.FAILED_TO_UPDATE_DETAILS,
      readableErrorMessage,
      'Error message should be ' +
      COBPIDViewAndEditController.FAILED_TO_UPDATE_DETAILS
    );
  }

  @isTest
  static void testBuildTokenizedDataPassport() {
    Test.startTest();
    tokenizedData = COBPIDViewAndEditController.buildTokenizedData(
      pidPassport,
      passportDocModel
    );
    Test.stopTest();

    Assert.isNotNull(tokenizedData, 'A tokenized cob pid should be returned.');
    Assert.isFalse(
      String.isBlank(tokenizedData.PassportNumber__c),
      'PassportNumber__c should have a value'
    );
  }

  @isTest
  static void testBuildTokenizedDataLicense() {
    Test.startTest();
    tokenizedData = COBPIDViewAndEditController.buildTokenizedData(
      pidLicense,
      licenseDocModel
    );
    Test.stopTest();

    Assert.isNotNull(tokenizedData, 'A tokenized cob pid should be returned.');
    Assert.isFalse(
      String.isBlank(tokenizedData.LicenceCardNumber__c),
      'LicenceCardNumber__c should have a value'
    );
    Assert.isFalse(
      String.isBlank(tokenizedData.LicenceNumber__c),
      'LicenceNumber__c should have a value'
    );
  }

  @isTest
  static void testUpdateTokenizedDataSuccess() {
    registerMocks();

    tokenizedData = COBPIDViewAndEditController.buildTokenizedData(
      pidLicense,
      licenseDocModel
    );

    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult('{"success":true}')
    };
    dmlRepoMock.mock('updateRecords', saveResults);

    COBPIDViewAndEditController.PIDDMLOperator pidDmlOperator = new COBPIDViewAndEditController.PIDDMLOperator();

    Test.startTest();
    try {
      pidDmlOperator.updateTokenizedData(tokenizedData);
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isNull(error, ASSERT_MSG_NO_EXCEPTION);
    Assert.isFalse(
      dmlRepoMock.getHistories('updateRecords').isEmpty(),
      'updateRecords call should have been made.'
    );
  }

  @isTest
  static void testUpdateTokenizedDataFailed() {
    registerMocks();

    tokenizedData = COBPIDViewAndEditController.buildTokenizedData(
      pidLicense,
      licenseDocModel
    );

    List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    dmlRepoMock.mock('updateRecords', saveResults);

    COBPIDViewAndEditController.PIDDMLOperator pidDmlOperator = new COBPIDViewAndEditController.PIDDMLOperator();

    Test.startTest();
    try {
      pidDmlOperator.updateTokenizedData(tokenizedData);
    } catch (Exception ex) {
      error = ex;
    }
    Test.stopTest();

    Assert.isTrue(
      error instanceof AuraHandledException,
      ASSERT_MSG_AURA_EXCEPTION
    );
    Assert.isFalse(
      dmlRepoMock.getHistories('updateRecords').isEmpty(),
      'updateRecords call should have been made.'
    );
  }
}
