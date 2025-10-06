/**
 * @author Batya Aisman Sufrin
 * @since 04/2025
 * @description tests for {@link FraudXCaseActions}
 */
@isTest
private class FraudXCaseActionsTest {
  static final Faker FAKER = new Faker('AU');
  static Lib_MockProvider repoMock;
  static Lib_MockProvider dmlRepoMock;
  static Map<String, String> caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(
    Case.Type
  );
  static Case theCase = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  );
  static User fraudXUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    FirstName = 'FraudXUser',
    ProfileId = QueryProfile.anzxUser.Id,
    UserRoleId = QueryRole.fraudXAgent.Id
  );
  static Dispute disputeRec = new Dispute(
    Id = Lib_FakeIdGenerator.getMockId(Dispute.SObjectType),
    CaseId = theCase.Id,
    ReceivedDate = Date.today(),
    RecordTypeId = RTDispute.disputedTransaction,
    OwnerId = fraudXUser.Id
  );
  static DisputeItem disputeItemRec = new DisputeItem(
    Id = Lib_FakeIdGenerator.getMockId(DisputeItem.SObjectType),
    Case__c = theCase.Id,
    DisputeId = disputeRec.Id,
    RecordTypeId = RTDisputeItem.disputedTransaction
  );

  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(FraudXCaseRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static Case mockClosingCase(
    Id recordTypeId,
    Boolean validRecoveryStatus,
    String issueType
  ) {
    theCase.Type = issueType;

    Case oldCase = theCase.clone(true);
    oldCase.Status = 'New';

    theCase.RecordTypeId = recordTypeId;
    theCase.Status = 'Closed';

    List<DisputeItem> mockValue = validRecoveryStatus
      ? new List<DisputeItem>()
      : new List<DisputeItem>{ disputeItemRec };
    repoMock.mock('getTxnItemsByRecoveryStatus', mockValue);

    return oldCase;
  }

  @isTest
  static void testPopulateFraudXCaseSubjectFraud() {
    // GIVEN Fraud Case
    theCase.RecordTypeId = RTCase.fraud;
    theCase.Type = 'Remote Access';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Fraud case subject should be as expected.'
    );
  }

  @isTest
  static void testPopulateFraudXCaseSubjectIdentity() {
    // GIVEN Identity Case
    theCase.RecordTypeId = RTCase.identity;
    theCase.Type = 'Remote Access';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Identity case subject should be as expected.'
    );
  }

  @isTest
  static void testPopulateFraudXCaseSubjectRecipientMule() {
    // GIVEN Recipien/tMule Case
    theCase.RecordTypeId = RTCase.recipientMule;
    theCase.Type = 'Remote Access';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Recipient/Mule case subject should be as expected.'
    );
  }

  @isTest
  static void testPopulateFraudXCaseSubjectScam() {
    // GIVEN Scam Case
    theCase.RecordTypeId = RTCase.scam;
    theCase.Type = 'Remote Access';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Scam case subject should be as expected.'
    );
  }

  //Test to verify Subject auto-population when Case Type has a numerical value different from the label
  @isTest
  static void testPopulateFraudXCaseSubjectNumericType() {
    // GIVEN Scam Case with numeric Type
    theCase.RecordTypeId = RTCase.scam;
    theCase.Type = '12';

    // WHEN a case subject is populated
    Test.startTest();
    FraudXCaseActions.populateFraudXCaseSubject(
      new List<Case>{ theCase },
      new Map<Id, Case>()
    );
    Test.stopTest();

    // THEN Case Subject should be populated based on RecordType Name and Type
    Assert.areEqual(
      RTCase.get(theCase.RecordTypeId).Name +
        ' - ' +
        caseTypeLabelByValue.get(theCase.Type),
      theCase.Subject,
      'Scam case subject should be as expected.'
    );
  }

  @isTest
  static void testChangeRelatedDisputeOwner() {
    registerMocks();

    // GIVEN a Case with valid RecordType and OwnerId
    theCase.RecordTypeId = RTCase.fraud;
    theCase.OwnerId = fraudXUser.Id;

    Case updatedCase = theCase.clone(true);
    updatedCase.OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    repoMock.mock('getRelatedDisputes', new List<Dispute>{ disputeRec });
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );

    // WHEN case owner is changed
    Test.startTest();
    FraudXCaseActions.changeRelatedDisputeOwner(
      new List<Case>{ updatedCase },
      new Map<Id, Case>{ updatedCase.Id => theCase }
    );
    Test.stopTest();

    List<Dispute> relatedDisputes = (List<Dispute>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    // THEN related Disputes should have their OwnerId updated
    Assert.areEqual(
      updatedCase.OwnerId,
      relatedDisputes[0].OwnerId,
      'Dispute OwnerId should match Case OwnerId.'
    );
  }

  @isTest
  static void testGetDisputesForOwnerUpdates() {
    registerMocks();
    theCase.OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    // GIVEN a list of Disputes and Cases
    List<Dispute> disputes = new List<Dispute>{ disputeRec };
    List<Case> cases = new List<Case>{ theCase };

    // WHEN checking the dispute's owner after changing the case owner
    Test.startTest();
    List<Dispute> recordsForUpdates = FraudXCaseActions.getDisputesForOwnerUpdates(
      cases,
      disputes
    );
    Test.stopTest();

    // THEN the records for owner update should be returned
    Assert.isTrue(
      recordsForUpdates.size() > 0,
      'Dispute records for owner update should be returned.'
    );
  }

  @isTest
  static void testvalidateLinkedTxnRecoveryStatusNull() {
    registerMocks();

    // GIVEN that the case is Recipient/Mule and is being closed
    Case oldCase = mockClosingCase(
      RTCase.recipientMule,
      false,
      'Intended Recipient'
    );

    // WHEN the RecoveryStatus is blank
    Test.startTest();
    FraudXCaseActions.validateLinkedTxnRecoveryStatus(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    // THEN there should be a validation error
    Assert.areEqual(
      FraudXCaseActions.RECOVERY_STATUS_VALIDATION_ERROR,
      theCase.getErrors()[0].getMessage(),
      'Error message should match expected validation error.'
    );
  }

  @isTest
  static void testvalidateLinkedTxnRecoveryStatusInvalid() {
    registerMocks();

    // GIVEN that the case is Recipient/Mule and is being closed
    Case oldCase = mockClosingCase(
      RTCase.recipientMule,
      false,
      'Dating & Romance'
    );

    // WHEN the RecoveryStatus is in an invalid state
    Test.startTest();
    FraudXCaseActions.validateLinkedTxnRecoveryStatus(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    // THEN there should be a validation error
    Assert.areEqual(
      FraudXCaseActions.RECOVERY_STATUS_VALIDATION_ERROR,
      theCase.getErrors()[0].getMessage(),
      'Should have error message that match expected validation error.'
    );
  }

  @isTest
  static void testvalidateLinkedTxnRecoveryStatusValid() {
    registerMocks();

    // GIVEN that the case is Recipient/Mule and is being closed
    Case oldCase = mockClosingCase(
      RTCase.recipientMule,
      true,
      'ID Takeover Mule'
    );

    // WHEN the RecoveryStatus is in Valid state
    Test.startTest();
    FraudXCaseActions.validateLinkedTxnRecoveryStatus(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    // THEN there should be NO validation error
    Assert.isFalse(
      theCase.hasErrors(),
      'Should not have any validation error messages.'
    );
  }

  @isTest
  static void testvalidateLinkedTxnRecoveryStatusNotRecipientType() {
    registerMocks();

    // GIVEN that the case is Recipient/Mule and is being closed
    Case oldCase = mockClosingCase(
      RTCase.recipientMule,
      false,
      'Not a Recipient'
    );

    // WHEN the RecoveryStatus is in Invalid state with Issue type=Not a Recipient
    Test.startTest();
    FraudXCaseActions.validateLinkedTxnRecoveryStatus(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    // THEN there should be NO validation error
    Assert.isFalse(
      theCase.hasErrors(),
      'Should not have any validation error messages.'
    );
  }

  @isTest
  static void testvalidateLinkedTxnRecoveryStatusRTNotRecipientMule() {
    registerMocks();

    // GIVEN that the case is NOT Recipient/Mule and is being closed
    Case oldCase = mockClosingCase(RTCase.fraud, true, 'Malware');

    // WHEN the RecoveryStatus is in an invalid state or blank
    Test.startTest();
    FraudXCaseActions.validateLinkedTxnRecoveryStatus(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    // THEN there should NOT be a validation error
    Assert.isFalse(
      theCase.hasErrors(),
      'Should not have any validation error messages.'
    );
  }

  @isTest
  static void testValidateCustomerChange() {
    registerMocks();

    Account customer = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
    theCase.AccountId = customer.Id;

    // GIVEN that the case has linked dispute transactions
    Case oldCase = theCase.clone(true, true);
    oldCase.AccountId = customer.Id;

    //WHEN changing the customer value
    theCase.AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    repoMock.mock('getRelatedDisputes', new List<Dispute>{ disputeRec });

    Test.startTest();
    FraudXCaseActions.validateCustomerChange(
      new List<Case>{ theCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();

    // THEN there should be a validation error
    Assert.areEqual(
      FraudXCaseActions.CUSTOMER_CHANGE_VALIDATION_ERROR,
      theCase.getErrors()[0].getMessage(),
      'Should have error message that match expected validation error.'
    );
  }
}
