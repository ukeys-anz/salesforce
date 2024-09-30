/**
 * @author shawg2
 * @since Jan 2024
 * @description Test class for GetHelpCaseActions
 */
@IsTest
private class GetHelpCaseActionsTest {
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @IsTest
  static void setOwnerToIDOpsQueue() {
    Account oAccount = TestDataFactory.createAccount(true);

    List<Case> lstCases = new List<Case>{
      new Case(
        AccountId = oAccount.Id,
        RecordTypeId = RTCase.profileUpdate,
        Type = GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
        Status = GetHelpConstants.OPEN_STATUS
      ),
      new Case(AccountId = oAccount.Id, RecordTypeId = RTCase.generalInquiry)
    };

    Test.startTest();

    GetHelpCaseActions.setOwnerToIDOpsQueue(lstCases);

    Test.stopTest();

    for (Case oCase : lstCases) {
      if (oCase.RecordTypeId == RTCase.profileUpdate) {
        Assert.areEqual(
          GetHelpCaseActions.idOpsQueue.Id,
          oCase.OwnerId,
          'Profile Update cases should be assigned to the ID Ops Queue on insert'
        );
      } else {
        Assert.areNotEqual(
          GetHelpCaseActions.idOpsQueue.Id,
          oCase.OwnerId,
          'Non-Profile Update cases should not be assigned to ID Ops Queue on insert'
        );
      }
    }
  }

  // Checks if case is valid to create external case status record
  @isTest
  public static void testIsValidCaseToCreateExtCaseStatus() {
    ExternalCaseStatusMappingQueryHelper externalCaseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = externalCaseStatusQueryHelper.getSalesforceStatusToMetadataMap();

    Case theCase = TestDataFactory.createCase('ATM_Dispute');
    theCase.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case theOldCase = theCase;
    theOldCase.Id = theCase.Id;
    theOldCase.Status = 'On Hold';
    Test.startTest();
    Boolean isValid = GetHelpCaseActions.isValidCaseToCreateExtCaseStatus(
      new Map<Id, Case>{ theOldCase.Id => theOldCase },
      theCase,
      statusToMetadataMap
    );
    Test.stopTest();
    Assert.isFalse(
      isValid,
      'Dispute should be valid to create external case status'
    );
  }

  // Checks and creates external case status record
  @isTest
  public static void testCreateExternalCaseStatus() {
    registerMocks();

    dmlRepoMock.mock(
      'insertRecords',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );

    List<Case> lstCases = new List<Case>{
      new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        RecordTypeId = GetHelpConstants.NPP_DISPUTE_RT_ID,
        Type = GetHelpConstants.RESIDENTIAL_ADDRESS_QA,
        Status = GetHelpConstants.UNDER_INVESTIGATION_STATUS,
        Dispute_Reason__c = 'Unauthorised Transaction'
      )
    };
    Case oldCase = TestDataFactory.createCase('NPP_Dispute');
    oldCase.Dispute_Reason__c = 'Unauthorised Transaction';
    oldCase.Status = 'On Hold';

    Test.startTest();
    GetHelpCaseActions.createExternalCaseStatuses(
      lstCases,
      new Map<Id, Case>{ lstCases[0].Id => oldCase }
    );
    Test.stopTest();
    List<External_Case_Status__c> extCaseStatuses = (List<External_Case_Status__c>) dmlRepoMock.getHistory(
        'insertRecords'
      )
      .getParam('records');
    Assert.isTrue(
      extCaseStatuses.size() == 1,
      'Only one external case record should be created'
    );
    Assert.isTrue(
      extCaseStatuses[0].Case__c == lstCases[0].Id,
      'External Case Status is not created correctly'
    );
  }

  @isTest
  public static void testExternalCaseStatusNotCreated() {
    registerMocks();

    dmlRepoMock.mock(
      'insertRecords',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":false}')
      }
    );
    Case theCase = TestDataFactory.createCase('NPP_Dispute');
    theCase.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case oldCase = theCase;
    oldCase.Status = 'On Hold';

    Test.startTest();
    GetHelpCaseActions.createExternalCaseStatuses(
      new List<Case>{ theCase },
      new Map<Id, Case>{ theCase.Id => oldCase }
    );
    Test.stopTest();
    List<External_Case_Status__c> extCaseStatuses = (List<External_Case_Status__c>) dmlRepoMock.getHistory(
        'insertRecords'
      )
      .getParam('records');
    Assert.isTrue(
      extCaseStatuses.size() == 0,
      'Only one external case record should be created'
    );
  }

  @isTest
  public static void testMarkSlaStatus() {
    Case theCase = TestDataFactory.createCase('Credit_Referral');
    theCase.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    theCase.Status = 'On Hold';
    Case oldCase = TestDataFactory.createCase('Credit_Referral');
    Test.startTest();
    GetHelpCaseActions.markSLAStatus(
      new List<Case>{ theCase },
      new Map<Id, Case>{ theCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isTrue(theCase.IsStopped, 'IsStopped should be true');
  }
}
