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

  static Faker faker = new Faker('AU');

  static COBTaxResidency__c taxResidency = new COBTaxResidency__c(
    PersonaId__c = faker.randomString(10),
    TaxIdentificationNumber__c = '123456789'
  );

  static COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
    PersonaId__c = faker.randomString(10),
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

  static Case idOpsCase = new Case(
    PersonaId__c = cobPid.PersonaId__c,
    RecordTypeId = RTCase.idOpsAssistance
  );

  static Case newCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.sObjectType),
    RecordTypeId = RTCase.idOpsAssistance,
    PersonaId__c = faker.randomString(15),
    Status = COBCaseConstants.COB_ID_OPS_DAON_OK_STATUS
  );

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

    Assert.areNotEqual(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  @isTest
  static void testClosePackageWithFailure() {
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

    Assert.areEqual(null, response.body, 'Response body should be null.');
  }

  @isTest
  static void testTriggerTemporalCaseWorkflowSuccess() {
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
    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.areEqual(
      '{"caseId":"' + newCase.Id + '"}',
      payload,
      'Payload is not correct.'
    );
  }

  @isTest
  static void testGetCaseWorkflowPayloadIdOpsEmpty() {
    Case newCase = new Case(
      ParentId = Lib_FakeIdGenerator.getMockId(Case.sObjectType),
      RecordTypeId = RTCase.idOpsAssistance,
      Status = COBCaseConstants.COB_ID_CHECK_OK_STATUS
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
  static void testGetCaseWorkflowPayloadFraudCheckEmpty() {
    Case newCase = new Case(
      ParentId = Lib_FakeIdGenerator.getMockId(Case.sObjectType),
      RecordTypeId = RTCase.fraudCheck,
      Status = COBCaseConstants.COB_ID_CHECK_OK_STATUS
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
    Case newCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.sObjectType),
      RecordTypeId = RTCase.idOpsAssistance,
      Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS,
      Subject = 'ID Ops Assistance - Daon Fallout: WATCHLIST_HIT'
    );

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.isFalse(String.isBlank(payload), 'Payload should not be empty.');
    Assert.areEqual(
      '{\"reason\":\"' +
        COBCaseConstants.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON +
        '\"}',
      payload,
      'Payload is not correct.'
    );
  }

  @isTest
  static void testGetCaseWorkflowPayloadFraudCheckConfirmedFraud() {
    Case newCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.sObjectType),
      RecordTypeId = RTCase.fraudCheck,
      Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    );

    Test.startTest();
    StravinskyService temporalCaseWorkflowAPI = new StravinskyService();
    String payload = temporalCaseWorkflowAPI.getCaseWorkflowPayload(newCase);
    Test.stopTest();

    Assert.isFalse(String.isBlank(payload), 'Payload should not be empty.');
    Assert.areEqual(
      '{\"reason\":\"' + COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS + '\"}',
      payload,
      'Payload is not correct.'
    );
  }

  @isTest
  static void testRetrieveDetokenizedCOBPIDSuccess() {
    Set<String> fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      cobPid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );
    DetokenizeRequestModel tokenizedValues = new DetokenizeRequestModel(
      fieldValues,
      COBPrimaryIDDocumentModel.TOKEN_TRANSFORM_VALUE
    );

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + cobPid.PersonaId__c,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockRetrieveDetokenizedCOBPIDSuccess()
    );

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.detokenize(
      cobPid.PersonaId__c,
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
    Set<String> fieldValues = COBPIDViewAndEditController.getTokenizedFieldValues(
      cobPid,
      COBPIDViewAndEditController.LICENCE_TOKENIZED_FIELDS
    );
    DetokenizeRequestModel tokenizedValues = new DetokenizeRequestModel(
      fieldValues,
      COBPrimaryIDDocumentModel.TOKEN_TRANSFORM_VALUE
    );

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + cobPid.PersonaId__c,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockRetrieveDetokenizedCOBPIDFailure()
    );

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.detokenize(
      cobPid.PersonaId__c,
      tokenizedValues
    );
    Test.stopTest();

    Assert.areEqual(401, response.statusCode, 'Status code should be 401.');
  }

  @isTest
  static void testTokenizeCOBPIDSuccess() {
    COBPrimaryIDDocUpdateRequestModel requestBody = new COBPrimaryIDDocUpdateRequestModel(
      cobPid,
      idOpsCase.Id
    );

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + cobPid.PersonaId__c,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockTokenizeCOBPIDSuccess());

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.updatePrimaryIDDocument(
      cobPid.PersonaId__c,
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
    COBPrimaryIDDocUpdateRequestModel requestBody = new COBPrimaryIDDocUpdateRequestModel(
      cobPid,
      idOpsCase.Id
    );

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + cobPid.PersonaId__c,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockTokenizeCOBPIDFailure());

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.updatePrimaryIDDocument(
      cobPid.PersonaId__c,
      requestBody
    );
    Test.stopTest();

    Assert.areEqual(401, response.statusCode, 'Status code should be 401.');
  }

  @isTest
  static void testRetrieveDetokenizedCOBTaxResidencySuccess() {
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
        'forgeJWTToken' +
        taxResidency.PersonaId__c,
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
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
        'forgeJWTToken' +
        taxResidency.PersonaId__c,
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
