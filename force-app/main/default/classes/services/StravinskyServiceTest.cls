/**
 * @author Paul Boyington
 * @since May 2022
 * @description Test class for {@link StravinskyService}
 * @group Services
 */
@isTest
public inherited sharing class StravinskyServiceTest {
  private static final String SUCCESS_CLOSE_PACKAGE_RESPONSE =
    '{' +
    '   \"accountsClosed\": "1"' +
    '   \"cardsClosed\": "0"' +
    '   \"packagesClosed\": "0"' +
    '   \"errorInfo\": "null" ' +
    '}';

  private static final String FAILURE_CLOSE_PACKAGE_RESPONSE =
    '{' +
    '   \"accountsClosed\": "1"' +
    '   \"cardsClosed\": "0"' +
    '   \"packagesClosed\": "0"' +
    '  \"errorInfo\": { \"errorCode\": 500, \"reason\": \"some reason here\" },' +
    '}';

  private static final String TEMPORAL_CASE_WORKFLOW_TRIGGER_RESPONSE_SUCCESS = '{}';

  private static final String TEMPORAL_CASE_WORKFLOW_TRIGGER_RESPONSE_FAILURE =
    '{' +
    '   \"code\": 100,' +
    '   \"message\": \"WorkflowId is not set on request.\"' +
    '}';

  private static final String ACCOUNT_CLOSURE_DETAILS =
    '{' +
    '   \"ocv_ids\": [103245756],' +
    '   \"items\":[' +
    '{\"account_resource\":"accounts/111111111",' +
    '{\"account_resource\":"accounts/000000000",' +
    '{\"package_resource\":"jfhfhjfjhfjhf",' +
    ']' +
    '}';

  @isTest
  static void getRealService() {
    Test.startTest();
    Service stravinskyService = (Service) ServiceProvider.getService(
      StravinskyService.class
    );
    Test.stopTest();
    System.assert(
      stravinskyService instanceof StravinskyServiceMock,
      'Service should be instance of StravinskyServiceMock.'
    );
  }

  @isTest
  static void testClosePackageSuccess() {
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);

    Test.setMock(HttpCalloutMock.class, new MockClosePackageSuccess());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.closePackage(
      ocvId,
      ACCOUNT_CLOSURE_DETAILS
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  @isTest
  static void testClosePackageWithFailure() {
    Faker faker = new Faker('AU');

    String ocvId = faker.randomString(10);

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
    Test.setMock(HttpCalloutMock.class, new MockClosePackageFailure());

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.closePackage(
      ocvId,
      ACCOUNT_CLOSURE_DETAILS
    );
    Test.stopTest();

    System.assertEquals(null, response.body, 'Response body should be null.');
  }

  @isTest
  static void testTriggerTemporalCaseWorkflowSuccess() {
    Faker faker = new Faker('AU');
    Case newCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      PersonaId__c = faker.randomString(15),
      Status = GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS
    );

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + newCase.PersonaId__c,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockTemporalCaseWorkflowSuccess());

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    HttpCalloutResponse response = temporalCaseWorkflowAPI.triggerTemporalCaseWorkflow(
      newCase
    );

    Test.stopTest();

    Assert.areEqual(200, response.statusCode, 'Status code should be 200.');
  }

  @isTest
  static void testTriggerTemporalCaseWorkflowFailure() {
    Faker faker = new Faker('AU');
    Case newCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      PersonaId__c = faker.randomString(15),
      Status = GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS
    );

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + newCase.PersonaId__c,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockTemporalCaseWorkflowFailure());

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    HttpCalloutResponse response = temporalCaseWorkflowAPI.triggerTemporalCaseWorkflow(
      newCase
    );
    Test.stopTest();

    Assert.areEqual(400, response.statusCode, 'Status code should be 400.');
  }

  @isTest
  static void testGetCaseWorkflowPayloadIdOpsDaonApproved() {
    Faker faker = new Faker('AU');
    Id mockId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType());
    Case newCase = new Case(
      Id = mockId,
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      Status = GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS
    );

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.isFalse(String.isBlank(payload), 'Payload should not be empty.');
    Assert.areEqual(
      '{\"caseId\":\"' + mockId + '\"}',
      payload,
      'Payload is not correct.'
    );
  }

  @isTest
  static void testGetCaseWorkflowPayloadIdOpsEmpty() {
    Faker faker = new Faker('AU');
    Case newCase = new Case(
      ParentId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      Status = GetHelpConstants.COB_EQUIFAX_PASSED_STATUS
    );

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.areEqual(
      StravinskyService.EMPTY_BODY,
      payload,
      'Payload should be empty body {}.'
    );
  }

  @isTest
  static void testGetCaseWorkflowPayloadFraudCheckDaonApproved() {
    Faker faker = new Faker('AU');
    Id mockId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType());
    Case newCase = new Case(
      ParentId = mockId,
      RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID,
      Status = GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS
    );

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.isFalse(String.isBlank(payload), 'Payload should not be empty.');
    Assert.areEqual(
      '{\"caseId\":\"' + mockId + '\"}',
      payload,
      'Payload is not correct.'
    );
  }

  @isTest
  static void testGetCaseWorkflowPayloadFraudCheckEmpty() {
    Faker faker = new Faker('AU');
    Case newCase = new Case(
      ParentId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID,
      Status = GetHelpConstants.COB_EQUIFAX_PASSED_STATUS
    );

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.areEqual(
      StravinskyService.EMPTY_BODY,
      payload,
      'Payload should be empty body {}.'
    );
  }

  @isTest
  static void testGetCaseWorkflowPayloadIdOpsWatchlistConfirmedFraud() {
    Faker faker = new Faker('AU');
    Id mockId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType());
    Case newCase = new Case(
      Id = mockId,
      RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
      Status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS,
      Subject = 'ID Ops Assistance - Daon Fallout: WATCHLIST_HIT'
    );

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.isFalse(String.isBlank(payload), 'Payload should not be empty.');
    Assert.areEqual(
      '{\"reason\":\"' +
        GetHelpConstants.ONBOARDING_FAILED_REASON_CONFIRMED_FRAUD_WATCHLIST +
        '\"}',
      payload,
      'Payload is not correct.'
    );
  }

  @isTest
  static void testGetCaseWorkflowPayloadFraudCheckConfirmedFraud() {
    Faker faker = new Faker('AU');
    Id mockId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType());
    Case newCase = new Case(
      Id = mockId,
      RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID,
      Status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    );

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.isFalse(String.isBlank(payload), 'Payload should not be empty.');
    Assert.areEqual(
      '{\"reason\":\"' + GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS + '\"}',
      payload,
      'Payload is not correct.'
    );
  }

  @isTest
  static void testRetrieveDetokenizedCOBPIDSuccess() {
    Faker faker = new Faker('AU');
    String personaId = faker.randomString(10);

    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      PersonaId__c = personaId,
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

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + personaId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockRetrieveDetokenizedCOBPIDSuccess()
    );

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.detokenizeCOBPID(
      personaId,
      tokenizedValues
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  @isTest
  static void testRetrieveDetokenizedCOBPIDFailure() {
    Faker faker = new Faker('AU');
    String personaId = faker.randomString(10);

    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      PersonaId__c = personaId,
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

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + personaId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockRetrieveDetokenizedCOBPIDFailure()
    );

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.detokenizeCOBPID(
      personaId,
      tokenizedValues
    );
    Test.stopTest();

    Assert.areEqual(401, response.statusCode, 'Status code should be 401.');
  }

  @isTest
  static void testTokenizeCOBPIDSuccess() {
    Faker faker = new Faker('AU');
    String personaId = faker.randomString(10);

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

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + personaId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockTokenizeCOBPIDSuccess());

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.tokenizeCOBPID(
      personaId,
      requestBody
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  @isTest
  static void testTokenizeCOBPIDFailure() {
    Faker faker = new Faker('AU');
    String personaId = faker.randomString(10);

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

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + personaId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockTokenizeCOBPIDFailure());

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.tokenizeCOBPID(
      personaId,
      requestBody
    );
    Test.stopTest();

    Assert.areEqual(401, response.statusCode, 'Status code should be 401.');
  }

  @isTest
  static void testRetrieveDetokenizedCOBTaxResidencySuccess() {
    Faker faker = new Faker('AU');
    String personaId = faker.randomString(10);

    COBTaxResidency__c taxResidency = new COBTaxResidency__c(
      PersonaId__c = personaId,
      TaxIdentificationNumber__c = '123456789'
    );

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + personaId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockRetrieveDetokenizedCOBTaxResidencySuccess()
    );

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.detokenizeCOBTaxResidency(
      taxResidency
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      response.body,
      'Response body should not be null.'
    );

    Assert.areEqual(
      StravinskyServiceMock.DETOKENIZED_COB_TAX_RESIDENCY_SUCCESS_RESPONSE,
      response.body,
      'Response is not correct.'
    );
  }

  @isTest
  static void testRetrieveDetokenizedCOBTaxResidencyFailure() {
    Faker faker = new Faker('AU');
    String personaId = faker.randomString(10);

    COBTaxResidency__c taxResidency = new COBTaxResidency__c(
      PersonaId__c = personaId,
      TaxIdentificationNumber__c = '123456789'
    );

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + personaId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockRetrieveDetokenizedCOBTaxResidencyFailure()
    );

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.detokenizeCOBTaxResidency(
      taxResidency
    );
    Test.stopTest();

    Assert.areEqual(401, response.statusCode, 'Status code should be 401.');
  }

  @isTest
  static void testGetDetokenizePayload() {
    COBTaxResidency__c taxResidency = new COBTaxResidency__c(
      TaxIdentificationNumber__c = '123456789'
    );

    StravinskyService stravinskyService = new StravinskyService();
    String payload = stravinskyService.getDetokenizePayload(taxResidency);

    Assert.isFalse(String.isBlank(payload), 'Payload should not be empty.');
    Assert.areEqual(
      '{' +
        '\"values\":[' +
        '{' +
        '\"transform\":\"' +
        COBTaxResidencyModel.TIN_TRANSFORM +
        '",' +
        '\"tokenized":\"' +
        taxResidency.TaxIdentificationNumber__c +
        '"}' +
        ']' +
        '}',
      payload,
      'Payload is not correct.'
    );
  }

  class MockClosePackageSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(200);
      res.setBody(SUCCESS_CLOSE_PACKAGE_RESPONSE);

      res.setHeader('Content-Type', 'application/json');

      return res;
    }
  }

  class MockClosePackageFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(FAILURE_CLOSE_PACKAGE_RESPONSE);

      return res;
    }
  }

  class MockTemporalCaseWorkflowSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(200);
      res.setBody(TEMPORAL_CASE_WORKFLOW_TRIGGER_RESPONSE_SUCCESS);

      res.setHeader('Content-Type', 'application/json');

      return res;
    }
  }

  class MockTemporalCaseWorkflowFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(400);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(TEMPORAL_CASE_WORKFLOW_TRIGGER_RESPONSE_FAILURE);

      return res;
    }
  }

  class MockRetrieveDetokenizedCOBPIDSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        StravinskyServiceMock.SUCCESS_RETRIEVE_DETOKENIZED_COBPID_RESPONSE
      );

      return res;
    }
  }

  class MockRetrieveDetokenizedCOBPIDFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(401);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        StravinskyServiceMock.FAILURE_RETRIEVE_DETOKENIZED_COBPID_RESPONSE
      );

      return res;
    }
  }

  class MockTokenizeCOBPIDSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(StravinskyServiceMock.SUCCESS_TOKENIZING_COBPID_RESPONSE);

      return res;
    }
  }

  class MockTokenizeCOBPIDFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(401);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(StravinskyServiceMock.FAILURE_TOKENIZING_COBPID_RESPONSE);

      return res;
    }
  }

  class MockRetrieveDetokenizedCOBTaxResidencySuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        StravinskyServiceMock.DETOKENIZED_COB_TAX_RESIDENCY_SUCCESS_RESPONSE
      );

      return res;
    }
  }

  class MockRetrieveDetokenizedCOBTaxResidencyFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(401);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        StravinskyServiceMock.DETOKENIZED_COB_TAX_RESIDENCY_FAILURE_RESPONSE
      );

      return res;
    }
  }
}
