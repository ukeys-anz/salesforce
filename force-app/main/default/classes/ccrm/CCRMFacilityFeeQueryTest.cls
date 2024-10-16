/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class for CCRMFacilityFeeQuery
 */
@isTest
private class CCRMFacilityFeeQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }
  private static FinServ__FinancialAccountRole__c getMockedData() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = accId,
        Account_Key__c = '4011643101-403456789',
        FinServ__FinancialAccountNumber__c = '403456789',
        Product_Type__c = 'CAP-CIS:CDA',
        Source_System_Status__c = 'Open'
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "facilityFees": [' +
      '     {' +
      '       "compositeFacilityFeeId": "4020018249-72466661701-0",' +
      '       "feeType": "COMFE",' +
      '       "feePercentage": "1.3",' +
      '       "feeAmount": "50.01",' +
      '       "feeFrequency": "YR",' +
      '       "feeChargeAccount": "250823253"' +
      '     }' +
      '   ]' +
      ' }';

    CCRMFacilityFeeQuery query = new CCRMFacilityFeeQuery();
    Test.startTest();
    query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void createFacilitiesTest() {
    registerMocks();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createFacilityFeeQueryContext();
    CCRMFacilityFeeQuery feeAcct = new CCRMFacilityFeeQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult data = feeAcct.execute(
      context
    );
    feeAcct.calloutResponse = new CCRMFacilityFeeQuery.FacilityFeeCalloutResponse();
    ((CCRMFacilityFeeQuery.FacilityFeeCalloutResponse) FeeAcct.calloutResponse)
      .facilityFees = new List<CCRMFacilityFeeQuery.FacilityFeeModel>();
    CCRMFacilityFeeQuery.FacilityFeeModel feeModel = new CCRMFacilityFeeQuery.FacilityFeeModel();
    feeModel.compositeFacilityFeeId = '4020018249-72466661701-0';
    feeModel.feeType = 'COMFE';
    feeModel.feeFrequency = 'YR';
    ((CCRMFacilityFeeQuery.FacilityFeeCalloutResponse) feeAcct.calloutResponse)
      .facilityFees.add(feeModel);
    Test.startTest();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = feeAcct.createFinancialAccounts();
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
    System.assertEquals(
      'YR',
      result.queryResult[0].get('Frequency'),
      'Frequency mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMFacilityFeeQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_facilityFeeResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
