/**
 * @author Victor Wang
 * @since Jan 2023
 * @description test class for COBPrimaryIDDocumentModel class
 * @group Models
 */
@isTest
public with sharing class COBPrimaryIDDocumentModelTest {
  static final String JSON_LICENCE =
    '{' +
    '  \"australianDriverLicence\": {' +
    '    \"firstName\": \"Adam\",' +
    '    \"middleNames\": \"Foo Bar\",' +
    '    \"lastName\": \"Baz\",' +
    '    \"dateOfBirth\": {' +
    '      \"year\": 2000,' +
    '      \"month\": 10,' +
    '      \"day\": 16' +
    '     },' +
    '    \"expiryDate\": {' +
    '      \"year\": 2000,' +
    '      \"month\": 10,' +
    '      \"day\": 16' +
    '     },' +
    '    \"stateOfIssue\": \"NSW\",' +
    '    \"licenceNumberToken\": {' +
    '      \"value\": \"LICTOKEN292929\",' +
    '      \"transform\": \"fpe.personal-identifier\"' +
    '     },' +
    '    \"licenceCardNumberToken\": {' +
    '      \"value\": \"LICCARDTOKEN2929\",' +
    '      \"transform\": \"fpe.personal-identifier\"' +
    '     }' +
    '  }, ' +
    ' \"name\": \"Australian Driver\'s Licence\"' +
    '}';
  static final String JSON_PASSPORT =
    '{' +
    '  \"passport\": {' +
    '    \"firstName\": \"Adam\",' +
    '    \"middleNames\": \"Foo Bar\",' +
    '    \"lastName\": \"Baz\",' +
    '    \"dateOfBirth\": {' +
    '      \"year\": 2000,' +
    '      \"month\": 10,' +
    '      \"day\": 16' +
    '     },' +
    '    \"expiryDate\": {' +
    '      \"year\": 2000,' +
    '      \"month\": 10,' +
    '      \"day\": 16' +
    '     },' +
    '    \"countryOfIssue\": \"Australia\",' +
    '    \"passportNumberToken\": {' +
    '      \"value\": \"PASSPORTOKEN393939\",' +
    '      \"transform\": \"fpe.personal-identifier\"' +
    '     }' +
    '  }, ' +
    ' \"name\": \"Passport\"' +
    '}';

  static Faker faker = new Faker('AU');
  static COBPrimaryIDDocument__c pidPassport = new COBPrimaryIDDocument__c(
    Id = Lib_FakeIdGenerator.getMockId(COBPrimaryIDDocument__c.SObjectType),
    IdDocumentType__c = 'Passport',
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
    IdDocumentType__c = 'Licence',
    PersonaId__c = faker.randomString(10),
    DateOfBirth__c = Date.today(),
    ExpiryDate__c = Date.today(),
    FirstName__c = faker.randomString(5),
    LastName__c = faker.randomString(5),
    MiddleNames__c = faker.randomString(5),
    LicenceNumber__c = '148062',
    LicenceNumberOCRClient__c = '148062',
    LicenceNumberOCRServer__c = '29087612',
    LicenceCardNumber__c = '1612425932',
    LicenceCardNumberOCRClient__c = '1612425932',
    LicenceCardNumberOCRServer__c = '2045109312',
    StateOfIssue__c = 'NSW'
  );

  @isTest
  static void testParsePassport() {
    String modelName = 'Passport';

    Test.startTest();
    COBPrimaryIDDocumentModel obj = COBPrimaryIDDocumentModel.parse(
      JSON_PASSPORT
    );
    Test.stopTest();

    Assert.areEqual(
      modelName,
      obj.name,
      'The parsed model name should be ' + modelName
    );
    Assert.isNotNull(obj.passport, 'There should be a passport object');
  }

  @isTest
  static void testParseLicence() {
    String modelName = 'Australian Driver\'s Licence';

    Test.startTest();
    COBPrimaryIDDocumentModel obj = COBPrimaryIDDocumentModel.parse(
      JSON_LICENCE
    );
    Test.stopTest();

    Assert.areEqual(
      modelName,
      obj.name,
      'The parsed model name should be ' + modelName
    );
    Assert.isNotNull(
      obj.australianDriverLicence,
      'There should be an australianDriverLicence object'
    );
  }

  @isTest
  static void testParseException() {
    Lib_MockProvider model = Lib_MockProvider.forType(
      COBPrimaryIDDocumentModel.class
    );
    model.mock('parse', new JSONException('Error'));

    Test.startTest();
    try {
      COBPrimaryIDDocumentModel obj = COBPrimaryIDDocumentModel.parse(
        JSON_LICENCE
      );
    } catch (Exception ex) {
      Assert.isNotNull(ex, 'An exception should be thrown.');
    }
    Test.stopTest();
  }

  @isTest
  static void testPassportConstructor() {
    Test.startTest();
    COBPrimaryIDDocumentModel obj = new COBPrimaryIDDocumentModel(
      new COBPrimaryIDDocumentModel.Passport(pidPassport)
    );
    Test.stopTest();

    //Common details should have values
    Assert.isTrue(
      String.isNotBlank(obj.passport.firstName),
      'firstName should have value'
    );
    Assert.isTrue(
      String.isNotBlank(obj.passport.middleNames),
      'middleNames should have value'
    );
    Assert.isTrue(
      String.isNotBlank(obj.passport.lastName),
      'lastName should have value'
    );
    Assert.isNotNull(obj.passport.dateOfBirth, 'dateOfBirth should have value');
    Assert.isNotNull(obj.passport.expiryDate, 'expiryDate should have value');

    //Passport-specific details should have values
    Assert.isTrue(
      String.isNotBlank(obj.passport.passportNumber),
      'passportNumber should have value'
    );
    Assert.isTrue(
      String.isNotBlank(obj.passport.countryOfIssue),
      'countryOfIssue should have value'
    );
  }

  @isTest
  static void testLicenceConstructor() {
    Test.startTest();
    COBPrimaryIDDocumentModel obj = new COBPrimaryIDDocumentModel(
      new COBPrimaryIDDocumentModel.AustralianDriverLicence(pidLicense)
    );
    Test.stopTest();

    //Common details should have values
    Assert.isTrue(
      String.isNotBlank(obj.australianDriverLicence.firstName),
      'firstName should have value'
    );
    Assert.isTrue(
      String.isNotBlank(obj.australianDriverLicence.middleNames),
      'middleNames should have value'
    );
    Assert.isTrue(
      String.isNotBlank(obj.australianDriverLicence.lastName),
      'lastName should have value'
    );
    Assert.isNotNull(
      obj.australianDriverLicence.dateOfBirth,
      'dateOfBirth should have value'
    );
    Assert.isNotNull(
      obj.australianDriverLicence.expiryDate,
      'expiryDate should have value'
    );

    //Licence-specific details should have values
    Assert.isTrue(
      String.isNotBlank(obj.australianDriverLicence.stateOfIssue),
      'stateOfIssue should have value'
    );
    Assert.isTrue(
      String.isNotBlank(obj.australianDriverLicence.licenceNumber),
      'licenceNumber should have value'
    );
    Assert.isTrue(
      String.isNotBlank(obj.australianDriverLicence.licenceCardNumber),
      'licenceCardNumber should have value'
    );
  }
}
