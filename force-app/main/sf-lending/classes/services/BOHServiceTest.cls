/**
 * @author cruzb
 * @since May 2023
 * @description Service test class for BOH Service
 * @group Services
 */
@isTest
public inherited sharing class BOHServiceTest {
  class MockGearboxCalloutSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource mockResponse;

      mockResponse = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_CRListAssessment'
        WITH SECURITY_ENFORCED
      ];

      HttpResponse res = new HttpResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(mockResponse.Body.toString());

      return res;
    }
  }

  static StaticResourceCalloutMock staticMockResponse() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('mock_CRListAssessment');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/json');

    return mock;
  }

  @isTest
  static void testGetListAssets() {
    String ocvId = '11111231';
    String sopid = 'test';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.getListAssets(ocvId, sopid);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetCreditAssessmentsSuccess() {
    String credId = '1111';
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.getCreditAssessments(credId, ocvId);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testEditDebts() {
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, new MockGearboxCalloutSuccess());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    String testDebt = '{"name": "testDebt", "uid", "testStr"}';
    HttpCalloutResponse response = service.editDebt(ocvId, testDebt);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testCreateIncome() {
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    BOHService service = new BOHService();
    String incomeBody = ' {"uid":"0482747e-468f-40af-b1ed-ac09987e379e","name":"sops/c794dbe0-874b-4b04-85b4-8ea296200218/incomes/0482747e-468f-40af-b1ed-ac09987e379e","etag":"1737647185596307171","incomeVerifiedChanged":true,"incomeVerified":true,"details":[{"amountType":"INCOME_AMOUNT_TYPE_GROSS","amountValue":3456,"bonusPayments":0,"frequency":"INCOME_FREQUENCY_MONTHLY","type":"INCOME_TYPE_BASE_SALARY","isBonuses":false,"readableFrequency":"Monthly","categoryOfIncome":"Before Tax","itemHeading":"Base Salary","isBase":true,"isOverTime":false,"isCommission":false}],"employment":{"basis":"EMPLOYMENT_BASIS_FULL_TIME","businessName":"Test","partyId":"44a62254-601c-5530-a416-f338a1c537f6","startDate":{"year":2025,"month":1,"day":23},"type":"EMPLOYMENT_TYPE_PAYG","startDateValue":"2025-01-23"}}';
    HttpCalloutResponse response = service.createIncome(
      'Yes',
      ocvId,
      incomeBody
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testUpdateIncome() {
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    BOHService service = new BOHService();
    String incomeBody = ' {"uid":"0482747e-468f-40af-b1ed-ac09987e379e","name":"sops/c794dbe0-874b-4b04-85b4-8ea296200218/incomes/0482747e-468f-40af-b1ed-ac09987e379e","etag":"1737647185596307171","incomeVerifiedChanged":true,"incomeVerified":true,"details":[{"amountType":"INCOME_AMOUNT_TYPE_GROSS","amountValue":3456,"bonusPayments":0,"frequency":"INCOME_FREQUENCY_MONTHLY","type":"INCOME_TYPE_BASE_SALARY","isBonuses":false,"readableFrequency":"Monthly","categoryOfIncome":"Before Tax","itemHeading":"Base Salary","isBase":true,"isOverTime":false,"isCommission":false}],"employment":{"basis":"EMPLOYMENT_BASIS_FULL_TIME","businessName":"Test","partyId":"44a62254-601c-5530-a416-f338a1c537f6","startDate":{"year":2025,"month":1,"day":23},"type":"EMPLOYMENT_TYPE_PAYG","startDateValue":"2025-01-23"}}';
    HttpCalloutResponse response = service.updateIncome(
      'Yes',
      ocvId,
      incomeBody,
      false
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testViewUMIRequest() {
    List<String> sopIds = new List<String>{ '123456789' };
    String creditEnquiryId = '12345';
    String ocvId = '11111231';
    Integer termMonths = 60;
    Decimal loanAmount = 123.12;
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.getUMIAssessments(
      sopIds,
      creditEnquiryId,
      ocvId,
      termMonths,
      loanAmount
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetSOP() {
    String sopId = '12345';
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.getSOP(ocvId, sopId);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testDeleteIncome() {
    String sopId = '12345';
    String ocvId = '11111231';
    String deleModel = '{"delete model":"sdfsdfsdf","etag":"1234"}';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.deleteIncome(
      sopId,
      ocvId,
      deleModel
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testVerifyInsurance() {
    String requestbody = 'testbody';
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.verifyInsurance(requestbody, ocvId);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testCreateDebt() {
    String ocvId = '11111231';
    String debtBody = '{"name": "testDebt", "amount": 1000}';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.createDebt(ocvId, debtBody);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testDeleteDebt() {
    String sopId = '3242342-234';
    String deleModel = '{"delete model":"sdfsdfsdf","etag":"1234"}';
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.deleteDebt(sopId, ocvId, deleModel);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testCancelResidentialLoanApp() {
    String loanAppNumber = '12345';
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.cancelResidentialLoanApp(
      loanAppNumber,
      ocvId
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testDeleteReferralOutcome() {
    String creditId = '1111';
    String assessmentId = '2222';
    String ocvId = '11111231';
    String outcomeCode = 'OUTCOME_CODE';
    Test.setMock(HttpCalloutMock.class, new MockGearboxCalloutSuccess());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.deleteReferralOutcome(
      creditId,
      assessmentId,
      ocvId,
      outcomeCode
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testCreateCreditEnquiryAssessment() {
    String ocvId = '11111231';
    String payload = '{"creditId":"1111","referralOutcome":"APPROVED","uuid":"1234"}';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.createCreditEnquiryAssessment(
      payload,
      ocvId
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testCreditReassessment() {
    String ocvId = '11111231';
    String payload = '{"name": "testReassessment", "amount": 1000}';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.creditReassessment(payload, ocvId);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testFinaliseAssessment() {
    String creditId = '1111';
    String assessmentId = '12345';
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.finaliseAssessment(
      creditId,
      assessmentId,
      ocvId
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testEditExpense() {
    String ocvId = '11111231';
    String expenseBody = '{"name": "testExpense", "amount": 500}';
    Test.setMock(HttpCalloutMock.class, staticMockResponse());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.editExpense(ocvId, expenseBody);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }
}
