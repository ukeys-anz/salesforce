/**
 * @author Paul Boyington
 * @since May 2022
 * @description Test class for StravinskyAPIRepository
 */
@isTest
public with sharing class StravinskyAPIRepositoryTest {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = faker.randomString(10)
    );

    insert acc;
  }

  @isTest
  static void testPackageClosureSuccess() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    Faker faker = new Faker('AU');
    Case newCase = new Case(
      AccountId = acc.Id,
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID,
      Package_Id__c = faker.randomString(10)
    );
    String checkingAccount = faker.randomString(15);
    String savingsAccount = faker.randomString(15);

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();

    PackageClosureModel response = stravinskyApi.packageClosure(
      newCase,
      checkingAccount,
      savingsAccount
    );
    PackageClosureModel.Status status = response.status;

    Test.stopTest();
    System.assertEquals(200, status.code, 'Status code of 200 expected');
    System.assertEquals(
      'Package closure successfully completed',
      status.description,
      'Package closure was not successful'
    );
  }

  /**
   * @description fetch invalid statement
   */
  @isTest
  static void closePackageInvalidResponse() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
    ];

    Faker faker = new Faker('AU');
    Case newCase = new Case(
      AccountId = acc.Id,
      RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID
    );
    String checkingAccount = faker.randomString(15);
    String savingsAccount = faker.randomString(15);

    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);
    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    try {
      PackageClosureModel response = stravinskyApi.packageClosure(
        newCase,
        checkingAccount,
        savingsAccount
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    System.assertEquals(
      'exception occured',
      resultException.getMessage(),
      'Exception was expected'
    );
  }

  /**
   * @description fetch invalid statement
   */
  @isTest
  static void testTriggerTemporalCaseWorkflowFailureResponse() {
    Faker faker = new Faker('AU');
    Case newCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      PersonaId__c = faker.randomString(15),
      Status = GetHelpConstants.COB_DAON_FAILED_STATUS
    );

    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);

    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository temporalCaseWorkflowAPI = new StravinskyAPIRepository();
    try {
      temporalCaseWorkflowAPI.triggerTemporalCaseWorkflow(newCase);
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.areEqual(
      'exception occured',
      resultException.getMessage(),
      'Exception was expected'
    );
  }

  /**
   * @description Mock exception response
   * @return HttpCalloutResponse
   */
  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('exception occured');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  @isTest
  static void testCobPIdDetokenizationSuccess() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
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
      cobPid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    COBPrimaryIDDocumentModel response = stravinskyApi.cobPidDetokenization(
      cobPid.PersonaId__c,
      tokenizedValues
    );
    Test.stopTest();

    Assert.isTrue(
      !response.values.isEmpty(),
      'Response should have valid detokenized values.'
    );
  }

  @isTest
  static void testRetrieveDetokenizedCOBPIDInvalidResponse() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
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
      cobPid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );

    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);

    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    try {
      stravinskyApi.cobPidDetokenization(cobPid.PersonaId__c, tokenizedValues);
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    System.assertEquals(
      'exception occured',
      resultException.getMessage(),
      'Exception was expected'
    );
  }

  @isTest
  static void testCobPidTokenizationSuccess() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      PersonaId__c = '000000000',
      IdDocumentType__c = 'Licence',
      FirstName__c = 'firstName',
      MiddleNames__c = 'middle names',
      LastName__c = 'lastName',
      DateOfBirth__c = Date.today(),
      LicenceNumber__c = '123123',
      LicenceNumberOCRClient__c = '123123',
      LicenceNumberOCRServer__c = '123123',
      LicenceCardNumber__c = '456456',
      LicenceCardNumberOCRClient__c = '456456',
      LicenceCardNumberOCRServer__c = '456456',
      ExpiryDate__c = Date.today(),
      StateOfIssue__c = 'AU'
    );

    COBPrimaryIDDocumentModel requestBody = COBPrimaryIDDocumentModel.buildUpdateRequestBody(
      cobPid
    );

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    COBPrimaryIDDocumentModel response = stravinskyApi.cobPidTokenization(
      cobPid.PersonaId__c,
      requestBody
    );
    Test.stopTest();

    Assert.isTrue(
      String.isNotEmpty(response.passport.passportNumberToken.value),
      'Response should have valid tokenized values.'
    );
  }

  @isTest
  static void testCobPidTokenizationFailure() {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      PersonaId__c = '000000000',
      IdDocumentType__c = 'Licence',
      FirstName__c = 'firstName',
      MiddleNames__c = 'middle names',
      LastName__c = 'lastName',
      DateOfBirth__c = Date.today(),
      LicenceNumber__c = '123123',
      LicenceNumberOCRClient__c = '123123',
      LicenceNumberOCRServer__c = '123123',
      LicenceCardNumber__c = '456456',
      LicenceCardNumberOCRClient__c = '456456',
      LicenceCardNumberOCRServer__c = '456456',
      ExpiryDate__c = Date.today(),
      StateOfIssue__c = 'AU'
    );

    COBPrimaryIDDocumentModel requestBody = COBPrimaryIDDocumentModel.buildUpdateRequestBody(
      cobPid
    );

    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(StravinskyService.class);
    s.setCalloutResponse(res);

    Exception resultException;

    Test.startTest();
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    try {
      stravinskyApi.cobPidTokenization(cobPid.PersonaId__c, requestBody);
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();

    Assert.areEqual(
      'exception occured',
      resultException.getMessage(),
      'Exception was expected'
    );
  }
}
