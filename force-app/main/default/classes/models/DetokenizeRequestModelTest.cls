/**
 * @author Karen Valeriano
 * @since Jul 2024
 * @description test class for DetokenizeRequestModel class
 * @group Models
 */
@isTest
private with sharing class DetokenizeRequestModelTest {
  private static final String TOKEN_TRANSFORM_VALUE = 'fpe.personal-identifier';

  static COBPrimaryIDDocument__c licencePid = new COBPrimaryIDDocument__c(
    PersonaId__c = '000000000',
    IdDocumentType__c = 'Licence',
    LicenceNumber__c = 'LN123123',
    LicenceNumberOCRClient__c = 'LN123123Client',
    LicenceNumberOCRServer__c = 'LN123123Server',
    LicenceCardNumber__c = 'LCN456456',
    LicenceCardNumberOCRClient__c = 'LCN456456Client',
    LicenceCardNumberOCRServer__c = 'LCN456456Server',
    DateOfBirth__c = Date.today(),
    ExpiryDate__c = Date.today()
  );
  static COBPrimaryIDDocument__c passportPid = new COBPrimaryIDDocument__c(
    PersonaId__c = '000000000',
    IdDocumentType__c = 'Passport',
    PassportNumber__c = 'P12345',
    PassportNumberOCRClient__c = 'P12345Client',
    PassportNumberOCRServer__c = 'P12345Server',
    DateOfBirth__c = Date.today(),
    ExpiryDate__c = Date.today()
  );

  @isTest
  static void testConstructorWithNullOCRServer() {
    licencePid.LicenceCardNumberOCRServer__c = null;

    Set<String> fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      licencePid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );

    Test.startTest();
    DetokenizeRequestModel tokenizedValues = new DetokenizeRequestModel(
      fieldValues,
      COBPrimaryIDDocumentModel.TOKEN_TRANSFORM_VALUE
    );
    Test.stopTest();

    Integer expected =
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size() - 1;
    System.assertEquals(
      expected,
      tokenizedValues.values.size(),
      'Should tokenized ' + expected + ' fields.'
    );
  }

  @isTest
  static void testConstructorWithParamsLicence() {
    Set<String> fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      licencePid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );

    Test.startTest();
    DetokenizeRequestModel model = new DetokenizeRequestModel(
      fieldValues,
      COBPrimaryIDDocumentModel.TOKEN_TRANSFORM_VALUE
    );
    Test.stopTest();

    Assert.areEqual(
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size(),
      model.values.size(),
      'Should tokenized ' +
        COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size() +
        ' fields.'
    );
  }

  @isTest
  static void testConstructorWithParamsPassport() {
    Set<String> fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      passportPid,
      COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS
    );

    Test.startTest();
    DetokenizeRequestModel model = new DetokenizeRequestModel(
      fieldValues,
      COBPrimaryIDDocumentModel.TOKEN_TRANSFORM_VALUE
    );
    Test.stopTest();

    Assert.areEqual(
      COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS.size(),
      model.values.size(),
      'Should tokenized ' +
        COBPIDViewAndEditController.PASSPORT_TOKENIZED_FIELDS.size() +
        ' fields.'
    );
  }
}
