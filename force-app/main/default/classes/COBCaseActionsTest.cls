/**
 * @description Test class for {@link COBCaseActions}
 * @author Karen Valeriano
 * @since 08/2023
 */
@isTest
private class COBCaseActionsTest {
  static final Faker FAKER = new Faker('en-AU');

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider cobCaseRepoMock;

  static Id idOpsId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

  static Case idOpsCase = new Case(
    Id = idOpsId,
    RecordTypeId = RTCase.idOpsAssistance,
    Status = COBCaseConstants.COB_POTENTIAL_FRAUD_STATUS,
    CustomerOnboardingApplication__c = Lib_FakeIdGenerator.getMockId(
      CustomerOnboardingApplication__c.SObjectType
    ),
    PersonaId__c = FAKER.randomString(10)
  );

  static Case fraudCheckCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = RTCase.fraudCheck,
    Status = COBCaseConstants.COB_DAON_FALLOUT_STATUS,
    ParentId = idOpsId
  );

  static Map<Id, Case> oldFraudCheckMap = new Map<Id, Case>{
    fraudCheckCase.Id => fraudCheckCase
  };

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    cobCaseRepoMock = Lib_MockProvider.forType(COBCaseRepository.class);
  }

  @isTest
  static void testCreateFraudCheckCase() {
    registerMocks();

    //Create Id Ops Case to be used as Old Map record
    Case oldIdOpsCase = idOpsCase.clone(true);
    oldIdOpsCase.Status = COBCaseConstants.COB_DAON_FALLOUT_STATUS;

    Map<Id, Case> oldIdOpsMap = new Map<Id, Case>{ idOpsId => oldIdOpsCase };

    Test.startTest();
    COBCaseActions.createFraudCheckCase(
      new List<Case>{ idOpsCase },
      oldIdOpsMap
    );
    Test.stopTest();

    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );

    List<Case> insertedRecords = (List<Case>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');

    Assert.areEqual(
      new Case(
        RecordTypeId = RTCase.fraudCheck,
        OwnerId = QueryQueue.cobFraudCheckQueue.Id,
        Status = oldIdOpsCase.Status,
        ParentId = oldIdOpsCase.Id,
        Subject = 'Fraud Check Case',
        CustomerOnboardingApplication__c = idOpsCase.CustomerOnboardingApplication__c,
        PersonaId__c = idOpsCase.PersonaId__c
      ),
      insertedRecords[0],
      'New Fraud Check Case record should be created with the correct field values'
    );
  }

  @isTest
  static void testSetIDOpsCaseStatusConfirmedFraud() {
    registerMocks();

    //Update the Fraud Check Case status and OnboardingVerificationFailedReason__c
    fraudCheckCase.Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;
    fraudCheckCase.OnboardingVerificationFailedReason__c = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;

    List<Case> idOpsCases = new List<Case>{ idOpsCase };
    cobCaseRepoMock.mock('getCasesByIds', idOpsCases);

    //Create Map of ParentId and updated Child Case
    Map<Id, Case> parentIdAndChildCaseMap = new Map<Id, Case>{
      fraudCheckCase.ParentId => fraudCheckCase
    };

    Test.startTest();
    idOpsCases = COBCaseActions.setIDOpsCaseStatus(
      parentIdAndChildCaseMap,
      oldFraudCheckMap
    );
    Test.stopTest();

    Assert.isFalse(
      cobCaseRepoMock.getHistories('getCasesByIds').isEmpty(),
      'getCasesByIds should have been called'
    );

    Assert.areEqual(
      fraudCheckCase.Status,
      idOpsCases[0].Status,
      'Status should be ' + fraudCheckCase.Status
    );

    Assert.areEqual(
      fraudCheckCase.OnboardingVerificationFailedReason__c,
      idOpsCases[0].OnboardingVerificationFailedReason__c,
      'OnboardingVerificationFailedReason__c should be ' +
      fraudCheckCase.OnboardingVerificationFailedReason__c
    );
  }

  @isTest
  static void testSetIDOpsCaseStatusToDaonFallout() {
    registerMocks();

    //Clone existing Fraud Case record to preserve the one that's in oldFraudCheckMap
    Case newFraudCase = fraudCheckCase.clone(true);

    //Update the Fraud Check Case status
    newFraudCase.Status = COBCaseConstants.COB_NOT_A_FRAUD_STATUS;

    //Create Map of ParentId and updated Child Case
    Map<Id, Case> newParentIdAndChildCaseMap = new Map<Id, Case>{
      newFraudCase.ParentId => newFraudCase
    };

    List<Case> idOpsCases = new List<Case>{ idOpsCase };
    cobCaseRepoMock.mock('getCasesByIds', idOpsCases);

    Test.startTest();
    idOpsCases = COBCaseActions.setIDOpsCaseStatus(
      newParentIdAndChildCaseMap,
      oldFraudCheckMap
    );
    Test.stopTest();

    Assert.isFalse(
      cobCaseRepoMock.getHistories('getCasesByIds').isEmpty(),
      'getCasesByIds should have been called'
    );

    Assert.areEqual(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      idOpsCases[0].Status,
      'Status should be ' + COBCaseConstants.COB_DAON_FALLOUT_STATUS
    );

    Assert.isTrue(
      String.isBlank(idOpsCases[0].OnboardingVerificationFailedReason__c),
      'OnboardingVerificationFailedReason__c should be blank'
    );
  }

  @isTest
  static void testSetIDOpsCaseStatusToEquifaxFallout() {
    registerMocks();

    fraudCheckCase.Status = COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS;
    //Clone existing Fraud Case record to preserve the one that's in oldFraudCheckMap
    Case newFraudCase = fraudCheckCase.clone(true);

    //Update the Fraud Check Case status
    newFraudCase.Status = COBCaseConstants.COB_NOT_A_FRAUD_STATUS;

    //Map of ParentId and updated Child Case
    Map<Id, Case> newParentIdAndChildCaseMap = new Map<Id, Case>{
      newFraudCase.ParentId => newFraudCase
    };

    List<Case> idOpsCases = new List<Case>{ idOpsCase };
    cobCaseRepoMock.mock('getCasesByIds', idOpsCases);

    Test.startTest();
    idOpsCases = COBCaseActions.setIDOpsCaseStatus(
      newParentIdAndChildCaseMap,
      oldFraudCheckMap
    );
    Test.stopTest();

    Assert.isFalse(
      cobCaseRepoMock.getHistories('getCasesByIds').isEmpty(),
      'getCasesByIds should have been called'
    );

    Assert.areEqual(
      COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS,
      idOpsCases[0].Status,
      'Status should be ' + COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS
    );

    Assert.isTrue(
      String.isBlank(idOpsCases[0].OnboardingVerificationFailedReason__c),
      'OnboardingVerificationFailedReason__c should be blank'
    );
  }

  @isTest
  static void testUpdateIDOpsCaseStatus() {
    registerMocks();
    cobCaseRepoMock.mock('getCasesByIds', new List<Case>{ idOpsCase });

    //Clone existing Fraud Case record to preserve the one that's in oldFraudCheckMap
    Case childFraudCase = fraudCheckCase.clone(true);

    //Update the Fraud Check Case status
    childFraudCase.Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;

    Test.startTest();
    COBCaseActions.updateIdOpsCaseStatus(
      new List<Case>{ childFraudCase },
      oldFraudCheckMap
    );
    Test.stopTest();

    Assert.isFalse(
      cobCaseRepoMock.getHistories('getCasesByIds').isEmpty(),
      'getCasesByIds should have been called'
    );

    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<Case> parentIdOpsRecords = (List<Case>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.areEqual(
      childFraudCase.Status,
      parentIdOpsRecords[0].Status,
      'The ID Ops Case record should have been updated with ' +
      childFraudCase.Status
    );
  }
}
