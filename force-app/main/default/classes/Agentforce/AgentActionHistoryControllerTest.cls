/**
 * @author Ian Huang
 * @since April 2026
 * @description Unit testing class for AgentActionHistory LWC controller class
 * @group Platform
 */
@IsTest
private class AgentActionHistoryControllerTest {
  /**
   * @description
   * Mock provider used to stub DmlRepository behavior during unit tests.
   */
  static Lib_MockProvider dmlRepoMock;
  /**
   * @description
   * Mock provider used to stub CCRMAgentActionRepository behavior during unit tests.
   */
  static Lib_MockProvider agentActionRepoMock;

  /**
   * @description
   * Registers mock implementations for DmlRepository to prevent real DML execution.
   */
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    agentActionRepoMock = Lib_MockProvider.forType(
      CCRMAgentforceActionRepository.class
    );
  }

  /**
   * @description
   * Reference to the DmlRepository instance under test, resolved via InstanceProvider.
   */
  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description
   * Test setup method that registers common DmlRepository mocks.
   * Ensures all insert operations return successful save results without executing real DML during tests.
   */
  @TestSetup
  static void setupMocks() {
    registerMocks();
    // Prepare robust save results to cover all doInsert call shapes and avoid real DML.
    // 1) Single SObject insert returns a single Database.SaveResult inside a List.
    List<Database.SaveResult> singleSaveResult = new List<Database.SaveResult>{
      (Database.SaveResult) JSON.deserialize(
        '{"id":"' +
          (String) Lib_FakeIdGenerator.getMockId(Account.SObjectType) +
          '","success":true,"errors":[]}',
        Database.SaveResult.class
      )
    };

    // 2) Agent Action History single insert result
    List<Database.SaveResult> aahSingleSaveResult = new List<Database.SaveResult>{
      (Database.SaveResult) JSON.deserialize(
        '{"id":"' +
          (String) Lib_FakeIdGenerator.getMockId(
            Agent_Action_History__c.SObjectType
          ) +
          '","success":true,"errors":[]}',
        Database.SaveResult.class
      )
    };

    // 3) Generic list insert result with two successful entries to cover batch inserts
    List<Database.SaveResult> twoSaveResults = new List<Database.SaveResult>{
      (Database.SaveResult) JSON.deserialize(
        '{"id":"' +
          (String) Lib_FakeIdGenerator.getMockId(
            Agent_Action_History__c.SObjectType
          ) +
          '","success":true,"errors":[]}',
        Database.SaveResult.class
      ),
      (Database.SaveResult) JSON.deserialize(
        '{"id":"' +
          (String) Lib_FakeIdGenerator.getMockId(
            Agent_Action_History__c.SObjectType
          ) +
          '","success":true,"errors":[]}',
        Database.SaveResult.class
      )
    };

    // Mock doInsert for various call shapes. Order matters for this Lib_MockProvider implementation;
    // register the most specific mocks first and generic last.
    dmlRepoMock.mock('doInsert', singleSaveResult); // covers Account insert
    dmlRepoMock.mock('doInsert', aahSingleSaveResult); // covers single Agent_Action_History__c insert
    dmlRepoMock.mock('doInsert', twoSaveResults); // covers list inserts (returns two successes)
  }
  /**
   * @description POSITIVE TEST
   * - createAgentActionHistory inserts records successfully
   */
  @IsTest
  static void testCreateAgentActionHistorySuccess() {
    AgentActionHistoryController controller = new AgentActionHistoryController();

    String recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    Test.startTest();
    controller.createAgentActionHistory(
      'Account',
      'Test Agent',
      'Created',
      new List<String>{ recordId }
    );
    Test.stopTest();

    // Verify record inserted
    List<Agent_Action_History__c> histories = [
      SELECT
        Related_Object_Type__c,
        Agent_Name__c,
        Action__c,
        Related_Record_Id__c
      FROM Agent_Action_History__c
    ];

    System.assertEquals(
      1,
      histories.size(),
      'One Agent Action History record should be created'
    );
  }

  /**
   * @description NEGATIVE TEST
   * - Invalid input causes DML failure
   * - Exception is caught
   * - No records inserted
   */
  @IsTest
  static void testCreateAgentActionHistoryCatchBlock() {
    AgentActionHistoryController controller = new AgentActionHistoryController();

    Test.startTest();
    controller.createAgentActionHistory(
      null, // invalid
      null, // invalid
      null, // invalid
      new List<String>{ Lib_FakeIdGenerator.getMockId(Account.SObjectType) }
    );
    Test.stopTest();

    // Since exception is caught, no records should exist
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Agent_Action_History__c],
      'No records should be inserted when exception occurs'
    );
  }

  /**
   * @description NEGATIVE TEST
   * - No histories exist for the record
   * - Wrapper fields should be null
   * - Histories list should be empty
   */
  @IsTest
  static void getAgentActionHistoryNoHistories() {
    Test.startTest();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    AgentActionHistoryController.AgentActionHistoryWrapper result = AgentActionHistoryController.getAgentActionHistory(
      accId,
      'Detail View'
    );
    Test.stopTest();

    System.assertEquals(null, result.createdBy, 'createdBy should be null');
    System.assertEquals(null, result.createdAt, 'createdAt should be null');
    System.assertEquals(
      null,
      result.lastModifiedBy,
      'lastModifiedBy should be null'
    );
    System.assertEquals(
      null,
      result.lastModifiedAt,
      'lastModifiedAt should be null'
    );
    System.assertEquals(
      0,
      result.histories != null ? result.histories.size() : 0,
      'size should be 0'
    );
  }

  /**
   * @description POSITIVE TEST
   * - List View mode
   * - Wrapper metadata NOT populated
   * - Histories returned
   */

  @IsTest
  static void getAgentActionHistoryListView() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    insert new Agent_Action_History__c(
      Agent_Name__c = 'List Agent',
      Action__c = 'Created',
      Related_Object_Type__c = 'Task',
      Related_Record_Id__c = accId
    );

    Test.startTest();
    AgentActionHistoryController.AgentActionHistoryWrapper result = AgentActionHistoryController.getAgentActionHistory(
      accId,
      'List View'
    );
    Test.stopTest();

    System.assertEquals(null, result.createdBy, 'createdBy should be null');
    System.assertEquals(null, result.createdAt, 'createdAt should be null');
    System.assertEquals(
      null,
      result.lastModifiedBy,
      'lastModifiedBy should be null'
    );
    System.assertEquals(
      null,
      result.lastModifiedAt,
      'lastModifiedAt should be null'
    );
  }
  /**
   * @description POSITIVE TEST
   * - Detail View mode
   * - Repository is mocked because parent record cannot be inserted
   * - Created and Updated histories exist
   * - Wrapper metadata should be populated
   */
  @IsTest
  static void getAgentActionHistoryDetailViewCreatedAndUpdated() {
    registerMocks();

    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    Agent_Action_History__c createdHistory = (Agent_Action_History__c) JSON.deserialize(
      '{"attributes":{"type":"Agent_Action_History__c"},' +
        '"Id":"' +
        String.valueOf(
          Lib_FakeIdGenerator.getMockId(Agent_Action_History__c.SObjectType)
        ) +
        '",' +
        '"Agent_Name__c":"Created Agent",' +
        '"Action__c":"Created",' +
        '"Related_Object_Type__c":"Account",' +
        '"Related_Record_Id__c":"' +
        String.valueOf(recordId) +
        '",' +
        '"CreatedDate":"2026-04-01T10:00:00.000+0000"}',
      Agent_Action_History__c.class
    );

    Agent_Action_History__c updatedHistory = (Agent_Action_History__c) JSON.deserialize(
      '{"attributes":{"type":"Agent_Action_History__c"},' +
        '"Id":"' +
        String.valueOf(
          Lib_FakeIdGenerator.getMockId(Agent_Action_History__c.SObjectType)
        ) +
        '",' +
        '"Agent_Name__c":"Updated Agent",' +
        '"Action__c":"Updated",' +
        '"Related_Object_Type__c":"Account",' +
        '"Related_Record_Id__c":"' +
        String.valueOf(recordId) +
        '",' +
        '"CreatedDate":"2026-04-02T10:00:00.000+0000"}',
      Agent_Action_History__c.class
    );

    List<Agent_Action_History__c> mockHistories = new List<Agent_Action_History__c>{
      createdHistory,
      updatedHistory
    };

    agentActionRepoMock.mock('getAgentActionHistory', mockHistories);

    Test.startTest();
    AgentActionHistoryController.AgentActionHistoryWrapper result = AgentActionHistoryController.getAgentActionHistory(
      recordId,
      'Detail View'
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Wrapper should not be null');

    System.assertNotEquals(
      null,
      result.histories,
      'Histories should not be null'
    );

    System.assertEquals(
      2,
      result.histories.size(),
      'Two Agent Action History records should be returned'
    );

    System.assertEquals(
      'Created Agent',
      result.createdBy,
      'createdBy should come from Created history'
    );

    System.assertNotEquals(
      null,
      result.createdAt,
      'createdAt should be populated from Created history'
    );

    System.assertEquals(
      'Updated Agent',
      result.lastModifiedBy,
      'lastModifiedBy should come from Updated history'
    );

    System.assertNotEquals(
      null,
      result.lastModifiedAt,
      'lastModifiedAt should be populated from Updated history'
    );
  }
}
