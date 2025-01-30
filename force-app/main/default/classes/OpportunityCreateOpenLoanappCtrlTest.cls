@isTest
private class OpportunityCreateOpenLoanappCtrlTest {
  //jwt containing a single claim of exp 26/11/2050
  public final static String IDTESTVALUE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI1NTMwMzIxNzh9.eAWGLhTYhn4y9M2t2OHeTLIe7MLPObBFK2Nli8CPTD4';
  static Lib_MockProvider controllerRepoMock;
  static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    controllerRepoMock = Lib_MockProvider.forType(
      OpportunityCreateOpenLoanappRepository.class
    );
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
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
