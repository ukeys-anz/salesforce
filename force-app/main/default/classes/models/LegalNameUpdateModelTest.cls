/**
 * @author Karen Valeriano
 * @since Jan 2025
 * @description Test cases for @link LegalNameUpdateModel
 */
@IsTest
public with sharing class LegalNameUpdateModelTest {
  static final Faker FAKER = new Faker('AU');
  static Account acct = new Account(
    Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
    OCV_ID__c = FAKER.randomString(10),
    Source_System_ID__c = FAKER.randomString(10),
    Source_System_Name__c = 'CAP-CIS'
  );
  static Case caseLicence = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    NewFirstName__c = FAKER.person.firstName('male'),
    NewMiddleName__c = FAKER.randomString(5),
    NewLastName__c = FAKER.person.lastName(),
    DocumentType__c = LegalNameUpdateModel.DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE,
    LicenceNumber__c = FAKER.randomString(10),
    LicenceCardNumber__c = FAKER.randomString(15),
    ExpiryDate__c = Date.newInstance(2029, 12, 1),
    StateCode__c = FAKER.address.state(),
    CountryCode__c = 'AUS'
  );
  static Case casePassport = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    NewFirstName__c = FAKER.person.firstName('female'),
    NewMiddleName__c = FAKER.randomString(5),
    NewLastName__c = FAKER.person.lastName(),
    DocumentType__c = LegalNameUpdateModel.DOCUMENT_TYPE_AUSTRALIAN_PASSPORT,
    PassportNumber__c = FAKER.randomString(10),
    ExpiryDate__c = Date.newInstance(2029, 10, 10),
    CountryCode__c = 'AUS'
  );
  static Case caseCertificate = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    NewFirstName__c = FAKER.person.firstName('female'),
    NewMiddleName__c = FAKER.randomString(5),
    NewLastName__c = FAKER.person.lastName(),
    DocumentType__c = LegalNameUpdateModel.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE,
    CertificateIdentifier__c = FAKER.randomString(15),
    StateCode__c = FAKER.address.state()
  );

  @IsTest
  static void testConstructorDefaults() {
    Test.startTest();
    LegalNameUpdateModel model = new LegalNameUpdateModel(caseLicence, acct);
    Test.stopTest();

    Assert.areEqual(
      LegalNameUpdateModel.PARTY_TYPE,
      model.partyType,
      'partyType value not correct'
    );
    Assert.areEqual(
      LegalNameUpdateModel.SOURCE_VALUE,
      model.source,
      'source value not correct'
    );
  }

  @IsTest
  static void testCustomerIdentifierConstructor() {
    Test.startTest();
    LegalNameUpdateModel.CustomerIdentifier model = new LegalNameUpdateModel.CustomerIdentifier(
      acct.OCV_ID__c
    );
    Test.stopTest();

    Assert.areEqual(
      LegalNameUpdateModel.CUSTOMER_IDENTIFIER_USAGE_TYPE,
      model.identifierUsageType,
      'identifierUsageType is incorrect.'
    );
    Assert.areEqual(
      acct.OCV_ID__c,
      model.identifier,
      'identifier is incorrect.'
    );
  }

  @IsTest
  static void testNameConstructor() {
    Test.startTest();
    LegalNameUpdateModel.Name model = new LegalNameUpdateModel.Name(
      caseLicence
    );
    Test.stopTest();

    Assert.areEqual(
      caseLicence.NewFirstName__c,
      model.firstName,
      'firstName is incorrect.'
    );
    Assert.areEqual(
      caseLicence.NewMiddleName__c,
      model.middleName,
      'middleName is incorrect.'
    );
    Assert.areEqual(
      caseLicence.NewLastName__c,
      model.lastName,
      'lastName is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.NAME_USAGE_TYPE,
      model.nameUsageType,
      'nameUsageType is incorrect.'
    );
  }

  @IsTest
  static void testRelatedEntityConstructor() {
    Test.startTest();
    LegalNameUpdateModel.RelatedEntity model = new LegalNameUpdateModel.RelatedEntity(
      casePassport
    );
    Test.stopTest();

    Assert.areEqual(
      LegalNameUpdateModel.ENTITY_RELATIONSHIP_TYPE,
      model.entityRelationshipType,
      'entityRelationshipType is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.SOURCE_VALUE,
      model.source,
      'source is incorrect.'
    );
  }

  @IsTest
  static void testVerificationDetailConstructor() {
    Test.startTest();
    LegalNameUpdateModel.VerificationDetail model = new LegalNameUpdateModel.VerificationDetail(
      caseLicence
    );
    Test.stopTest();

    Assert.areEqual(
      LegalNameUpdateModel.CHANNEL_VALUE,
      model.channel,
      'channel is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.VERIFICATION_ATTRIBUTE,
      model.verificationAttribute,
      'verificationAttribute is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.VERIFICATION_METHOD,
      model.verificationMethod,
      'verificationMethod is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.VERIFIED_BY,
      model.verifiedBy,
      'verifiedBy is incorrect.'
    );
  }

  @IsTest
  static void testDocumentIdentifierLicenceConstructor() {
    Test.startTest();
    LegalNameUpdateModel.DocumentIdentifier model = new LegalNameUpdateModel.DocumentIdentifier(
      caseLicence
    );
    Test.stopTest();

    Assert.areEqual(
      getEncryptedFormat(caseLicence.LicenceNumber__c),
      model.identifier,
      'doc identifier is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.getFormattedDate(caseLicence.ExpiryDate__c),
      model.expiryDate,
      'expiryDate is incorrect.'
    );
    Assert.areEqual(
      caseLicence.StateCode__c,
      model.identificationState,
      'identificationState is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.DOC_TYPE_MAP.get(caseLicence.DocumentType__c),
      model.identifierUsageType,
      'identifierUsageType is incorrect.'
    );
    Assert.areEqual(
      getEncryptedFormat(caseLicence.LicenceCardNumber__c),
      model.relatedIdentifiers[0].identifier,
      'relatedIdentifier is incorrect.'
    );
  }

  @IsTest
  static void testDocumentIdentifierPassportConstructor() {
    Test.startTest();
    LegalNameUpdateModel.DocumentIdentifier model = new LegalNameUpdateModel.DocumentIdentifier(
      casePassport
    );
    Test.stopTest();

    Assert.areEqual(
      getEncryptedFormat(casePassport.PassportNumber__c),
      model.identifier,
      'doc identifier is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.getFormattedDate(casePassport.ExpiryDate__c),
      model.expiryDate,
      'expiryDate is incorrect.'
    );
    Assert.areEqual(
      LegalNameUpdateModel.DOC_TYPE_MAP.get(casePassport.DocumentType__c),
      model.identifierUsageType,
      'identifierUsageType is incorrect.'
    );
    Assert.isNull(
      model.relatedIdentifiers,
      'there should be no relatedIdentifiers'
    );
  }

  @IsTest
  static void testDocumentIdentifierOtherDocTypeConstructor() {
    Test.startTest();
    LegalNameUpdateModel.DocumentIdentifier model = new LegalNameUpdateModel.DocumentIdentifier(
      caseCertificate
    );
    Test.stopTest();

    Assert.areEqual(
      getEncryptedFormat(caseCertificate.CertificateIdentifier__c),
      model.identifier,
      'doc identifier is incorrect.'
    );
    Assert.areEqual(
      caseCertificate.StateCode__c,
      model.identificationState,
      'identificationState is incorrect.'
    );
    Assert.isNull(
      model.relatedIdentifiers,
      'there should be no relatedIdentifiers'
    );
  }

  @IsTest
  static void testLegalNameUpdateModelConstructor() {
    Test.startTest();
    LegalNameUpdateModel model = new LegalNameUpdateModel(caseLicence, acct);
    Test.stopTest();

    Assert.isFalse(
      model.identifiers.isEmpty(),
      'identifiers should have records'
    );
    Assert.isFalse(model.names.isEmpty(), 'names should have records');
    Assert.isFalse(
      model.names[0].relatedEntities.isEmpty(),
      'relatedEntities should have records'
    );
    Assert.isFalse(
      model.names[0].verificationDetails.isEmpty(),
      'verificationDetails should have records'
    );
    Assert.isFalse(
      model.names[0].relatedEntities[0].identifiers.isEmpty(),
      'relatedEntities.identifiers should have records'
    );
    Assert.isFalse(
      model.names[0]
        .relatedEntities[0]
        .identifiers[0]
        .relatedIdentifiers.isEmpty(),
      'relatedEntities.identifiers.relatedIdentifiers should have records'
    );
  }

  private static String getEncryptedFormat(String identifier) {
    return 'enc(' + identifier + ')';
  }
}
