/**
 * @author Prasanjeet
 * @since 2026
 * @description Test class for CCRMCustomerInsightsSummary invocable Apex class.
 */
@IsTest
private class CCRMCustomerInsightsSummaryTest {
  /**
   * @description Positive test: returns combined JSON payload with customerInsights, wocInsights, and bbdInsights
   *              when a valid Account with Source_System_ID__c is provided.
   */
  @IsTest
  static void testGetCustomerInsightsPositive() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Test Account',
      RecordTypeId = RTAccount.clgAccount,
      Source_System_ID__c = '1001'
    );

    // Stubs (order not critical here since this class does not query Account)
    SoqlStubProvider customerStub = new CustomerInsightSoqlStub();
    Test.createSoqlStub(Customer_Insights__dlm.sObjectType, customerStub);
    Assert.isTrue(
      Test.isSoqlStubDefined(Customer_Insights__dlm.sObjectType),
      'Customer_Insights__dlm stub should be registered'
    );

    Test.createSoqlStub(
      WholeOfCustomer__dlm.sObjectType,
      new WOCInsightSoqlStub()
    );
    Assert.isTrue(
      Test.isSoqlStubDefined(WholeOfCustomer__dlm.sObjectType),
      'WholeOfCustomer__dlm stub should be registered'
    );

    // Register CAZ assessment stub
    Test.createSoqlStub(
      CAZ_Assessment2__dlm.sObjectType,
      new CAZAssessmentSoqlStub()
    );
    Assert.isTrue(
      Test.isSoqlStubDefined(CAZ_Assessment2__dlm.sObjectType),
      'CAZ_Assessment2__dlm stub should be registered'
    );
    Test.startTest();
    CCRMCustomerInsightsSummary.Request req = new CCRMCustomerInsightsSummary.Request();
    req.accountObj = acc;

    List<CCRMCustomerInsightsSummary.Response> resList = CCRMCustomerInsightsSummary.getCustomerInsights(
      new List<CCRMCustomerInsightsSummary.Request>{ req }
    );
    Test.stopTest();
    // Assert
    System.assertEquals(1, resList.size(), 'One response expected');
    System.assertNotEquals(
      null,
      resList[0].Prompt,
      'Prompt should be populated'
    );

    // Parse combined payload: { customerInsights: [...], wocInsights: [...], bbdInsights: [...] }
    Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(
      resList[0].Prompt
    );

    System.assertEquals(
      true,
      payload.containsKey('customerInsights'),
      'Payload should contain customerInsights'
    );
    System.assertEquals(
      true,
      payload.containsKey('wocInsights'),
      'Payload should contain wocInsights'
    );

    // Validate customerInsights (3 raw items)
    List<Object> customer = (List<Object>) payload.get('customerInsights');
    System.assertEquals(
      3,
      customer.size(),
      'Should serialize all 3 raw customer insight records'
    );
    Set<String> quarters = new Set<String>();
    for (Object o : customer) {
      Map<String, Object> m = (Map<String, Object>) o;
      quarters.add((String) m.get('quarter__c'));
      System.assertEquals(
        '1001',
        String.valueOf(m.get('customer_no__c')),
        'Customer number should match stubbed value'
      );
    }
    System.assert(
      quarters.contains('2024Q1'),
      'Quarter 2024Q1 should be present'
    );
    System.assert(
      quarters.contains('2024Q2'),
      'Quarter 2024Q2 should be present'
    );

    // Validate WOC insights
    List<Object> woc = (List<Object>) payload.get('wocInsights');
    System.assertEquals(2, woc.size(), 'Expected 2 WOC rows');
    for (Object o : woc) {
      Map<String, Object> m = (Map<String, Object>) o;
      System.assertEquals(
        '1001',
        (String) m.get('bus_cust_no__c'),
        'bus_cust_no__c should match account external id'
      );
    }

    // Validate CAZ assessments presence
    System.assertEquals(
      true,
      payload.containsKey('cazAssessments'),
      'Payload should contain cazAssessments'
    );
    List<Object> caz = (List<Object>) payload.get('cazAssessments');
    // Our stub will return 1 CAZ assessment row; validate only existence and size
    System.assertEquals(1, caz.size(), 'Expected 1 CAZ assessment row');
  }

  /**
   * @description Negative test: when null request list or missing account, returns informative Prompt.
   */
  @IsTest
  static void testGetCustomerInsightsNullInput() {
    // Null list
    List<CCRMCustomerInsightsSummary.Response> res1 = CCRMCustomerInsightsSummary.getCustomerInsights(
      null
    );
    System.assertEquals(1, res1.size(), 'Expected 1 response for null input');
    System.assertEquals(
      'No Account provided.',
      res1[0].Prompt,
      'Prompt should be set for null input'
    );

    // Empty list
    List<CCRMCustomerInsightsSummary.Response> res2 = CCRMCustomerInsightsSummary.getCustomerInsights(
      new List<CCRMCustomerInsightsSummary.Request>()
    );
    System.assertEquals(1, res2.size(), 'Expected 1 response for empty list');
    System.assertEquals(
      'No Account provided.',
      res2[0].Prompt,
      'Prompt should be set for empty list'
    );

    // Request with null account
    CCRMCustomerInsightsSummary.Request req = new CCRMCustomerInsightsSummary.Request();
    List<CCRMCustomerInsightsSummary.Response> res3 = CCRMCustomerInsightsSummary.getCustomerInsights(
      new List<CCRMCustomerInsightsSummary.Request>{ req }
    );
    System.assertEquals(1, res3.size(), 'Expected 1 response for null account');
    System.assertEquals(
      'No Account provided.',
      res3[0].Prompt,
      'Prompt should be set for null account'
    );
  }

  /**
   * @description Negative test: when Account has blank Source_System_ID__c, returns informative Prompt.
   */
  @IsTest
  static void testGetCustomerInsightsMissingExternalId() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Test Account',
      RecordTypeId = RTAccount.clgAccount,
      Source_System_ID__c = null
    );

    CCRMCustomerInsightsSummary.Request req = new CCRMCustomerInsightsSummary.Request();
    req.accountObj = acc;

    List<CCRMCustomerInsightsSummary.Response> res = CCRMCustomerInsightsSummary.getCustomerInsights(
      new List<CCRMCustomerInsightsSummary.Request>{ req }
    );

    System.assertEquals(
      1,
      res.size(),
      'Expected 1 response for missing external ID'
    );
    System.assertEquals(
      'Account Source_System_ID__c is missing. Unable to fetch Customer Insights.',
      res[0].Prompt,
      'Prompt should indicate missing external ID'
    );
  }

  /**
   * @description Negative test: when Account is not CLG RecordType, returns blank Prompt.
   */
  @IsTest
  static void testGetCustomerInsightsNonClgReturnsBlank() {
    // Arrange: create a non-CLG account
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Test Account',
      RecordTypeId = RTAccount.personAccount,
      Source_System_ID__c = '1001'
    );

    // Stubs (order not critical here since this class does not query Account)
    SoqlStubProvider customerStub = new CustomerInsightSoqlStub();
    Test.createSoqlStub(Customer_Insights__dlm.sObjectType, customerStub);
    Assert.isTrue(
      Test.isSoqlStubDefined(Customer_Insights__dlm.sObjectType),
      'Customer_Insights__dlm stub should be registered'
    );

    Test.createSoqlStub(
      WholeOfCustomer__dlm.sObjectType,
      new WOCInsightSoqlStub()
    );
    Assert.isTrue(
      Test.isSoqlStubDefined(WholeOfCustomer__dlm.sObjectType),
      'WholeOfCustomer__dlm stub should be registered'
    );

    // Register CAZ assessment stub
    Test.createSoqlStub(
      CAZ_Assessment2__dlm.sObjectType,
      new CAZAssessmentSoqlStub()
    );
    Assert.isTrue(
      Test.isSoqlStubDefined(CAZ_Assessment2__dlm.sObjectType),
      'CAZ_Assessment2__dlm stub should be registered'
    );
    Test.startTest();
    CCRMCustomerInsightsSummary.Request req = new CCRMCustomerInsightsSummary.Request();
    req.accountObj = acc;

    // Act
    List<CCRMCustomerInsightsSummary.Response> res = CCRMCustomerInsightsSummary.getCustomerInsights(
      new List<CCRMCustomerInsightsSummary.Request>{ req }
    );
    Test.stopTest();

    // Parse payload and verify structure: customerInsights and wocInsights should be present but empty, cazAssessments present
    Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(
      res[0].Prompt
    );

    System.assert(
      payload.containsKey('customerInsights'),
      'Payload should contain customerInsights key'
    );
    System.assert(
      payload.containsKey('wocInsights'),
      'Payload should contain wocInsights key'
    );
    System.assert(
      payload.containsKey('cazAssessments'),
      'Payload should contain cazAssessments key'
    );

    List<Object> customer = (List<Object>) payload.get('customerInsights');
    List<Object> woc = (List<Object>) payload.get('wocInsights');
    List<Object> caz = (List<Object>) payload.get('cazAssessments');

    System.assertEquals(
      0,
      customer.size(),
      'Non-CLG customerInsights should be empty'
    );
    System.assertEquals(0, woc.size(), 'Non-CLG wocInsights should be empty');
    // Our stub returns 1 CAZ assessment row; validate existence
    System.assertEquals(
      1,
      caz.size(),
      'Expected 1 CAZ assessment row for non-CLG'
    );
  }
  // Local stubs for SOQL-backed data
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
      SObject rec1 = Test.createStubQueryRow(
        sot,
        new Map<String, Object>{
          'quarter__c' => '2024Q1',
          'customer_no__c' => customerNo,
          'load_date__c' => Date.today()
        }
      );

      SObject rec2 = Test.createStubQueryRow(
        sot,
        new Map<String, Object>{
          'quarter__c' => '2024Q1',
          'customer_no__c' => customerNo,
          'load_date__c' => Date.today().addDays(-1)
        }
      );

      SObject rec3 = Test.createStubQueryRow(
        sot,
        new Map<String, Object>{
          'quarter__c' => '2024Q2',
          'customer_no__c' => customerNo,
          'load_date__c' => Date.today()
        }
      );

      return new List<SObject>{ rec1, rec2, rec3 };
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

  // CAZ assessment stub
  class CAZAssessmentSoqlStub extends SoqlStubProvider {
    public override List<SObject> handleSoqlQuery(
      SObjectType sot,
      String query,
      Map<String, Object> bindVars
    ) {
      String custNo = '1001';
      // Use fields that exist on CAZ_Assessment2__dlm as defined in CCRMAgentBQRepository.fetchCAZAssessmentByCustomerNumber
      SObject rec = Test.createStubQueryRow(
        sot,
        new Map<String, Object>{
          'customer_id__c' => custNo,
          'created_date__c' => Date.today(),
          'bc_borrowingpurposedetails__c' => 'Test purpose'
        }
      );
      return new List<SObject>{ rec };
    }
  }
}
