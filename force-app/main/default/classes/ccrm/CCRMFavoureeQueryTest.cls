/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class of CCRMFavoureeQuery
 */
@isTest
private class CCRMFavoureeQueryTest {
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
      FinServ__FinancialAccount__r = (FinServ__FinancialAccount__c) TestUtil.setFields(
        new FinServ__FinancialAccount__c(
          Name = 'Test',
          FinServ__Status__c = 'Active',
          FinServ__FinancialAccountType__c = 'Savings',
          FinServ__PrimaryOwner__c = accId,
          Account_Key__c = '4011643101-3424909811',
          FinServ__FinancialAccountNumber__c = '3424909811',
          Product_Type__c = 'CAP-CIS:DDA'
        ),
        new Map<String, Object>{ 'Account_Number__c' => '3424-909811' }
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
      '   "guaranteesFavourees": [' +
      '     {' +
      '       "compositeGuaranteesFavoureesId": "4020018249-72466661701-29618-0",' +
      '       "name": "test",' +
      '       "abn": "DDA"' +
      '     }' +
      '   ]' +
      ' }';

    CCRMFavoureeQuery favoureeAcct = new CCRMFavoureeQuery();
    Test.startTest();
    favoureeAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      favoureeAcct.calloutResponse == null,
      'Response is not null'
    );
  }

  @isTest
  static void createFavoureeTest() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createFavoureeQueryContext();
    CCRMFavoureeQuery favoureeQuery = new CCRMFavoureeQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = favoureeQuery.execute(
      context
    );
    Test.stopTest();
    assert.areEqual(1, result.queryResult.size(), 'Size of accounts is 1');
  }
}
