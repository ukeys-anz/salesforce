/**
 * @author Hitesh
 * @since  09/2024
 * @group Platform
 * @description Test Class for FacilitiesExternalQuery
 */
@isTest
private class FacilitiesExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
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
    Test.startTest();
    String responseBody =
      '{' +
      '  "facilities": [ ' +
      '    {' +
      '      "compositeFacilityId": "OLL-710002326-0",' +
      '      "ollSequence": 1,' +
      '      "ollType": 16,' +
      '      "ollAmount": 20000,' +
      '      "ollExpiryDate": "2019-09-22T00:00:00",' +
      '      "tpmiNumber": 0, ' +
      '      "tpmiSubNumber": 0 ' +
      '    } ' +
      ' ]' +
      '}';
    FacilitiesExternalQuery facilitiesQry = new FacilitiesExternalQuery();
    facilitiesQry.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      facilitiesQry.calloutResponse == null,
      'Response is not null'
    );
  }

  @isTest
  static void createFacilitiesTest() {
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createFacilitiesContext();
    FacilitiesExternalQuery facilitiesQry = new FacilitiesExternalQuery();
    facilitiesQry.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    facilitiesQry.execute(context);

    facilitiesQry.calloutResponse = new FacilitiesExternalQuery.FacilityCalloutResponse();
    ((FacilitiesExternalQuery.FacilityCalloutResponse) facilitiesQry.calloutResponse)
      .facilities = new List<FacilitiesExternalQuery.FacilityModel>();
    FacilitiesExternalQuery.FacilityModel facilitiesModel = new FacilitiesExternalQuery.FacilityModel();
    facilitiesModel.accountName = 'Stephan Pedersen';
    facilitiesModel.accountNumber = '523456789';
    facilitiesModel.ollSequence = 1;
    facilitiesModel.sourceSystemStatus = 'ACT';
    facilitiesModel.ollExpiryDate = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
    ((FacilitiesExternalQuery.FacilityCalloutResponse) facilitiesQry.calloutResponse)
      .facilities.add(facilitiesModel);
    ExternalObjectQueryBase.ExternalQueryResult result = facilitiesQry.createExternalRecords(
      facilitiesQry.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(1, firstRecord.get('Sequence'), 'Sequence mismatch');
    Assert.areEqual(
      'ACT - Active',
      firstRecord.get('Source_System_Status'),
      'Source system status should be ACT - Active'
    );
    Assert.areEqual(
      '5234-56789',
      firstRecord.get('Account_Number'),
      'Account Number should be 5234-56789'
    );
    Assert.areEqual(
      '30/01/1997',
      firstRecord.get('ExpiryDate'),
      'Expiry date should be 30/01/1997'
    );
  }

  /**
   * @description Create OLL test context
   * @name createFacilitiesContext
   * @return Returns DataSource.QueryContext context
   */
  private static DataSource.QueryContext createFacilitiesContext() {
    Test.setMock(HttpCalloutMock.class, new FacilitiesQueryTestMock());
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'Facilities'
    );
    conn.query(context);
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  private class FacilitiesQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_facilitiesResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
