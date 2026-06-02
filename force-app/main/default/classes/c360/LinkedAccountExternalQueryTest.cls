/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of LinkedAccountExternalQuery
 */
@isTest
private class LinkedAccountExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }

  private static FinServ__FinancialAccountRole__c getMockedData() {
    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = (FinServ__FinancialAccount__c) TestUtil.setFields(
        new FinServ__FinancialAccount__c(
          Name = 'Test',
          FinServ__Status__c = 'Active',
          FinServ__FinancialAccountType__c = 'Savings',
          FinServ__PrimaryOwner__c = Lib_FakeIdGenerator.getMockId(
            Account.SobjectType
          ),
          Account_Key__c = '4011643101-523456789',
          FinServ__FinancialAccountNumber__c = '523456789',
          Product_Type__c = 'CAP-CIS:OLL'
        ),
        new Map<String, Object>{ 'Account_Number__c' => '5234-56789' }
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
      '   "relatedAccounts": [' +
      '     {' +
      '       "compositeLinkedAccountId": "PTF-10000000038-1",' +
      '       "productCode": "APP",' +
      '       "accountNumber": "708749911",' +
      '        "relateCode": "PSA"' +
      '     }' +
      '   ]' +
      ' }';

    LinkedAccountExternalQuery linkedAcct = new LinkedAccountExternalQuery();
    Test.startTest();
    linkedAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(linkedAcct.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    LinkedAccountExternalQuery linkedAccountQry = new LinkedAccountExternalQuery();
    Test.startTest();
    linkedAccountQry.parseResponse('');
    Test.stopTest();
    Assert.isTrue(
      linkedAccountQry.calloutResponse == null,
      'Response is not null'
    );
  }

  @isTest
  static void testCreateExternalRecords() {
    registerMocks();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    Test.startTest();
    Account acc = new Account(
      External_Id__c = 'CAP-CIS_4011643101',
      Source_System_Name__c = 'CAP-CIS'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    faRepoMock.mock(
      'getIndustryNamesByCodes',
      new Map<String, String>{ '6220' => 'Test Industry' }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    DataSource.QueryContext context = createQueryContext();
    LinkedAccountExternalQuery linkedAccountQry = new LinkedAccountExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    ExternalObjectQueryBase.ExternalQueryResult result = linkedAccountQry.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(
      'PTF-10000000038-1',
      firstRecord.get('ExternalId'),
      'External Id mismatch'
    );
    Assert.areEqual(
      '708-749-911',
      firstRecord.get('AccountNumber'),
      'Account Number mismatch'
    );
  }

  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new LinkedAccountQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'LinkedAccount'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class LinkedAccountQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_linkedAccountResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
