/**
 * @author Victor Wang
 * @since Jan 2023
 * @description test class for COBPrimaryIDDocumentModel class
 * @group Models
 */
@isTest
public with sharing class COBPrimaryIDDocumentModelTest {
  @isTest
  static void testParse() {
    String json =
      '{' +
      '  \"values\": [' +
      '    {' +
      '      \"Tokenized\": \"Q2CmJdCA0\",' +
      '      \"Detokenized\": \"PA0940444\"' +
      '    },' +
      '    {' +
      '      \"Tokenized\": \"Q2CmJdCA1\",' +
      '      \"Detokenized\": \"PA0940441\"' +
      '    }' +
      '  ]' +
      '}';

    COBPrimaryIDDocumentModel obj = COBPrimaryIDDocumentModel.parse(json);
    System.assertEquals(
      2,
      obj.values.size(),
      'Should have 2 values after parse.'
    );
  }

  @isTest
  static void testBuildTokenizedValues() {
    COBPrimaryIDDocument__c pid = new COBPrimaryIDDocument__c(
      PersonaId__c = '000000000',
      IdDocumentType__c = 'Licence',
      LicenceNumber__c = '123123',
      LicenceNumberOCRClient__c = '123123',
      LicenceNumberOCRServer__c = '123123',
      LicenceCardNumber__c = '456456',
      LicenceCardNumberOCRClient__c = '456456',
      LicenceCardNumberOCRServer__c = '456456'
    );

    List<COBPrimaryIDDocumentModel.TokenizedValue> tokenizedValues = COBPrimaryIDDocumentModel.buildTokenizedValues(
      pid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );
    System.assertEquals(
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size(),
      tokenizedValues.size(),
      'Should tokenized ' +
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS.size() +
      ' fields.'
    );
  }

  @isTest
  static void testConstructorWithParams() {
    COBPrimaryIDDocumentModel model = new COBPrimaryIDDocumentModel(
      'Passport',
      ''
    );

    model.primaryIdDocument.passport = new COBPrimaryIDDocumentModel.DocumentDetail(
      'firstName',
      'middleNames',
      'lastName'
    );

    model.primaryIdDocument.passport.dateOfBirth = new COBPrimaryIDDocumentModel.DateWrapper(
      Date.today()
    );

    model.primaryIdDocument.passport.expiryDate = new COBPrimaryIDDocumentModel.DateWrapper(
      Date.today()
    );

    System.assertEquals(
      COBPrimaryIDDocumentModel.PASSPORT_UPDATE_MASK,
      model.updateMask,
      'Should use COBPrimaryIDDocumentModel.PASSPORT_UPDATE_MASK'
    );
  }
}
