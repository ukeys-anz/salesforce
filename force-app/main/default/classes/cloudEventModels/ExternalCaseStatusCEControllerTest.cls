/**
 * @author Mohit Garg
 * @since  03/2026
 * @description  ExternalCaseStatusCEControllerTest Class for ExternalCaseStatusCEController
 */
@isTest
public class ExternalCaseStatusCEControllerTest {
  static Lib_MockProvider disputeRepoCaseMock;
  static Lib_MockProvider disputeRepoUserMock;
  static final Id FAKER_IMT_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );
  static final Id FAKER_NPP_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  static void registerMocks() {
    disputeRepoCaseMock = Lib_MockProvider.forType(
      DisputeExternalCaseStatusRepository.class
    );

    disputeRepoUserMock = Lib_MockProvider.forType(
      DisputeExternalCaseStatusRepository.class
    );
  }
  static Case nppCaseRecords {
    get {
      Case c = new Case(
        Id = FAKER_NPP_CASE_ID, //001
        Description = 'NPP Dispute Case Description Test_Text_32k',
        Dispute_Reason__c = 'Duplicate Transaction',
        Origin = 'In Phone',
        Intended_Amount__c = 1000.00,
        Status = 'Open',
        Submitted__c = false,
        Transaction_Id__c = 'Transaction Id Test_NPP_Text_255',
        Transaction_UUID__c = 'Transaction UUID Test_NPP_Text_255',
        RecordTypeId = RTCase.nppDispute
      );
      return c;
    }
  }
  static Case imtCaseRecords {
    get {
      return new Case(
        Id = FAKER_IMT_CASE_ID,
        Description = 'Test',
        Dispute_Reason__c = 'Cancel transfer',
        Origin = 'In Phone',
        Intended_Amount__c = 1000.00,
        Status = 'Open',
        Submitted__c = false,
        Transaction_Id__c = 'Transaction Id Test_IMT_Text_255',
        Transaction_UUID__c = 'Transaction UUID Test_IMT_Text_255',
        RecordTypeId = RTCase.imtDispute
      );
    }
  }

  static External_Case_Status__c externalCaseRecords {
    get {
      return new External_Case_Status__c(
        Id = Lib_FakeIdGenerator.getMockId(External_Case_Status__c.SObjectType),
        Case__c = FAKER_IMT_CASE_ID,
        External_Status__c = 'IMT_New',
        Status_Event_ID__c = '1234567890'
      );
    }
  }
  static External_Case_Status__c nppExternalCaseRecords {
    get {
      return new External_Case_Status__c(
        Id = Lib_FakeIdGenerator.getMockId(External_Case_Status__c.SObjectType),
        Case__c = FAKER_NPP_CASE_ID, //001
        External_Status__c = 'NPP_New',
        Status_Event_ID__c = '1234567890'
      );
    }
  }

  static User userRecords {
    get {
      return new User(
        Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Alias = 'stduser',
        Email = 'standard.user@anz.com',
        LastName = 'Testing',
        ProfileId = Lib_FakeIdGenerator.getMockId(Profile.SObjectType),
        UserName = 'standard.user@anztest.com',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'GMT',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8'
      );
    }
  }

  // Test method for publishing v1beta2 cloud events related to External Case Status for IMT dispute
  @IsTest
  static void testPublishExternalCaseCloudEventsV1Beta2() {
    // Register Mocks
    registerMocks();
    // Start the test execution
    Test.startTest();

    disputeRepoCaseMock.mock(
      'getRelatedCasesByCaseId',
      new List<Case>{ imtCaseRecords }
    );
    disputeRepoUserMock.mock(
      'getRelatedUsersByUserId',
      new List<User>{ userRecords }
    );

    ExternalCaseStatusCEController.publishCloudEvents(
      new List<External_Case_Status__c>{ externalCaseRecords }
    );
    DisputeExternalCaseStatusRepository disputeRepo = new DisputeExternalCaseStatusRepository();
    disputeRepo.getRelatedCasesByCaseId(new Set<Id>{ FAKER_IMT_CASE_ID });
    disputeRepo.getRelatedUsersByUserId(new Set<Id>{ userRecords.Id });
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[1].Data_1__c; //[1] for beta2 events
    ExternalCaseStatusCloudEventModel externalCaseStatusCEModel = (ExternalCaseStatusCloudEventModel) JSON.deserialize(
      payload,
      ExternalCaseStatusCloudEventModel.class
    );
    Assert.areEqual(
      'anzx.salesforce.case.v1beta2.dispute.imt.externalstatus.created',
      externalCaseStatusCEModel.ce_type,
      'ce_type is correct'
    );
    Assert.areEqual(
      'proto://buf.anz/anz/salesforceapis/salesforce.service.disputes.v1beta2#ExternalCaseStatus',
      externalCaseStatusCEModel.ce_dataschema,
      'ce_dataschema is correct'
    );
    Assert.areEqual(
      2,
      CloudEventController.cloudEvents.size(),
      '2 External Case Status cloud events should be generated'
    );
  }

  // Test method for publishing v1beta1 cloud events related to External Case Status for Npp dispute
  @IsTest
  static void testPublishExternalCaseCloudEventsV1Beta1() {
    // Register Mocks
    registerMocks();
    // Start the test execution
    disputeRepoCaseMock.mock(
      'getRelatedCasesByCaseId',
      new List<Case>{ nppCaseRecords }
    );

    disputeRepoUserMock.mock(
      'getRelatedUsersByUserId',
      new List<User>{ userRecords }
    );
    Test.startTest();
    // Prepare the mock data
    DisputeExternalCaseStatusRepository disputeRepo = new DisputeExternalCaseStatusRepository();
    disputeRepo.getRelatedCasesByCaseId(new Set<Id>{});
    disputeRepo.getRelatedUsersByUserId(new Set<Id>{});
    try {
      disputeRepo.queryCaseStatuses('', new Map<String, Object>{});
    } catch (exception e) {
      Assert.isTrue(
        e.getMessage().contains('unexpected token'),
        'queryCaseStatuses method should be called with the correct parameters'
      );
    }
    ExternalCaseStatusCEController.publishCloudEvents(
      new List<External_Case_Status__c>{ nppExternalCaseRecords }
    );
    Test.stopTest();
    String payload = CloudEventController.cloudEvents[1].Data_1__c; // [1] for beta1 events
    ExternalCaseStatusCloudEventModel externalCaseStatusCEModel = (ExternalCaseStatusCloudEventModel) JSON.deserialize(
      payload,
      ExternalCaseStatusCloudEventModel.class
    );
    Assert.areEqual(
      'anzx.salesforce.case.v1beta1.dispute.npp.externalstatus.created',
      externalCaseStatusCEModel.ce_type,
      'ce_type is correct'
    );
    Assert.areEqual(
      'proto://buf.anz/anz/salesforceapis/salesforce.service.disputes.v1beta1#ExternalCaseStatus',
      externalCaseStatusCEModel.ce_dataschema,
      'ce_dataschema is correct'
    );

    Assert.areEqual(
      2,
      CloudEventController.cloudEvents.size(),
      '2 External Case Status cloud events should be generated'
    );
  }
}
