/**
 * @author       : Amisha Gyani
 * @since        : February, 2026
 * @description  : Test class for CCRMAgentCustomerComplaintsPrompt invocable Apex class
 **/
@IsTest
private class CCRMAgentCustomerComplaintsPromptTest {
  static Lib_MockProvider repoMock;

  /**
   * @description Registers the mock repository for customer complaints
   */
  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(CCRMAgentforceRepository.class);
  }

  /**
   * @description Positive test:
   *              CLG Account → includes related accounts → complaints returned
   */
  @IsTest
  static void testGetCustomerComplaintsPositiveCLG() {
    registerMocks();

    Faker faker = new Faker('AU');

    // Create CLG Account
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = faker.randomString(6),
      RecordTypeId = RTAccount.clgAccount
    );

    // Mock related Account Id
    Id relatedAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    // Mock Account Relations
    List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        FinServ__RelatedAccount__c = relatedAccId
      )
    };

    repoMock.mock('fetchAccountRelationsForCLG', relations);

    // Mock Cases
    List<Case> mockCases = new List<Case>{
      new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        AccountId = acc.Id,
        CreatedDate = System.now().addDays(-2),
        ClosedDate = System.now(),
        RecordTypeId = RTCase.customerComplaint
      )
    };

    repoMock.mock('fetchCustomerComplaints', mockCases);

    // Prepare request
    CCRMAgentCustomerComplaintsPrompt.Request req = new CCRMAgentCustomerComplaintsPrompt.Request();
    req.accountObj = acc;

    Test.startTest();
    List<CCRMAgentCustomerComplaintsPrompt.Response> results = CCRMAgentCustomerComplaintsPrompt.getCustomerComplaints(
      new List<CCRMAgentCustomerComplaintsPrompt.Request>{ req }
    );
    Test.stopTest();

    // Assertions
    Assert.areEqual(1, results.size(), 'Should return exactly one wrapper.');
  }

  /**
   * @description Positive test:
   *              Non-CLG Account → only direct complaints fetched
   */
  @IsTest
  static void testGetCustomerComplaintsNonCLG() {
    registerMocks();

    Faker faker = new Faker('AU');

    // Non-CLG Account
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = faker.randomString(6),
      RecordTypeId = RTAccount.personAccount
    );

    // Mock Cases
    List<Case> mockCases = new List<Case>{
      new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        AccountId = acc.Id,
        CreatedDate = System.now().addDays(-1),
        ClosedDate = null,
        RecordTypeId = RTCase.customerComplaint
      )
    };

    repoMock.mock('fetchCustomerComplaints', mockCases);

    CCRMAgentCustomerComplaintsPrompt.Request req = new CCRMAgentCustomerComplaintsPrompt.Request();
    req.accountObj = acc;

    Test.startTest();
    List<CCRMAgentCustomerComplaintsPrompt.Response> results = CCRMAgentCustomerComplaintsPrompt.getCustomerComplaints(
      new List<CCRMAgentCustomerComplaintsPrompt.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(1, results.size(), 'Should return exactly one wrapper.');
  }

  /**
   * @description Negative test: Null input list
   */
  @IsTest
  static void testGetCustomerComplaintsNullInput() {
    registerMocks();

    Test.startTest();
    List<CCRMAgentCustomerComplaintsPrompt.Response> results = CCRMAgentCustomerComplaintsPrompt.getCustomerComplaints(
      null
    );
    Test.stopTest();

    Assert.areEqual(
      '[]',
      results[0].Prompt,
      'Null input should return empty JSON array.'
    );
  }

  /**
   * @description Negative test: Request with null Account
   */
  @IsTest
  static void testGetCustomerComplaintsNullAccount() {
    registerMocks();

    CCRMAgentCustomerComplaintsPrompt.Request req = new CCRMAgentCustomerComplaintsPrompt.Request();
    req.accountObj = null;

    Test.startTest();
    List<CCRMAgentCustomerComplaintsPrompt.Response> results = CCRMAgentCustomerComplaintsPrompt.getCustomerComplaints(
      new List<CCRMAgentCustomerComplaintsPrompt.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(
      '[]',
      results[0].Prompt,
      'Null account should return empty JSON array.'
    );
  }
}
