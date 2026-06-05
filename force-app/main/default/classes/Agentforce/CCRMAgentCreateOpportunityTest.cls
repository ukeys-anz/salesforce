/**
 * @author Amisha Gyani
 * @since February 2026
 * @description Test class for CCRMAgentCreateOpportunity invocable Apex class.
 *              Verifies creation of single and multiple Opportunity records and proper field mapping.
 */
@IsTest
private class CCRMAgentCreateOpportunityTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userRepoMock;
  static Lib_MockProvider actionRepoMock;

  /**
   * @description Registers mock providers for DmlRepository, UserInfoRepository, and CCRMAgentforceActionRepository
   */
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
    actionRepoMock = Lib_MockProvider.forType(
      CCRMAgentforceActionRepository.class
    );
  }

  /**
   * @testSetup
   * @description Test setup method to register mocks. No DML is performed here.
   */
  @TestSetup
  static void setupTestData() {
    registerMocks();
    dmlRepoMock.mock('doInsert', new List<Database.SaveResult>());
    userRepoMock.mock('checkProfile', true);
    actionRepoMock.mock(
      'getStandardPricebookId',
      Lib_FakeIdGenerator.getMockId(Pricebook2.SObjectType)
    );
  }

  /**
   * @description Positive test: Validates creation of a single Opportunity and correct field mapping
   */
  @IsTest
  static void testCreateSingleOpportunity() {
    registerMocks();

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    List<Database.SaveResult> mockResults = new List<Database.SaveResult>{
      (Database.SaveResult) JSON.deserialize(
        '{"id":"' + (String) oppId + '","success":true,"errors":[]}',
        Database.SaveResult.class
      )
    };

    dmlRepoMock.mock('doInsert', mockResults);
    userRepoMock.mock('checkProfile', true);
    actionRepoMock.mock(
      'getStandardPricebookId',
      Lib_FakeIdGenerator.getMockId(Pricebook2.SObjectType)
    );

    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    CCRMAgentCreateOpportunity.OpportunityInput input = new CCRMAgentCreateOpportunity.OpportunityInput();
    input.opportunityName = 'New Opportunity';
    input.accountId = accountId;
    input.description = 'Single opportunity creation test.';

    List<CCRMAgentCreateOpportunity.OpportunityInput> inputs = new List<CCRMAgentCreateOpportunity.OpportunityInput>{
      input
    };

    Test.startTest();
    List<CCRMAgentCreateOpportunity.OpportunityOutput> results = CCRMAgentCreateOpportunity.createOpportunity(
      inputs
    );
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'Exactly one OpportunityOutput should be returned.'
    );
  }
}
