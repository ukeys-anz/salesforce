@IsTest
public class ExternalCaseStatusTriggerHandlerTest {
  @TestSetup
  static void setup() {
    Account newAccount = TestDataFactory.createTestAccountForDisputeCases();
    insert newAccount;
    FinServ__FinancialAccount__c newFinServFinancialAccount = TestDataFactory.createTestFinAccountForDisputeCases();
    newFinServFinancialAccount.FinServ__PrimaryOwner__c = newAccount.Id;
    insert newFinServFinancialAccount;
    List<Case> theCases = new List<Case>();
    Case theCase1 = TestDataFactory.createCase('Card_Dispute');
    theCase1.AccountId = newAccount.Id;
    theCase1.FinServ__FinancialAccount__c = newFinServFinancialAccount.Id;
    theCases.add(theCase1);
    Case theCase2 = TestDataFactory.createCase('NPP_Dispute');
    theCase2.AccountId = newAccount.Id;
    theCase2.FinServ__FinancialAccount__c = newFinServFinancialAccount.Id;
    theCases.add(theCase2);
    insert theCases;
  }

  @IsTest
  static void testExternalCaseStatusTriggerActions() {
    String recordTypeDeveloperName = 'Card_Dispute';
    String predicate =
      'RecordType.DeveloperName = \'' +
      recordTypeDeveloperName +
      '\'';
    Case theCase = CommonUtil.getCaseRecordWithAllFields(
      recordTypeDeveloperName,
      predicate
    );

    Map<String, Object> dataMap = new Map<String, Object>{
      'External_System__c' => 'Pega_Smarts ',
      'External_Case_Id__c' => 'ABC1234',
      'Status' => 'Under Investigation'
    };
    Test.startTest();
    theCase = TestDataFactory.updateCase(theCase, dataMap);
    String caseStatusBefore = theCase.Status;
    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Pending-xxxxx',
      Status_Event_ID__c = 'Status_Event_ID__c_0'
    );
    insert externalCaseStatus;
    theCase = [SELECT Id, Status, CaseNumber FROM Case WHERE Id = :theCase.Id];
    System.assertEquals(
      caseStatusBefore,
      theCase.Status,
      'Case status should not change'
    );

    Test.stopTest();
  }

  @isTest
  static void testCaseStatusUpdate() {
    String recordTypeDeveloperName = 'Card_Dispute';
    String predicate =
      'RecordType.DeveloperName = \'' +
      recordTypeDeveloperName +
      '\'';
    Case theCase = CommonUtil.getCaseRecordWithAllFields(
      recordTypeDeveloperName,
      predicate
    );

    Map<String, Object> dataMap = new Map<String, Object>{
      'External_System__c' => 'Pega_Smarts ',
      'External_Case_Id__c' => 'ABC1234',
      'Status' => 'Under Investigation'
    };
    Test.startTest();
    theCase = TestDataFactory.updateCase(theCase, dataMap);

    theCase = [SELECT Id, Status FROM Case WHERE Id = :theCase.Id];
    verifyRelatedCaseUpdate(theCase);
    Test.stopTest();
  }

  @isTest
  static void testExternalCaseStatusCloudEvent() {
    Case theCase = [SELECT Id, CaseNumber, Status FROM Case LIMIT 1];
    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Pending-xxxxx',
      Status_Event_ID__c = 'Status_Event_ID__c_0'
    );

    Test.startTest();
    insert externalCaseStatus;
    externalCaseStatus = [
      SELECT Id, Name, Case__c, External_Status__c, Status_Event_ID__c
      FROM External_Case_Status__c
      WHERE Id = :externalCaseStatus.Id
    ];

    Test.stopTest();

    verifyCloudEventForExternalCase(externalCaseStatus, theCase);
  }

  private static void verifyCloudEventForExternalCase(
    External_Case_Status__c externalCaseStatus,
    Case theCase
  ) {
    System.assertEquals(
      1,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
    System.assert(
      String.isNotBlank(CloudEventController.cloudEvents[0].Data_1__c),
      'Cloud Event should be generated'
    );
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    ExternalCaseStatusCloudEventModel externalCaseStatusCEModel = (ExternalCaseStatusCloudEventModel) JSON.deserialize(
      payload,
      ExternalCaseStatusCloudEventModel.class
    );

    Map<String, Object> mappedResponse = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Map<String, Object> mappedResponse2 = (Map<String, Object>) mappedResponse.get(
      'ce_data'
    );
    ExternalCaseStatusCloudEventModel.ExternalCaseStatusCloudEventDataModel externalCaseStatusCloudEventDataModel = (ExternalCaseStatusCloudEventModel.ExternalCaseStatusCloudEventDataModel) JSON.deserialize(
      JSON.serialize(mappedResponse2),
      ExternalCaseStatusCloudEventModel.ExternalCaseStatusCloudEventDataModel.class
    );

    System.assertEquals(
      theCase.CaseNumber,
      externalCaseStatusCloudEventDataModel.caseNumber,
      'Case Number should match'
    );
    System.assertEquals(
      'ExternalCaseStatusNumber/' + externalCaseStatus.Name,
      externalCaseStatusCEModel.ce_subject,
      'ce_subject should match'
    );
  }

  private static void verifyRelatedCaseUpdate(Case theCase) {
    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Resolved-xxxxx',
      Status_Event_ID__c = 'Status_Event_ID__c_1'
    );
    try {
      insert externalCaseStatus;
    } catch (DmlException e) {
      System.assert(
        false,
        'Failed to create External Case Status record: ' + e.getMessage()
      );
    }
    theCase = [SELECT Id, Status FROM Case WHERE Id = :theCase.Id];
    System.assertEquals(
      'Closed',
      theCase.Status,
      'Case status should change to Closed Status'
    );

    externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Pending-xxxxx',
      Status_Event_ID__c = 'Status_Event_ID__c_2'
    );
    try {
      insert externalCaseStatus;
    } catch (DmlException e) {
      System.assert(
        false,
        'External Case Status record should be created even when the Case is Closed: ' +
        e.getMessage()
      );
    }
    theCase = [SELECT Id, Status FROM Case WHERE Id = :theCase.Id];
    System.assertEquals(
      'Closed',
      theCase.Status,
      'Case status should be Closed'
    );
  }

  @isTest
  private static void testNppExternalCaseStatus() {
    String recordTypeDeveloperName = 'NPP_Dispute';
    String predicate =
      'RecordType.DeveloperName = \'' +
      recordTypeDeveloperName +
      '\'';
    Case theCase = CommonUtil.getCaseRecordWithAllFields(
      recordTypeDeveloperName,
      predicate
    );

    Map<String, Object> dataMap = new Map<String, Object>{
      'External_System__c' => 'Pega_PRS',
      'External_Case_Id__c' => 'ABC1234',
      'Status' => 'Open'
    };
    theCase = TestDataFactory.updateCase(theCase, dataMap);

    theCase = [SELECT Id, Status FROM Case WHERE Id = :theCase.Id];
    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Pending-Investigation',
      Status_Event_ID__c = 'Status_Event_ID__c_0'
    );
    Test.startTest();
    insert externalCaseStatus;
    theCase = [SELECT Id, Status, CaseNumber FROM Case WHERE Id = :theCase.Id];
    External_Case_Status__c theExternalCaseStatus = [
      SELECT Id, Internal_Description__c
      FROM External_Case_Status__c
      WHERE Id = :externalCaseStatus.Id
      LIMIT 1
    ];
    Test.stopTest();
    Assert.areEqual('On Hold', theCase.Status, 'Case status should be on hold');
    Assert.areEqual(
      'Under investigation',
      theExternalCaseStatus.Internal_Description__c,
      'Internal Description should be under investigation'
    );
  }

  @isTest
  private static void testNppDisputeUpdate() {
    String recordTypeDeveloperName = 'NPP_Dispute';
    String predicate =
      'RecordType.DeveloperName = \'' +
      recordTypeDeveloperName +
      '\'';
    Case theCase = CommonUtil.getCaseRecordWithAllFields(
      recordTypeDeveloperName,
      predicate
    );

    Map<String, Object> dataMap = new Map<String, Object>{
      'External_System__c' => 'Pega_PRS',
      'External_Case_Id__c' => 'ABC1234'
    };
    theCase = TestDataFactory.updateCase(theCase, dataMap);

    theCase = [SELECT Id, Status FROM Case WHERE Id = :theCase.Id];
    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Resolved-Duplicate',
      Status_Event_ID__c = 'Status_Event_ID__c_0'
    );
    Test.startTest();
    insert externalCaseStatus;
    theCase = [SELECT Id, Status, CaseNumber FROM Case WHERE Id = :theCase.Id];
    External_Case_Status__c theExternalCaseStatus = [
      SELECT Id, Internal_Description__c
      FROM External_Case_Status__c
      WHERE Id = :externalCaseStatus.Id
      LIMIT 1
    ];
    Test.stopTest();
    Assert.areEqual('Closed', theCase.Status, 'Case status should be closed');
    Assert.areEqual(
      'Closed as duplicate dispute',
      theExternalCaseStatus.Internal_Description__c,
      'Internal Description should be Closed as duplicate dispute'
    );
  }
}
