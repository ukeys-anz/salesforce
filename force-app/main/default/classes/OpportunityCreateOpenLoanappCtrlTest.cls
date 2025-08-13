@isTest
private class OpportunityCreateOpenLoanappCtrlTest {
  //jwt containing a single claim of exp 26/11/2050
  public final static String IDTESTVALUE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI1NTMwMzIxNzh9.eAWGLhTYhn4y9M2t2OHeTLIe7MLPObBFK2Nli8CPTD4';
  static Lib_MockProvider controllerRepoMock;
  static Lib_MockProvider dmlMockProvider;
  static Lib_MockProvider loanAppServiceMock;
  static void registerMocks() {
    controllerRepoMock = Lib_MockProvider.forType(
      OpportunityCreateOpenLoanappRepository.class
    );
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
    loanAppServiceMock = Lib_MockProvider.forType(LoanappService.class);
  }
  private static Id newOppId = Lib_FakeIdGenerator.getMockId(
    Schema.Opportunity.getSObjectType()
  );
  private static Id newAccId = Lib_FakeIdGenerator.getMockId(
    Schema.Account.getSObjectType()
  );
  private static Id newConId = Lib_FakeIdGenerator.getMockId(
    Schema.Contact.getSObjectType()
  );
  private static Account cust = new Account(
    Id = newAccId,
    FirstName = 'Test',
    LastName = 'Test',
    Salutation = 'Mrs',
    External_Id__c = 'CAP-CIS_4011643101',
    Name = 'Test Test',
    RecordTypeId = CCRMConstants.ACCOUNT_PERSON_RT_ID
  );
  private static Opportunity opp = new Opportunity(
    Id = newOppId,
    AccountId = newAccId,
    Name = 'Test',
    StageName = 'Needs Analysis',
    Amount = 5000,
    Customer_Needs__c = 'Home Loan - Other',
    CloseDate = Date.today() + 5
  );
  private static OpportunityContactRole ocr = new OpportunityContactRole(
    OpportunityId = newOppId,
    ContactId = newConId,
    Role = 'Applicant'
  );

  private static User_Territory__c ut = new User_Territory__c(
    SAO__c = '719',
    Id = Lib_FakeIdGenerator.getMockId(
      Schema.User_Territory__c.getSObjectType()
    )
  );

  @isTest
  static void getOpportunityDetailsTest() {
    registerMocks();
    Opportunity oppTest = (Opportunity) TestUtil.setFields(
      opp,
      new Map<String, Object>{
        'OpportunityContactRoles' => new List<OpportunityContactRole>{ ocr }
      }
    );
    controllerRepoMock.mock('getOpportunity', oppTest);
    Test.startTest();
    String oppJson = OpportunityCreateOpenLoanappController.getOpportunityDetails(
      newOppId
    );
    Opportunity returnedOpp = (Opportunity) JSON.deserialize(
      oppJson,
      Opportunity.class
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      returnedOpp.OpportunityContactRoles.size(),
      'There should be one OCR Record'
    );
    Assert.areEqual(
      'Needs Analysis',
      returnedOpp.StageName,
      'The Opportunity should be in Needs Analysis stage!'
    );
  }

  @isTest
  static void getOpportunityDetailsTestNegative() {
    registerMocks();
    controllerRepoMock.mockException('getOpportunity', new QueryException());
    try {
      Test.startTest();
      OpportunityCreateOpenLoanappController.getOpportunityDetails(newOppId);
      Test.stopTest();
      Assert.isTrue(false, 'code was supposed to error out but it did not');
    } catch (Exception e) {
      Assert.isNotNull(e, 'Code should fail');
    }
  }

  @isTest
  static void createOpenLoanAppTest() {
    registerMocks();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + UserInfo.getUserId(),
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Opportunity oppTest = (Opportunity) TestUtil.setFields(
      opp,
      new Map<String, Object>{
        'OpportunityContactRoles' => new List<OpportunityContactRole>{ ocr }
      }
    );
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new CreateLoanappTestMock());
    String result = OpportunityCreateOpenLoanappController.createOpenLoanApp(
      JSON.serialize(oppTest),
      false
    );
    Test.stopTest();
    Assert.isNotNull(result, 'Application key should be returned!');
  }

  @isTest
  static void createOpenLoanAppTestNegative() {
    registerMocks();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + UserInfo.getUserId(),
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Opportunity oppTest = (Opportunity) TestUtil.setFields(
      opp,
      new Map<String, Object>{
        'OpportunityContactRoles' => new List<OpportunityContactRole>{ ocr }
      }
    );
    try {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new CreateLoanappTestMockError());
      OpportunityCreateOpenLoanappController.createOpenLoanApp(
        JSON.serialize(oppTest),
        false
      );
      Test.stopTest();
      Assert.isTrue(false, 'code was supposed to error out but it did not');
    } catch (Exception e) {
      Assert.isNotNull(e, 'code should fail!');
    }
  }

  @isTest
  static void updateOpportunityTest() {
    registerMocks();
    Test.startTest();
    OpportunityCreateOpenLoanappController.updateOpportunity(opp);
    Test.stopTest();
    Opportunity oppUpd = (Opportunity) dmlMockProvider.getHistory('doUpdate')
      .getParam('record');
    Assert.isNotNull(
      oppUpd,
      'There should be some opportunities that are updated'
    );
  }

  @isTest
  static void updateOpportunityTestNegative() {
    registerMocks();
    dmlMockProvider.mockException(
      'doUpdate',
      new AuraHandledException('Update failed!')
    );
    try {
      Test.startTest();
      OpportunityCreateOpenLoanappController.updateOpportunity(opp);
      Test.stopTest();
      Assert.isTrue(false, 'code was supposed to error out but it did not');
    } catch (exception e) {
      Assert.isTrue(
        e instanceof AuraHandledException,
        'aura handled exception should be thrown'
      );
    }
  }

  @isTest
  static void createANZPlusLoanappTest() {
    registerMocks();
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    res.body = '{"applicationId": "213354327"}';
    loanAppServiceMock.mock('getANZPlusLoanappCalloutResponse', res);
    Test.startTest();
    Map<String, String> response = OpportunityCreateOpenLoanappController.createANZPlusLoanapp(
      JSON.serialize(opp),
      ut
    );
    Test.stopTest();
    Assert.areEqual('success', response.get('status'), 'callout failed!');
  }

  @isTest
  static void createANZPlusLoanappTestNegative() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 400;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    loanAppServiceMock.mock('getANZPlusLoanappCalloutResponse', res);
    //Exception error;
    try {
      Test.startTest();
      OpportunityCreateOpenLoanappController.createANZPlusLoanapp(
        JSON.serialize(opp),
        ut
      );
      Test.stopTest();
      Assert.isTrue(false, 'code was supposed to error out but it did not');
    } catch (Exception e) {
      Assert.isNotNull(e, 'code should fail!');
    }
  }

  @isTest
  static void getUserTerritoryTest() {
    registerMocks();
    controllerRepoMock.mock('getUserTerritory', ut);
    Test.startTest();
    User_Territory__c ut = OpportunityCreateOpenLoanappController.getUserTerritory(
      UserInfo.getUserId(),
      Lib_FakeIdGenerator.getMockId(Schema.Territory__c.getSObjectType())
    );
    Test.stopTest();
    Assert.areEqual('719', ut.SAO__c, 'SAO code should be returned!');
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CreateLoanappTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_createLoanappResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CreateLoanappTestMockError implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = '{\"code\":\"ERROR\",\"message\":\"Simpology create application failed.\"}';
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(400);
      return res;
    }
  }
}
