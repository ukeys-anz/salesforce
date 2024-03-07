/**
 * @author Hrushikesh
 * @since Dec 2023
 * @description SigningAuthorityControllerTest is provide unit test coverage for SigningAuthorityController.
 */
@isTest
private class SigningAuthorityControllerTest {
  private static Faker faker;

  /**
   * @description Mock update signing authority api callout
   */
  class MockSigningAuthorityCalloutFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  /**
   * @description Mock update signing authority api callout
   */
  class MockSigningAuthorityCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  // Test method to check the success response of the api
  @isTest
  static void testSigngingAuthority() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Test.setMock(
      HttpCalloutMock.class,
      new SigningAuthorityControllerTest.MockSigningAuthorityCallout()
    );

    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = faker.randomString(10);
    accnt.Id = '0019p000000' + faker.randomString(7);

    FinServ__FinancialAccount__c finAccount = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.CHECKING_ACCOUNT_RT_ID,
      accnt.Id,
      false
    );
    Test.startTest();
    SigningAuthorityController ctrl = new SigningAuthorityController();
    inputMap.put('finAccountNumber', '3441231222');
    inputMap.put('numberOfSign', '1');
    inputMap.put('ocvId', accnt.OCV_Id__c);
    inputMap.put('finAccountId', finAccount.Id);

    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + accnt.OCV_Id__c,
      AuthServiceTest.IDTESTVALUE
    );

    Boolean isInvoked = (Boolean) ctrl.call(
      'updateSigningAutority',
      new Map<String, Object>{
        'input' => inputMap,
        'output' => outMap,
        'options' => options
      }
    );
    Test.stopTest();
    Assert.areEqual(
      outMap.get('httpCode'),
      '200',
      'Response should be Success'
    );
  }

  // Test method to check the failure response of the api
  @isTest
  static void testFailureSigngingAuthority() {
    Test.setMock(
      HttpCalloutMock.class,
      new SigningAuthorityControllerTest.MockSigningAuthorityCalloutFailure()
    );

    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = faker.randomString(10);
    accnt.Id = '0019p000000' + faker.randomString(7);

    FinServ__FinancialAccount__c finAccount = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.CHECKING_ACCOUNT_RT_ID,
      accnt.Id,
      false
    );
    finAccount.FinServ__FinancialAccountNumber__c = '7890878903';

    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + accnt.OCV_Id__c,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    FabricService signServ = new FabricService();
    HttpCalloutResponse res = signServ.updateSigningAutority(
      finAccount.FinServ__FinancialAccountNumber__c,
      2,
      accnt.OCV_ID__c
    );
    Test.stopTest();
    Assert.areEqual(res.statusCode, 500, 'Status Code should be 500');
  }

  // Method to test the update pending customer action record with error info
  @isTest
  static void testCustomerActionUpdates() {
    Faker faker = new Faker('AU');
    Account accnt = new Account();
    accnt.Name = 'TestAccount';
    accnt.Display_Name__c = 'TestAccount';
    accnt.OCV_ID__c = faker.randomString(10);
    accnt.ANZx_Customer__c = true;
    accnt.External_Id__c = faker.randomString(10);
    accnt.Id = '0019p000000' + faker.randomString(7);

    FinServ__FinancialAccount__c finAccount = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.CHECKING_ACCOUNT_RT_ID,
      accnt.Id,
      false
    );
    List<Customer_Action__c> customerActionRecords = new List<Customer_Action__c>();
    Customer_Action__c ca = TestDataFactory.createCustomerActionRecord(
      GetHelpConstants.CUSTOMER_ACTION_FIN_ACCOUNT_UPDATE_RT_ID,
      accnt.Id,
      finAccount.Id,
      false
    );
    customerActionRecords.add(ca);
    AlterAccountSignModeModel signingModel = new AlterAccountSignModeModel();
    signingModel.status = 'Error';
    Test.startTest();
    List<Customer_Action__c> updatedCustomerActionList = SigningAuthorityController.updateCustomerAction(
      signingModel,
      customerActionRecords
    );
    // Dummy callout for test coverage
    SigningAuthorityController.processCustomerAction(
      signingModel,
      finAccount.Id
    );
    Test.stopTest();
    Assert.areEqual(
      GetHelpFinancialAccountActions.CUSTOMER_ACTION_ERROR,
      updatedCustomerActionList[0].Status__c,
      'Customer Action Status Should be Error'
    );
  }
}
