/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Facility Query external query class
 */
@isTest
private class CCRMFacilitiesQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
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
    CCRMFacilitiesQuery facilitiesQry = new CCRMFacilitiesQuery();
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
    DataSource.QueryContext context = CCRMTestDataFactory.createFacilitiesContext();
    CCRMFacilitiesQuery facilitiesQry = new CCRMFacilitiesQuery();
    facilitiesQry.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult data = facilitiesQry.execute(
      context
    );

    facilitiesQry.calloutResponse = new CCRMFacilitiesQuery.FacilityCalloutResponse();
    ((CCRMFacilitiesQuery.FacilityCalloutResponse) facilitiesQry.calloutResponse)
      .facilities = new List<CCRMFacilitiesQuery.FacilityModel>();
    CCRMFacilitiesQuery.FacilityModel facilitiesModel = new CCRMFacilitiesQuery.FacilityModel();
    facilitiesModel.accountName = 'Stephan Pedersen';
    facilitiesModel.accountNumber = '523456789';
    facilitiesModel.ollSequence = 1;
    ((CCRMFacilitiesQuery.FacilityCalloutResponse) facilitiesQry.calloutResponse)
      .facilities.add(facilitiesModel);
    CCRMExternalObjectQueryBase.ExternalQueryResult result = facilitiesQry.createFinancialAccounts();
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
    Map<String, Object> firstRecord = result.queryResult[0];
    Assert.areEqual(1, firstRecord.get('Sequence'), 'Sequence mismatch');
  }
}
