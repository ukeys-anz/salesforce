/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Test Class for AccountClosureService
 */
@isTest
public with sharing class AccountClosureServiceTest {
    private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
        Case.getSObjectType()
    );

    private static final Id FAKER_CHILD_CASE_ID = Lib_FakeIdGenerator.getMockId(
        Case.getSObjectType()
      );
    
    private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
        Account.getSObjectType()
    );

    private static final String MOCK_CASE_NUMBER = '03771916';

    private static final StaticResource MOCK_SEAL_RESPONSE = [
      SELECT body
      FROM StaticResource
      WHERE Name = 'mock_AccountClosurePrecheckSuccess'
    ];
    @isTest
    static void testInitiateAccountClosurePreChecksSuccess() {
    Test.setMock(HttpCalloutMock.class, new FabricSealMockResponse());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken1111',
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    AccountClosureApiRepository apiRepoInstance = new AccountClosureApiRepository();
    List<FabricSealRequestModel> contextReq = apiRepoInstance.generateFabricSealInputRequest(mockQueryEligibleChildCases());
    AccountClosureService serviceInstance = new AccountClosureService();
    HttpCalloutResponse response = serviceInstance.initiateAccountClosurePreChecks(
      '1111',
      contextReq
    );
    Test.stopTest();

    Assert.areEqual(response.statuscode, 200, 'Valid status');
    Assert.isTrue(contextReq.size()>0,'Response Done Successfully');
  }

  class FabricSealMockResponse implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(
        JSON.serialize(MOCK_SEAL_RESPONSE.body)
      );
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  private static List<Case> mockQueryEligibleChildCases(){
    List<Case> childcases = new  List<Case>();
    childcases.add(mockCaseRecord(MOCK_CASE_NUMBER,''));
    return childcases;
  }

  private static Case mockCaseRecord(String caseNumber, String subStatus){
        Case caseRecord = (Case) TestUtil.setFields(
        new Case(
          Id = FAKER_CHILD_CASE_ID,
          AccountId = FAKER_ACCOUNT_ID,
          Status = GetHelpConstants.ESCALATED_STATUS,
          Sub_Status__c = subStatus,
          OwnerId = UserInfo.getUserId(),
          ParentId = FAKER_PARENT_CASE_ID,
          RecordTypeId = RTCase.accountClosure,
          FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
            FinServ__FinancialAccount__c.getSObjectType()
          ),
          ProductId = Lib_FakeIdGenerator.getMockId(
            Product2.getSObjectType()
          )
        ),
        new Map<String, Object>{ 'CaseNumber' => caseNumber }
      );
      return caseRecord;

  }
}