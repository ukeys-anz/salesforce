/**
 * @author Tan Phan
 * @since 04/2024
 * @description Test class for {@link DisputeExternalCaseStatusActions}
 */
@isTest
private class DisputeExternalCaseStatusActionsTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider decsRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    decsRepoMock = Lib_MockProvider.forType(
        DisputeExternalCaseStatusRepository.class
      )
      .mock('queryMappings', queryMappingsMock);
  }

  static PegaExternalCaseStatuses__mdt mappingWithReason = new PegaExternalCaseStatuses__mdt(
    MasterLabel = faker.randomString(9),
    DisputeReason__c = faker.randomString(9),
    DisputeStatus__c = faker.randomString(9),
    QueueName__c = 'TobeWorkedFraudDisputes',
    ExternalStatus__c = faker.randomString(9),
    RecordType__c = faker.randomString(9),
    SLADaysInStatus__c = 1,
    SLAQueueName__c = 'CardDisputesAwaitingContact'
  );

  static PegaExternalCaseStatuses__mdt mappingWithoutReason = new PegaExternalCaseStatuses__mdt(
    MasterLabel = faker.randomString(10),
    DisputeStatus__c = faker.randomString(10),
    QueueName__c = 'TobeWorkedSchemeDisputes',
    ExternalStatus__c = faker.randomString(10),
    RecordType__c = faker.randomString(10),
    SLADaysInStatus__c = 1,
    SLAQueueName__c = 'CardDisputesAwaitingContact'
  );

  static List<PegaExternalCaseStatuses__mdt> queryMappingsMock = new List<PegaExternalCaseStatuses__mdt>{
    mappingWithReason,
    mappingWithoutReason
  };

  static Case caseWithReason = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Dispute_Reason__c = mappingWithReason.DisputeReason__c,
      RecordType = new RecordType(
        DeveloperName = mappingWithReason.RecordType__c
      )
    ),
    new Map<String, List<SObject>>{
      'External_Case_Statuses__r' => new List<External_Case_Status__c>{
        new External_Case_Status__c(
          External_Status__c = mappingWithReason.ExternalStatus__c,
          Status_TimeStamp__c = System.now().addDays(-1)
        )
      }
    }
  );

  static Case caseWithoutReason = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordType = new RecordType(
        DeveloperName = mappingWithoutReason.RecordType__c
      )
    ),
    new Map<String, List<SObject>>{
      'External_Case_Statuses__r' => new List<External_Case_Status__c>{
        new External_Case_Status__c(
          External_Status__c = mappingWithoutReason.ExternalStatus__c,
          Status_TimeStamp__c = System.now().addDays(-1)
        )
      }
    }
  );

  @IsTest
  static void testGetMappingWithReason() {
    registerMocks();

    Case testCase = caseWithReason;
    PegaExternalCaseStatuses__mdt testMapping = mappingWithReason;
    decsRepoMock.mock(
      'queryMappings',
      new List<PegaExternalCaseStatuses__mdt>{ testMapping }
    );

    Test.startTest();
    PegaExternalCaseStatuses__mdt retrievedMapping = DisputeExternalCaseStatusActions.getMapping(
      testCase
    );
    Test.stopTest();

    Assert.areEqual(
      testMapping.MasterLabel,
      retrievedMapping.MasterLabel,
      'Mapping should be retrieved in accordance to the given Case and External_Case_Status__c'
    );
  }

  @IsTest
  static void testGetMappingWithoutReason() {
    registerMocks();

    Case testCase = caseWithoutReason;
    PegaExternalCaseStatuses__mdt testMapping = mappingWithoutReason;
    decsRepoMock.mock(
      'queryMappings',
      new List<PegaExternalCaseStatuses__mdt>{ testMapping }
    );

    Test.startTest();
    PegaExternalCaseStatuses__mdt retrievedMapping = DisputeExternalCaseStatusActions.getMapping(
      testCase
    );
    Test.stopTest();

    Assert.areEqual(
      testMapping.MasterLabel,
      retrievedMapping.MasterLabel,
      'Mapping should be retrieved in accordance to the given Case and External_Case_Status__c'
    );
  }

  @IsTest
  static void testGetMappingCaseWithoutChild() {
    registerMocks();

    Case testCase = new Case();

    Test.startTest();
    PegaExternalCaseStatuses__mdt retrievedMapping = DisputeExternalCaseStatusActions.getMapping(
      testCase
    );
    Test.stopTest();

    Assert.isNull(
      retrievedMapping,
      'No mapping should be retrieved when case has no child External_Case_Status__c'
    );
  }

  @IsTest
  static void testAssignCaseToOriginalQueue() {
    registerMocks();

    Case testCase = caseWithReason;
    PegaExternalCaseStatuses__mdt testMapping = mappingWithReason;
    dmlRepoMock.mock(
      'updateRecords',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
    decsRepoMock.mock('queryCasesWithLatestStatus', new List<Case>{ testCase });

    Test.startTest();
    DisputeExternalCaseStatusController.assignCaseToOriginalQueue(testCase.Id);
    Test.stopTest();

    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');
    Assert.areEqual(1, cases.size(), '1 case should be updated');
    Assert.areEqual(
      testMapping.DisputeStatus__c,
      cases[0].Status,
      'Case status should be set in accordance to mapping'
    );
    Assert.areEqual(
      CommonUtil.getQueueByName(testMapping.QueueName__c).Id,
      cases[0].OwnerId,
      'Case owner should be set in accordance to mapping'
    );
  }

  @IsTest
  static void testAssignCaseToOriginalQueueException() {
    registerMocks();

    Case testCase = caseWithReason;
    dmlRepoMock.mock('updateRecords', new List<Database.SaveResult>());
    decsRepoMock.mock('queryCasesWithLatestStatus', new List<Case>{ testCase });

    try {
      Test.startTest();
      DisputeExternalCaseStatusController.assignCaseToOriginalQueue(
        testCase.Id
      );
      Test.stopTest();
      Assert.fail('Error message should be thrown');
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'AuraHandledException should be thrown'
      );
    }
  }

  @IsTest
  static void testUpdateRelatedCasesStatusAndOwner() {
    registerMocks();

    PegaExternalCaseStatuses__mdt testMapping = mappingWithReason;
    Case testCase = caseWithReason;
    External_Case_Status__c testCaseStatus = new External_Case_Status__c(
      Case__c = testCase.Id
    );
    decsRepoMock.mock('queryCasesWithLatestStatus', new List<Case>{ testCase });

    Test.startTest();
    DisputeExternalCaseStatusActions.updateRelatedCasesStatusAndOwner(
      new List<External_Case_Status__c>{ testCaseStatus }
    );
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('updateRecords').isEmpty(),
      'updateRecords should have been invoked at least once'
    );
    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');
    Assert.areEqual(1, cases.size(), '1 case should be updated');
    Assert.areEqual(
      testMapping.DisputeStatus__c,
      cases[0].Status,
      'Case status should be set in accordance to mapping'
    );
    Assert.areEqual(
      CommonUtil.getQueueByName(testMapping.QueueName__c).Id,
      cases[0].OwnerId,
      'Case owner should be set in accordance to mapping'
    );
  }

  @IsTest
  static void testSetCaseStatusAndOwnerNoMapping() {
    registerMocks();

    Case testCase = caseWithReason;
    decsRepoMock.mock(
      'queryMappings',
      new List<PegaExternalCaseStatuses__mdt>()
    );

    Test.startTest();
    List<Case> cases = DisputeExternalCaseStatusActions.setCaseStatusAndOwner(
      new List<Case>{ testCase }
    );
    Test.stopTest();

    Assert.isTrue(
      cases.isEmpty(),
      'No case should be updated when no mapping is found'
    );
  }

  @IsTest
  static void testSetCaseStatusAndOwnerNoQueue() {
    registerMocks();

    Case testCase = caseWithReason;
    PegaExternalCaseStatuses__mdt testMapping = mappingWithReason;
    testMapping.QueueName__c = faker.randomString(10);
    decsRepoMock.mock(
      'queryMappings',
      new List<PegaExternalCaseStatuses__mdt>{ testMapping }
    );

    Test.startTest();
    List<Case> cases = DisputeExternalCaseStatusActions.setCaseStatusAndOwner(
      new List<Case>{ testCase }
    );
    Test.stopTest();

    Assert.isTrue(
      cases.isEmpty(),
      'No case should be updated when no queue is found'
    );
  }

  @IsTest
  static void testSetCaseStatusAndOwnerNoChange() {
    registerMocks();

    PegaExternalCaseStatuses__mdt testMapping = mappingWithReason;
    Case testCase = caseWithReason;
    testCase.Status = testMapping.DisputeStatus__c;
    testCase.OwnerId = CommonUtil.getQueueByName(testMapping.QueueName__c).Id;

    Test.startTest();
    List<Case> cases = DisputeExternalCaseStatusActions.setCaseStatusAndOwner(
      new List<Case>{ testCase }
    );
    Test.stopTest();

    Assert.isTrue(
      cases.isEmpty(),
      'No case should be updated when no changes are made to Status and OwnerId'
    );
  }

  @IsTest
  static void testDisputeCaseToSlaQueueAssignment() {
    registerMocks();

    PegaExternalCaseStatuses__mdt testMapping = mappingWithReason;
    Case testCase = caseWithReason;
    External_Case_Status__c testCaseStatus = new External_Case_Status__c(
      Case__c = testCase.Id
    );
    decsRepoMock.mock(
      new Map<String, Object>{
        'queryCasesWithLatestStatus' => new List<Case>{ testCase },
        'queryCaseStatuses' => new List<External_Case_Status__c>{
          testCaseStatus
        }
      }
    );

    Test.startTest();
    new DisputeCaseToSlaQueueSchedulable().execute(null);
    Test.stopTest();

    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');

    Assert.areEqual(1, cases.size(), '1 case should be updated');
    Assert.areEqual(
      CommonUtil.getQueueByName(testMapping.SLAQueueName__c).Id,
      cases[0].OwnerId,
      'Case owner should be set to SLA queue in accordance to mapping'
    );
  }

  @IsTest
  static void testAssignCaseToSlaQueueNoMapping() {
    registerMocks();

    Case testCase = caseWithReason;
    decsRepoMock.mock(
      'queryMappings',
      new List<PegaExternalCaseStatuses__mdt>()
    );

    Test.startTest();
    List<Case> cases = DisputeExternalCaseStatusActions.assignCaseToSlaQueue(
      new List<Case>{ testCase }
    );
    Test.stopTest();

    Assert.isTrue(
      cases.isEmpty(),
      'No case should be updated when no mapping is found'
    );
  }

  @IsTest
  static void testAssignCaseToSlaQueueNoQueue() {
    registerMocks();

    Case testCase = caseWithReason;
    PegaExternalCaseStatuses__mdt testMapping = mappingWithReason;
    testMapping.SlaQueueName__c = faker.randomString(10);
    decsRepoMock.mock(
      'queryMappings',
      new List<PegaExternalCaseStatuses__mdt>{ testMapping }
    );

    Test.startTest();
    List<Case> cases = DisputeExternalCaseStatusActions.assignCaseToSlaQueue(
      new List<Case>{ testCase }
    );
    Test.stopTest();

    Assert.isTrue(
      cases.isEmpty(),
      'No case should be updated when no queue is found'
    );
  }
}
