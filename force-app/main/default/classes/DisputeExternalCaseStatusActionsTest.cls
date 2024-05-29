/**
 * @author Tan Phan
 * @since 04/2024
 * @description Test class for {@link DisputeExternalCaseStatusActions}
 */
@isTest
private class DisputeExternalCaseStatusActionsTest {
  static Faker faker = new Faker('AU');
  static final String CARD_DISPUTE_CASE_EXTID = 'DisputeCase001';

  static PegaExternalCaseStatuses__mdt mapping {
    get {
      if (mapping == null) {
        mapping = [
          SELECT
            DisputeStatus__c,
            ExternalStatus__c,
            QueueName__c,
            RecordType__c,
            SLADaysInStatus__c,
            SLAQueueName__c
          FROM PegaExternalCaseStatuses__mdt
          WHERE DisputeReason__c = NULL AND SLADaysInStatus__c > 0
          LIMIT 1
        ];
      }
      return mapping;
    }
    set;
  }

  @TestSetup
  static void makeData() {
    User cardDisputeAgentUser = TestDataFactory.cardDisputeAgentUser;
    Case theCase = new Case(
      RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get(mapping.RecordType__c)
        .getRecordTypeId(),
      External_System__c = 'Pega_PRS',
      External_Case_ID__c = CARD_DISPUTE_CASE_EXTID
    );
    System.runAs(cardDisputeAgentUser) {
      insert theCase;
      insert new External_Case_Status__c(
        Case__c = theCase.Id,
        External_Status__c = mapping.ExternalStatus__c,
        Status_Event_ID__c = faker.randomString(10),
        Status_Timestamp__c = Date.today()
          .addDays((Integer) mapping.SLADaysInStatus__c * -1)
      );
    }
  }

  @IsTest
  static void testGetMapping() {
    Case theCase = getSampleCase();
    for (PegaExternalCaseStatuses__mdt mapping : [
      SELECT
        MasterLabel,
        DisputeReason__c,
        DisputeStatus__c,
        ExternalStatus__c,
        QueueName__c,
        RecordType__c
      FROM PegaExternalCaseStatuses__mdt
    ]) {
      theCase.RecordType.DeveloperName = mapping.RecordType__c;
      theCase.External_Case_Statuses__r[0]
        .External_Status__c = mapping.ExternalStatus__c;
      if (String.isBlank(mapping.DisputeReason__c)) {
        theCase.Dispute_Reason__c = 'Charged more than once';
        PegaExternalCaseStatuses__mdt retrievedMapping = DisputeExternalCaseStatusActions.getMapping(
          theCase
        );
        Assert.areEqual(
          mapping.MasterLabel,
          retrievedMapping.MasterLabel,
          'Mapping should be retrieved in accordance to the given Case and External_Case_Status__c'
        );
      } else {
        for (String disputeReason : mapping.DisputeReason__c.split(';')) {
          theCase.Dispute_Reason__c = disputeReason;
          PegaExternalCaseStatuses__mdt retrievedMapping = DisputeExternalCaseStatusActions.getMapping(
            theCase
          );
          Assert.areEqual(
            mapping.MasterLabel,
            retrievedMapping.MasterLabel,
            'Mapping should be retrieved in accordance to the given Case and External_Case_Status__c'
          );
        }
      }
    }
  }

  @IsTest
  static void testCardDisputeCaseQueueAssignment() {
    assertUpdateRelatedCasesStatusAndOwner();
    assertDisputeCaseToSlaQueueAssignment();
    assertAssignCaseToOriginalQueue();
  }

  static void assertUpdateRelatedCasesStatusAndOwner() {
    Case theCase = getSampleCase();
    Assert.areEqual(
      CommonUtil.getQueueByName(mapping.QueueName__c).Id,
      theCase.OwnerId,
      'Case owner must be set to queue in accordance to mapping'
    );
    Assert.areEqual(
      mapping.DisputeStatus__c,
      theCase.Status,
      'Case status must be set in accordance to mapping'
    );
  }

  static void assertDisputeCaseToSlaQueueAssignment() {
    Case theCase = getSampleCaseAndShare();

    System.runAs(TestDataFactory.cardDisputeAgentUser) {
      Test.startTest();
      new DisputeCaseToSlaQueueSchedulable().execute(null);
      Test.stopTest();
    }
    theCase = getSampleCase();
    Assert.areEqual(
      CommonUtil.getQueueByName(mapping.SLAQueueName__c).Id,
      theCase.OwnerId,
      'Case owner must be set to SLA queue in accordance to mapping'
    );
  }

  static void assertAssignCaseToOriginalQueue() {
    Case theCase = getSampleCaseAndShare();

    System.runAs(TestDataFactory.cardDisputeAgentUser) {
      DisputeExternalCaseStatusController.assignCaseToOriginalQueue(theCase.Id);
    }
    theCase = getSampleCase();
    Assert.areEqual(
      CommonUtil.getQueueByName(mapping.QueueName__c).Id,
      theCase.OwnerId,
      'Case owner must be set to back to original queue in accordance to mapping'
    );
  }

  static Case getSampleCase() {
    return [
      SELECT
        Id,
        Status,
        OwnerId,
        RecordType.DeveloperName,
        (SELECT Id FROM External_Case_Statuses__r)
      FROM Case
      WHERE External_Case_ID__c = :CARD_DISPUTE_CASE_EXTID
    ];
  }

  static Case getSampleCaseAndShare() {
    Case theCase = getSampleCase();
    insert new CaseShare(
      CaseId = theCase.id,
      UserOrGroupId = TestDataFactory.cardDisputeAgentUser.Id,
      CaseAccessLevel = 'Edit'
    );
    return theCase;
  }
}
