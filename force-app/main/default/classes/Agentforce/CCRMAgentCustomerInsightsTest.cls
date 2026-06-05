/**
 * @author <Prasanjeet Dutta>
 * @since 2026
 * @description Test class for CCRMAgentCustomerInsights invocable Apex class.
 */
@IsTest
private class CCRMAgentCustomerInsightsTest {
  static Lib_MockProvider userMock;
  static Lib_MockProvider agentRepoMock;

  static void registerMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class);
    agentRepoMock = Lib_MockProvider.forType(CCRMAgentforceRepository.class);
  }
  /**
   * @description Positive test: returns deduplicated quarterly insights for a valid Account Id in SINGLE scope.
   */
  @IsTest
  static void testGetCustomerInsightsSuccess() {
    Id mockAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Account acc = new Account(
      Id = mockAccId,
      Name = 'Test Account',
      RecordTypeId = RTAccount.clgAccount,
      Source_System_ID__c = '1001',
      OCV_ID__c = 'OCV-1234567890'
    );

    User usr = TestUtil.getUserByFirstName('APIUserTest');
    usr.Lan_Id__c = 'LAN-123';

    registerMocks();
    userMock.mock('getUser', usr);
    agentRepoMock.mock('fetchAccountById', new List<Account>{ acc });
    agentRepoMock.mock(
      'fetchAccountsByCustomerNumbers',
      new List<Account>{ acc }
    );

    // =====================
    // SOQL STUBS
    // =====================
    Test.createSoqlStub(
      Customer_Insights__dlm.sObjectType,
      new CustomerInsightSoqlStub()
    );

    Test.createSoqlStub(
      BusinessBankerDesktop__dlm.sObjectType,
      new BBDInsightSoqlStub()
    );

    Test.createSoqlStub(
      WholeOfCustomer__dlm.sObjectType,
      new WOCInsightSoqlStub()
    );

    Test.startTest();

    CCRMAgentCustomerInsights.Request req = new CCRMAgentCustomerInsights.Request();
    req.accountId = acc.Id;
    req.scope = 'SINGLE';

    List<CCRMAgentCustomerInsights.Response> resList = CCRMAgentCustomerInsights.getCustomerInsights(
      new List<CCRMAgentCustomerInsights.Request>{ req }
    );

    Test.stopTest();

    System.assertEquals(1, resList.size(), 'One response expected');

    CCRMAgentCustomerInsights.Response res = resList[0];

    System.assertEquals(
      2,
      res.bbdInsights.size(),
      'Two BBD insight rows expected'
    );

    Set<String> appNos = new Set<String>();
    for (BusinessBankerDesktop__dlm rec : res.bbdInsights) {
      appNos.add((String) rec.get('app_no__c'));
    }

    System.assertEquals(
      true,
      appNos.contains('APP-001'),
      'APP-001 should be in BBD insights'
    );
    System.assertEquals(
      true,
      appNos.contains('APP-002'),
      'APP-002 should be in BBD insights'
    );

    System.assertEquals(
      1,
      res.customerAndWocInsights.size(),
      'One customer bundle expected'
    );

    CCRMAgentCustomerInsights.CustomerInsightsWrapper w = res.customerAndWocInsights[0];

    System.assertEquals(
      '1001',
      w.customerNumber,
      'Bundle customer number should match'
    );
    System.assertEquals(
      'Test Account',
      w.customerName,
      'Bundle account name should match'
    );

    System.assertEquals(
      3,
      w.customerInsights.size(),
      'Expected 3 customer insight rows in bundle'
    );
    System.assertEquals(
      2,
      w.wocInsights.size(),
      'Expected 2 WoC insight rows in bundle'
    );

    // Quarter check
    Set<String> quarters = new Set<String>();
    for (Customer_Insights__dlm r : w.customerInsights) {
      quarters.add((String) r.get('quarter__c'));
    }

    System.assertEquals(
      true,
      quarters.contains('2024Q1'),
      '2024Q1 should be in customer insights'
    );
    System.assertEquals(
      true,
      quarters.contains('2024Q2'),
      '2024Q2 should be in customer insights'
    );
  }

  // =====================
  // STUBS
  // =====================

  class CustomerInsightSoqlStub extends SoqlStubProvider {
    public override List<SObject> handleSoqlQuery(
      SObjectType sot,
      String query,
      Map<String, Object> bindVars
    ) {
      Decimal customerNo = 1001;

      // Guard clauses to avoid deep nesting and ensure braces are used
      if (bindVars == null) {
        return buildCustomerInsightRows(sot, customerNo);
      }
      if (!bindVars.containsKey('tmpVar1')) {
        return buildCustomerInsightRows(sot, customerNo);
      }

      Object tmp = bindVars.get('tmpVar1');
      if (tmp instanceof Decimal) {
        customerNo = (Decimal) tmp;
      } else if (tmp instanceof String) {
        customerNo = Decimal.valueOf((String) tmp);
      }

      return buildCustomerInsightRows(sot, customerNo);
    }

    private List<SObject> buildCustomerInsightRows(
      SObjectType sot,
      Decimal customerNo
    ) {
      return new List<SObject>{
        Test.createStubQueryRow(
          sot,
          new Map<String, Object>{
            'quarter__c' => '2024Q1',
            'customer_no__c' => customerNo
          }
        ),
        Test.createStubQueryRow(
          sot,
          new Map<String, Object>{
            'quarter__c' => '2024Q1',
            'customer_no__c' => customerNo
          }
        ),
        Test.createStubQueryRow(
          sot,
          new Map<String, Object>{
            'quarter__c' => '2024Q2',
            'customer_no__c' => customerNo
          }
        )
      };
    }
  }

  class BBDInsightSoqlStub extends SoqlStubProvider {
    public override List<SObject> handleSoqlQuery(
      SObjectType sot,
      String query,
      Map<String, Object> bindVars
    ) {
      String lan = 'LAN-123';

      return new List<SObject>{
        Test.createStubQueryRow(
          sot,
          new Map<String, Object>{ 'lanid__c' => lan, 'app_no__c' => 'APP-001' }
        ),
        Test.createStubQueryRow(
          sot,
          new Map<String, Object>{ 'lanid__c' => lan, 'app_no__c' => 'APP-002' }
        )
      };
    }
  }

  class WOCInsightSoqlStub extends SoqlStubProvider {
    public override List<SObject> handleSoqlQuery(
      SObjectType sot,
      String query,
      Map<String, Object> bindVars
    ) {
      String custNo = '1001';

      return new List<SObject>{
        Test.createStubQueryRow(
          sot,
          new Map<String, Object>{ 'bus_cust_no__c' => custNo }
        ),
        Test.createStubQueryRow(
          sot,
          new Map<String, Object>{ 'bus_cust_no__c' => custNo }
        )
      };
    }
  }

  @IsTest
  /**
   * @description Negative test: null Account Id in SINGLE scope returns empty records in response wrapper.
   */
  static void testNullAccountId() {
    CCRMAgentCustomerInsights.Request req = new CCRMAgentCustomerInsights.Request();
    req.scope = 'SINGLE';

    List<CCRMAgentCustomerInsights.Response> result = CCRMAgentCustomerInsights.getCustomerInsights(
      new List<CCRMAgentCustomerInsights.Request>{ req }
    );

    System.assertEquals(
      1,
      result.size(),
      'One response wrapper always returned'
    );

    System.assertEquals(
      0,
      result[0].bbdInsights.size(),
      'No BBD insights when LAN not available'
    );
    System.assertEquals(
      0,
      result[0].customerAndWocInsights.size(),
      'No bundles when Account Id is null in SINGLE scope'
    );
  }

  @IsTest
  /**
   * @description Positive test: Portfolio scope with CPID_Type__c = 'P' fetches accounts from Controlling Post.
   */
  static void testPortfolioScopeWithTypePSuccess() {
    // Create Controlling Post with Type 'P'
    Id mockCpId = Lib_FakeIdGenerator.getMockId(
      Controlling_Post__c.SObjectType
    );
    Controlling_Post__c cp = new Controlling_Post__c(
      Id = mockCpId,
      Name = 'Test CP',
      CPID_LanID__c = 'LAN-123',
      CPID_Type__c = 'P'
    );

    // Create multiple accounts under this Controlling Post
    Account acc1 = new Account(
      Name = 'Test Account 1',
      RecordTypeId = RTAccount.clgAccount,
      Source_System_ID__c = '2001',
      Controlling_Post__c = mockCpId
    );
    Account acc2 = new Account(
      Name = 'Test Account 2',
      RecordTypeId = RTAccount.clgAccount,
      Source_System_ID__c = '2002',
      Controlling_Post__c = mockCpId
    );

    User usr = TestUtil.getUserByFirstName('APIUserTest');
    usr.Lan_Id__c = 'LAN-123';

    registerMocks();
    userMock.mock('getUser', usr);
    agentRepoMock.mock(
      'fetchControllingPostByLanId',
      new List<Controlling_Post__c>{ cp }
    );
    agentRepoMock.mock(
      'fetchCLGAccountsByCPID',
      new List<Account>{ acc1, acc2 }
    );
    agentRepoMock.mock(
      'fetchAccountsByCustomerNumbers',
      new List<Account>{ acc1, acc2 }
    );

    // =====================
    // SOQL STUBS
    // =====================
    Test.createSoqlStub(
      Customer_Insights__dlm.sObjectType,
      new CustomerInsightSoqlStub()
    );

    Test.createSoqlStub(
      BusinessBankerDesktop__dlm.sObjectType,
      new BBDInsightSoqlStub()
    );

    Test.createSoqlStub(
      WholeOfCustomer__dlm.sObjectType,
      new WOCInsightSoqlStub()
    );

    Test.startTest();

    CCRMAgentCustomerInsights.Request req = new CCRMAgentCustomerInsights.Request();
    req.scope = 'PORTFOLIO';
    // Note: accountId is null for portfolio scope

    List<CCRMAgentCustomerInsights.Response> resList = CCRMAgentCustomerInsights.getCustomerInsights(
      new List<CCRMAgentCustomerInsights.Request>{ req }
    );

    Test.stopTest();

    System.assertEquals(1, resList.size(), 'One response expected');

    CCRMAgentCustomerInsights.Response res = resList[0];

    System.assertEquals(
      2,
      res.bbdInsights.size(),
      'Two BBD insight rows expected'
    );

    // Should have 2 customer bundles (one for each account under the controlling post)
    System.assertEquals(
      2,
      res.customerAndWocInsights.size(),
      'Two customer bundles expected for portfolio scope'
    );

    Set<String> customerNumbers = new Set<String>();
    for (
      CCRMAgentCustomerInsights.CustomerInsightsWrapper w : res.customerAndWocInsights
    ) {
      customerNumbers.add(w.customerNumber);
    }

    System.assertEquals(
      true,
      customerNumbers.contains('2001'),
      'Customer 2001 should be in portfolio'
    );
    System.assertEquals(
      true,
      customerNumbers.contains('2002'),
      'Customer 2002 should be in portfolio'
    );
  }

  @IsTest
  /**
   * @description Positive test: Portfolio scope with CPID_Type__c = 'R' fetches accounts from Controlling Post.
   */
  static void testPortfolioScopeWithTypeRSuccess() {
    // Create Controlling Post with Type 'R'
    Id mockCpId = Lib_FakeIdGenerator.getMockId(
      Controlling_Post__c.SObjectType
    );
    Controlling_Post__c cp = new Controlling_Post__c(
      Id = mockCpId,
      Name = 'Test CP',
      CPID_LanID__c = 'LAN-123',
      CPID_Type__c = 'R'
    );

    // Create account under this Controlling Post
    Account acc1 = new Account(
      Name = 'Test Account 1',
      RecordTypeId = RTAccount.clgAccount,
      Source_System_ID__c = '3001',
      Controlling_Post__c = mockCpId
    );

    User usr = TestUtil.getUserByFirstName('APIUserTest');
    usr.Lan_Id__c = 'LAN-123';

    registerMocks();
    userMock.mock('getUser', usr);
    agentRepoMock.mock(
      'fetchControllingPostByLanId',
      new List<Controlling_Post__c>{ cp }
    );
    agentRepoMock.mock('fetchCLGAccountsByCPID', new List<Account>{ acc1 });
    agentRepoMock.mock(
      'fetchAccountsByCustomerNumbers',
      new List<Account>{ acc1 }
    );

    // =====================
    // SOQL STUBS
    // =====================
    Test.createSoqlStub(
      Customer_Insights__dlm.sObjectType,
      new CustomerInsightSoqlStub()
    );

    Test.createSoqlStub(
      BusinessBankerDesktop__dlm.sObjectType,
      new BBDInsightSoqlStub()
    );

    Test.createSoqlStub(
      WholeOfCustomer__dlm.sObjectType,
      new WOCInsightSoqlStub()
    );

    Test.startTest();

    CCRMAgentCustomerInsights.Request req = new CCRMAgentCustomerInsights.Request();
    req.scope = 'PORTFOLIO';

    List<CCRMAgentCustomerInsights.Response> resList = CCRMAgentCustomerInsights.getCustomerInsights(
      new List<CCRMAgentCustomerInsights.Request>{ req }
    );

    Test.stopTest();

    System.assertEquals(1, resList.size(), 'One response expected');

    CCRMAgentCustomerInsights.Response res = resList[0];

    System.assertEquals(
      1,
      res.customerAndWocInsights.size(),
      'One customer bundle expected for portfolio scope with Type R'
    );

    System.assertEquals(
      '3001',
      res.customerAndWocInsights[0].customerNumber,
      'Customer 3001 should be in portfolio'
    );
  }

  @IsTest
  /**
   * @description Negative test: Portfolio scope with invalid CPID_Type__c returns empty results.
   */
  static void testPortfolioScopeWithInvalidType() {
    // Create Controlling Post with invalid Type
    Id mockCpId = Lib_FakeIdGenerator.getMockId(
      Controlling_Post__c.SObjectType
    );
    Controlling_Post__c cp = new Controlling_Post__c(
      Id = mockCpId,
      Name = 'Test CP',
      CPID_LanID__c = 'LAN-123',
      CPID_Type__c = 'X' // Invalid type
    );

    User usr = TestUtil.getUserByFirstName('APIUserTest');
    usr.Lan_Id__c = 'LAN-123';

    registerMocks();
    userMock.mock('getUser', usr);
    agentRepoMock.mock(
      'fetchControllingPostByLanId',
      new List<Controlling_Post__c>{ cp }
    );

    Test.startTest();

    CCRMAgentCustomerInsights.Request req = new CCRMAgentCustomerInsights.Request();
    req.scope = 'PORTFOLIO';

    List<CCRMAgentCustomerInsights.Response> resList = CCRMAgentCustomerInsights.getCustomerInsights(
      new List<CCRMAgentCustomerInsights.Request>{ req }
    );

    Test.stopTest();

    System.assertEquals(1, resList.size(), 'One response expected');

    CCRMAgentCustomerInsights.Response res = resList[0];

    System.assertEquals(
      0,
      res.customerAndWocInsights.size(),
      'No customer bundles expected for invalid CPID Type'
    );
  }

  @IsTest
  /**
   * @description Negative test: Portfolio scope with no Controlling Post for user returns empty results.
   */
  static void testPortfolioScopeWithNoControllingPost() {
    User usr = TestUtil.getUserByFirstName('APIUserTest');
    usr.Lan_Id__c = 'LAN-999'; // No controlling post for this LAN ID

    registerMocks();
    userMock.mock('getUser', usr);
    agentRepoMock.mock(
      'fetchControllingPostByLanId',
      new List<Controlling_Post__c>()
    );

    Test.startTest();

    CCRMAgentCustomerInsights.Request req = new CCRMAgentCustomerInsights.Request();
    req.scope = 'PORTFOLIO';

    List<CCRMAgentCustomerInsights.Response> resList = CCRMAgentCustomerInsights.getCustomerInsights(
      new List<CCRMAgentCustomerInsights.Request>{ req }
    );

    Test.stopTest();

    System.assertEquals(1, resList.size(), 'One response expected');

    CCRMAgentCustomerInsights.Response res = resList[0];

    System.assertEquals(
      0,
      res.customerAndWocInsights.size(),
      'No customer bundles expected when no Controlling Post found'
    );
  }

  @IsTest
  /**
   * @description Negative test: Portfolio scope with null LAN ID returns empty results.
   */
  static void testPortfolioScopeWithNullLanId() {
    User usr = TestUtil.getUserByFirstName('APIUserTest');
    usr.Lan_Id__c = null;

    registerMocks();
    userMock.mock('getUser', usr);

    Test.startTest();

    CCRMAgentCustomerInsights.Request req = new CCRMAgentCustomerInsights.Request();
    req.scope = 'PORTFOLIO';

    List<CCRMAgentCustomerInsights.Response> resList = CCRMAgentCustomerInsights.getCustomerInsights(
      new List<CCRMAgentCustomerInsights.Request>{ req }
    );

    Test.stopTest();

    System.assertEquals(1, resList.size(), 'One response expected');

    CCRMAgentCustomerInsights.Response res = resList[0];

    System.assertEquals(
      0,
      res.customerAndWocInsights.size(),
      'No customer bundles expected when LAN ID is null'
    );
  }
}
