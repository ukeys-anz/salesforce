/**
 * @author Mohit Garg
 * @date March 2026
 * @description Test class for {@link DisputeCasesAssignmentRules} assignment rule test
 */
@isTest
public with sharing class DisputeCasesAssignmentRulesTest {
  private static final String SUSPECTED_FRAUD = 'Suspected fraud';
  private static final String CANCEL_PAYMENT = 'Cancel Payment';
  private static final String MONEY_NOT_RECEIVED = 'Money not received';
  private static final String OPEN_STATUS = 'Open';
  private static final String AMENDMENT_REQUEST = 'Amendment Request';

  /**
   * @description : This is to test for IMT dispute assignment rule for CreatedbyUserId assignment when dispute reason is updated from SUSPECTED_FRAUD to any other value and submitted__c is false
   */
  @isTest
  static void testCaseAssignmentToCreatedByUser() {
    Case oldCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Description = 'Test IMT',
      submitted__c = false,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      Subject = 'Test IMT Case assignment to Support Coach queue',
      Dispute_Reason__c = SUSPECTED_FRAUD
    );

    Case newCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Description = 'Test IMT Update',
      submitted__c = false,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = oldCase.Id,
      Subject = 'Test IMT Case assignment to Support Coach queue',
      Dispute_Reason__c = CANCEL_PAYMENT
    );

    Test.startTest();
    DisputeCasesAssignmentRules.assignDisputeCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.areEqual(
      oldCase.createdById,
      newCase.OwnerId,
      'Case must be assigned to the CreatedbyUser.'
    );
  }
  /**
   * @description : This is to test for IMT dispute assignment rule for Suport Coach queue
   * For dispute reason CANCEL_PAYMENT, MONEY_NOT_RECEIVED and AMENDMENT_REQUEST  case must be assigned to supportCoachQueue when Case is updated as submitted__c is true
   */
  @isTest
  static void testSupportCoachQueueImtOnUpdate() {
    Case oldCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Description = 'Test IMT',
      submitted__c = false,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      Subject = 'Test IMT Case assignment to Support Coach queue',
      Dispute_Reason__c = CANCEL_PAYMENT
    );

    Case newCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Description = 'Test IMT Update',
      submitted__c = true,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = oldCase.Id,
      Subject = 'Test IMT Case assignment to Support Coach queue',
      Dispute_Reason__c = CANCEL_PAYMENT
    );

    Test.startTest();
    DisputeCasesAssignmentRules.assignDisputeCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.areEqual(
      QueryQueue.supportCoachQueue.Id,
      newCase.OwnerId,
      'Case must be assigned to the Support Coach Queue.'
    );
  }

  /**
   * @description : This is to test for IMT dispute assignment rule for Suport Coach queue
   * For dispute reason CANCEL_PAYMENT, MONEY_NOT_RECEIVED and AMENDMENT_REQUEST  case must be assigned to supportCoachQueue when Dispute_Reason__c is updated to any of these values and submitted__c is true
   */
  @isTest
  static void testSupportCoachQueueIMTonUpdateDisputeReason() {
    Case oldCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Description = 'Test IMT',
      Dispute_Reason__c = CANCEL_PAYMENT,
      submitted__c = false,
      origin = 'Self Service',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      Subject = 'Test IMT Case assignment to Support Coach queue'
    );

    Case newCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Description = 'Test IMT Update',
      origin = 'Self Service',
      submitted__c = true,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = oldCase.Id,
      Subject = 'Test IMT Case assignment to Support Coach queue',
      Dispute_Reason__c = MONEY_NOT_RECEIVED
    );

    Test.startTest();
    DisputeCasesAssignmentRules.assignDisputeCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.areEqual(
      QueryQueue.supportCoachQueue.Id,
      newCase.OwnerId,
      'Case must be assigned to the Support Coach Queue.'
    );
  }

  /**
   * @description : This is to test for IMT dispute assignment rule should not assigned to Suport Coach queue
   * For dispute reason CANCEL_PAYMENT, MONEY_NOT_RECEIVED and AMENDMENT_REQUEST  case should not be assigned to supportCoachQueue
   */
  @isTest
  static void testSupportCoachQueueIMTNotAssigned() {
    Case imtCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Description = 'Test IMT',
      submitted__c = false,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      Subject = 'Test IMT Case assignment to Support Coach queue',
      Dispute_Reason__c = CANCEL_PAYMENT
    );

    Test.startTest();
    DisputeCasesAssignmentRules.assignDisputeCases(
      new List<Case>{ imtCase },
      null
    );
    Test.stopTest();
    Assert.isTrue(
      imtCase.OwnerId != QueryQueue.supportCoachQueue.Id,
      'Case must not be assigned to the Support Coach Queue.'
    );
  }

  /**
   * @description : This is to test for IMT dispute assignment rule for DIGITAL_FRAUD_QUEUE For Self Service
   * For dispute reason SUSPECTED_FRAUD, case must be assigned to digitalFraudQueue
   */
  @isTest
  static void testDigitalFraudQueueIMT() {
    Case imtCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Subject = 'Test IMT Case assignment to DIGITAL_FRAUD_QUEUE',
      Dispute_Reason__c = SUSPECTED_FRAUD,
      Submitted__c = false,
      Description = 'Test IMT',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType())
    );
    Case imtNewCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Subject = 'Test IMT Case assignment to DIGITAL_FRAUD_QUEUE',
      Dispute_Reason__c = SUSPECTED_FRAUD,
      Submitted__c = true,
      Description = 'Test IMT',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType())
    );

    Test.startTest();
    DisputeCasesAssignmentRules.assignDisputeCases(
      new List<Case>{ imtCase, imtNewCase },
      null
    );
    Test.stopTest();
    Assert.areEqual(
      QueryQueue.digitalFraudQueue.Id,
      imtCase.OwnerId,
      'Case must be assigned to the Digital Fraud Queue.'
    );
    Assert.areEqual(
      QueryQueue.digitalFraudQueue.Id,
      imtNewCase.OwnerId,
      'Case must be assigned to the Digital Fraud Queue.'
    );
  }

  /**
   * @description : This is to test for IMT dispute assignment rule on Case Update for DIGITAL_FRAUD_QUEUE For Self Service
   * For dispute reason SUSPECTED_FRAUD, case must be assigned to digitalFraudQueue when dispute_reason__c is updated to SUSPECTED_FRAUD and submitted__c is true
   */
  @isTest
  static void testDigitalFraudQueueIMTSubmittedForUpdate() {
    Case oldCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Subject = 'Test IMT Case assignment to DIGITAL_FRAUD_QUEUE',
      Dispute_Reason__c = CANCEL_PAYMENT,
      Submitted__c = true,
      Description = 'Test IMT',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType())
    );
    Case newCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Subject = 'Test IMT Case assignment to DIGITAL_FRAUD_QUEUE',
      Dispute_Reason__c = SUSPECTED_FRAUD,
      Submitted__c = true,
      Description = 'Test New Case IMT',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = oldCase.Id
    );

    Test.startTest();
    DisputeCasesAssignmentRules.assignDisputeCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.areEqual(
      QueryQueue.digitalFraudQueue.Id,
      newCase.OwnerId,
      'Case must be assigned to the Digital Fraud Queue.'
    );
  }
  /**
   * @description : This is to test that the case owner remains the same when the case is updated but the dispute reason and submitted__c value is not changed. This is to ensure that case is not reassigned when there is no change in the relevant fields for assignment rules
   *
   */
  @isTest
  static void testCaseOwnerSameForUpdate() {
    Case oldCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Subject = 'Test IMT Case assignment to DIGITAL_FRAUD_QUEUE',
      Dispute_Reason__c = SUSPECTED_FRAUD,
      Submitted__c = false,
      Description = 'Test IMT',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = Lib_FakeIdGenerator.getMockId(Case.getSObjectType())
    );
    Case newCase = new Case(
      RecordTypeId = RTCase.imtDispute,
      Status = OPEN_STATUS,
      Subject = 'Test IMT Case assignment to DIGITAL_FRAUD_QUEUE',
      Dispute_Reason__c = SUSPECTED_FRAUD,
      Submitted__c = false,
      Description = 'Test New Case IMT1',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Id = oldCase.Id
    );

    Test.startTest();
    DisputeCasesAssignmentRules.assignDisputeCases(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    Test.stopTest();
    Assert.isTrue(
      newCase.OwnerId == oldCase.OwnerId,
      'Case Owner should be same.'
    );
  }
}
