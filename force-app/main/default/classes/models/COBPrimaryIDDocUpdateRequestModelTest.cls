/**
 * @author Karen Valeriano
 * @since Jul 2024
 * @description test class for COBPrimaryIDDocUpdateRequestModel class
 * @group Models
 */
@isTest
private class COBPrimaryIDDocUpdateRequestModelTest {
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
  static void testConstructorWithParamsPassport() {
    Test.startTest();
    COBPrimaryIDDocUpdateRequestModel request = new COBPrimaryIDDocUpdateRequestModel(
      passportPid,
      null
    );
    Test.stopTest();

    Assert.areEqual(
      COBPrimaryIDDocUpdateRequestModel.PASSPORT_UPDATE_MASK,
      request.updateMask,
      'Should use COBPrimaryIDDocUpdateRequestModel.PASSPORT_UPDATE_MASK'
    );
    Assert.isNotNull(
      request.primaryIdDocument.passport,
      'The primaryIdDocument should be Passport'
    );
    Assert.isNull(
      request.primaryIdDocument.australianDriverLicence,
      'The AustralianDriverLicence document should be null.'
    );
  }

  @isTest
  static void testConstructorWithParamsLicence() {
    Test.startTest();
    COBPrimaryIDDocUpdateRequestModel request = new COBPrimaryIDDocUpdateRequestModel(
      licencePid,
      null
    );
    Test.stopTest();

    Assert.areEqual(
      COBPrimaryIDDocUpdateRequestModel.AUSTRALIAN_DRIVER_LICENCE_UPDATE_MASK,
      request.updateMask,
      'Should use COBPrimaryIDDocUpdateRequestModel.AUSTRALIAN_DRIVER_LICENCE_UPDATE_MASK'
    );
    Assert.isNotNull(
      request.primaryIdDocument.australianDriverLicence,
      'The primaryIdDocument should be AustralianDriverLicence'
    );
    Assert.isNull(
      request.primaryIdDocument.passport,
      'The Passport document should be null.'
    );
  }
}
